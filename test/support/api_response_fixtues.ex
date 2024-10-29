defmodule Test.Support.ApiResponseFixtures do
  def version_response do
    ~s<{
      "api": "2.0.0",
      "capabilities": {"upload-by-put": true},
      "hostname": "prusa-mk4",
      "nozzle_diameter": 0.4,
      "server": "2.1.2",
      "text": "PrusaLink"
    }>
  end

  def info_response do
    ~s<{
      "mmu": false,
      "nozzle_diameter": 0.4,
      "hostname": "prusa-mk4",
      "serial": "1234567890",
      "min_extrusion_temp":	170
    }>
  end

  def status_response do
    ~s<{
      "job": {
        "id": 297,
        "progress": 91.00,
        "time_remaining": 600,
        "time_printing": 7718
      },
      "storage": {
        "path": "/usb/",
        "name": "usb",
        "read_only": false
      },
      "printer": {
        "state": "PRINTING",
        "temp_bed": 60.0,
        "target_bed": 60.0,
        "temp_nozzle": 209.9,
        "target_nozzle": 210.0,
        "axis_z": 2.4,
        "flow": 100,
        "speed": 100,
        "fan_hotend": 3099,
        "fan_print": 5964
      }
    }>
  end

  def job_response do
    ~s<{
      "id": 297,
      "state": "PRINTING",
      "progress": 92.00,
      "time_remaining": 540,
      "time_printing": 7799,
      "file": {
          "refs": {
              "icon": "/thumb/s/usb/MURCIE~1.BGC",
              "thumbnail": "/thumb/l/usb/MURCIE~1.BGC",
              "download": "/usb/MURCIE~1.BGC"
          },
          "name": "MURCIE~1.BGC",
          "display_name": "murcielago-grande_0.4n_0.2mm_PLA_MK4_2h16m.bgcode",
          "path": "/usb",
          "size": 1176046,
          "m_timestamp": 1729957167
      }
    }>
  end

  def storage_response do
    ~s<{
      "storage_list": [
        {
          "available": true,
          "name": "usb",
          "path": "/usb/",
          "read_only": false,
          "type": "USB"
        }
      ]
    }>
  end

  def files_response do
    ~s<{
      "children": [
        {
          "display_name": "painting_cone_0.4n_0.2mm_PETG_MK4_31m.bgcode",
          "m_timestamp": 1729258582,
          "name": "PAINTI~1.BGC",
          "refs": {
            "download": "/usb/PAINTI~1.BGC",
            "icon": "/thumb/s/usb/PAINTI~1.BGC",
            "thumbnail": "/thumb/l/usb/PAINTI~1.BGC"
          },
          "ro": false,
          "type": "PRINT_FILE"
        },
        {
          "display_name": "ghost_0.4n_0.2mm_PLA_MK4_1h50m.bgcode",
          "m_timestamp": 1729768690,
          "name": "GHOST_~1.BGC",
          "refs": {
            "download": "/usb/GHOST_~1.BGC",
            "icon": "/thumb/s/usb/GHOST_~1.BGC",
            "thumbnail": "/thumb/l/usb/GHOST_~1.BGC"
          },
          "ro": false,
          "type": "PRINT_FILE"
        }
      ],
      "name": "usb",
      "ro": false,
      "type": "FOLDER"
    }>
  end

  def upload_response do
    ~s<{
      "display_name": "atlc.bgcode",
      "m_timestamp": 1730217507,
      "name": "ATLC~1.BGC",
      "refs": {
        "download": "/usb/ATLC~1.BGC",
        "icon": "/thumb/s/usb/ATLC~1.BGC",
        "thumbnail": "/thumb/l/usb/ATLC~1.BGC"
      },
      "ro": false,
      "size": 437662,
      "type": "PRINT_FILE"
    }>
  end
end
