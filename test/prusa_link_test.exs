defmodule PrusaLinkTest do
  use ExUnit.Case
  import Test.Support.SzenarioSetups

  doctest PrusaLink

  setup do
    bypass = Bypass.open()
    host = "127.0.0.1:#{bypass.port()}"

    {:ok, bypass: bypass, host: host}
  end

  describe "With a responding mk4" do
    setup :not_initialized

    test "printer/2 can connect to printer and return printer struct", %{host: host} do
      expected_printer = mk4(host)
      assert {:ok, ^expected_printer} = PrusaLink.printer(host, "password")
    end
  end

  describe "With a unauthorized mk4" do
    setup :unauthorized

    test "printer/2 returns error", %{host: host} do
      assert PrusaLink.printer(host, "wrong_password") == {:error, :unauthorized}
    end
  end

  describe "With initialized mk4 printer" do
    setup :printing_mk4

    test "specs/1 return printer specs", %{printer: printer} do
      assert PrusaLink.specs(printer) == %{
               name: "prusa-mk4",
               serial: "1234567890",
               api_version: 1,
               capabilities: %{"upload-by-put" => true},
               nozzle: 0.4,
               mmu: false
             }
    end

    test "status/1 can retrieve current status", %{printer: printer} do
      assert PrusaLink.status(printer) ==
               {:ok,
                %{
                  "job" => %{
                    "id" => 297,
                    "progress" => 91.0,
                    "time_printing" => 7718,
                    "time_remaining" => 600
                  },
                  "printer" => %{
                    "axis_z" => 2.4,
                    "fan_hotend" => 3099,
                    "fan_print" => 5964,
                    "flow" => 100,
                    "speed" => 100,
                    "state" => "PRINTING",
                    "target_bed" => 60.0,
                    "target_nozzle" => 210.0,
                    "temp_bed" => 60.0,
                    "temp_nozzle" => 209.9
                  },
                  "storage" => %{"name" => "usb", "path" => "/usb/", "read_only" => false}
                }}
    end

    test "job/1 can retrieve job info", %{printer: printer} do
      assert PrusaLink.job(printer) ==
               {:ok,
                %{
                  "file" => %{
                    "display_name" => "murcielago-grande_0.4n_0.2mm_PLA_MK4_2h16m.bgcode",
                    "m_timestamp" => 1_729_957_167,
                    "name" => "MURCIE~1.BGC",
                    "path" => "/usb",
                    "refs" => %{
                      "download" => "/usb/MURCIE~1.BGC",
                      "icon" => "/thumb/s/usb/MURCIE~1.BGC",
                      "thumbnail" => "/thumb/l/usb/MURCIE~1.BGC"
                    },
                    "size" => 1_176_046
                  },
                  "id" => 297,
                  "progress" => 92.0,
                  "state" => "PRINTING",
                  "time_printing" => 7799,
                  "time_remaining" => 540
                }}
    end

    test "job_stop/2 can stop a job", %{printer: printer, existing_job_id: existing_job_id} do
      assert PrusaLink.job_stop(printer, existing_job_id) == {:ok, []}
    end

    test "job_pause/2 can pause a job", %{printer: printer, existing_job_id: existing_job_id} do
      assert PrusaLink.job_pause(printer, existing_job_id) == {:ok, []}
    end

    test "job_pause/2 returns an error for a not existing job id", %{
      printer: printer,
      not_existing_job_id: not_existing_job_id
    } do
      assert PrusaLink.job_pause(printer, not_existing_job_id) == {:error, :not_found}
    end

    test "job_resume/2 can resume a job", %{printer: printer, existing_job_id: existing_job_id} do
      assert PrusaLink.job_resume(printer, existing_job_id) == {:ok, []}
    end

    test "storage/1 returns storage info", %{printer: printer} do
      assert PrusaLink.storage(printer) ==
               {:ok,
                %{
                  "storage_list" => [
                    %{
                      "available" => true,
                      "name" => "usb",
                      "path" => "/usb/",
                      "read_only" => false,
                      "type" => "USB"
                    }
                  ]
                }}
    end

    test "files/1 returns file listing", %{printer: printer} do
      assert PrusaLink.files(printer) ==
               {:ok,
                %{
                  "children" => [
                    %{
                      "display_name" => "painting_cone_0.4n_0.2mm_PETG_MK4_31m.bgcode",
                      "m_timestamp" => 1_729_258_582,
                      "name" => "PAINTI~1.BGC",
                      "refs" => %{
                        "download" => "/usb/PAINTI~1.BGC",
                        "icon" => "/thumb/s/usb/PAINTI~1.BGC",
                        "thumbnail" => "/thumb/l/usb/PAINTI~1.BGC"
                      },
                      "ro" => false,
                      "type" => "PRINT_FILE"
                    },
                    %{
                      "display_name" => "ghost_0.4n_0.2mm_PLA_MK4_1h50m.bgcode",
                      "m_timestamp" => 1_729_768_690,
                      "name" => "GHOST_~1.BGC",
                      "refs" => %{
                        "download" => "/usb/GHOST_~1.BGC",
                        "icon" => "/thumb/s/usb/GHOST_~1.BGC",
                        "thumbnail" => "/thumb/l/usb/GHOST_~1.BGC"
                      },
                      "ro" => false,
                      "type" => "PRINT_FILE"
                    }
                  ],
                  "name" => "usb",
                  "ro" => false,
                  "type" => "FOLDER"
                }}
    end

    test "print/1 starts printing", %{printer: printer} do
      assert PrusaLink.print(printer, "usb", "file.bgcode") == {:ok, []}
    end

    test "upload/1 uploads a file to the usb storage", %{printer: printer} do
      assert PrusaLink.upload(printer, "./README.md") == {
               :ok,
               %{
                 "display_name" => "atlc.bgcode",
                 "m_timestamp" => 1_730_217_507,
                 "name" => "ATLC~1.BGC",
                 "refs" => %{
                   "download" => "/usb/ATLC~1.BGC",
                   "icon" => "/thumb/s/usb/ATLC~1.BGC",
                   "thumbnail" => "/thumb/l/usb/ATLC~1.BGC"
                 },
                 "ro" => false,
                 "size" => 437_662,
                 "type" => "PRINT_FILE"
               }
             }
    end

    test "upload/1 returns an error for a not existing file", %{printer: printer} do
      assert PrusaLink.upload(printer, "not_existing.bgcode") == {:error, :file_not_found}
    end
  end
end
