defmodule Test.Support.SzenarioSetups do
  import Test.Support.ApiResponseFixtures
  alias PrusaLink.Printer

  @existing_job_id 123
  @not_existing_job_id 999

  def unauthorized(%{bypass: bypass}) do
    Bypass.stub(bypass, "GET", "/api/version", fn conn ->
      conn
      |> Plug.Conn.resp(401, "")
    end)
  end

  def not_initialized(%{bypass: bypass}) do
    Bypass.expect_once(bypass, "GET", "/api/version", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, version_response())
    end)

    Bypass.expect_once(bypass, "GET", "/api/v1/info", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, info_response())
    end)
  end

  def printing_mk4(%{bypass: bypass, host: host}) do
    Bypass.stub(bypass, "GET", "/api/v1/status", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, status_response())
    end)

    Bypass.stub(bypass, "GET", "/api/v1/job", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, job_response())
    end)

    Bypass.stub(bypass, "DELETE", "/api/v1/job/#{@existing_job_id}", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(204, "")
    end)

    Bypass.stub(bypass, "PUT", "/api/v1/job/#{@existing_job_id}/pause", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(204, "")
    end)

    Bypass.stub(bypass, "PUT", "/api/v1/job/#{@not_existing_job_id}/pause", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(404, "")
    end)

    Bypass.stub(bypass, "PUT", "/api/v1/job/#{@existing_job_id}/resume", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(204, "")
    end)

    Bypass.stub(bypass, "GET", "/api/v1/storage", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, storage_response())
    end)

    Bypass.stub(bypass, "GET", "/api/v1/files/usb//", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, files_response())
    end)

    Bypass.stub(bypass, "POST", "/api/v1/files/usb/file.bgcode", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(204, "")
    end)

    Bypass.stub(bypass, "PUT", "/api/v1//files/usb/README.md", fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.resp(200, upload_response())
    end)

    %{
      printer: mk4(host),
      existing_job_id: @existing_job_id,
      not_existing_job_id: @not_existing_job_id
    }
  end

  def mk4(host) do
    %Printer{
      client: %Tesla.Client{
        fun: nil,
        pre: [
          {Tesla.Middleware.BaseUrl, :call, ["http://#{host}"]},
          {Tesla.Middleware.DecodeJson, :call, [[{:engine_opts, [keys: :atoms]}]]},
          {Tesla.Middleware.Headers, :call, [[{"X-Api-Key", "password"}]]},
          {Tesla.Middleware.Timeout, :call, [[timeout: 5000]]}
        ],
        post: [],
        adapter: {Tesla.Adapter.Mint, :call, [[]]}
      },
      name: "prusa-mk4",
      api_version: 1,
      capabilities: %{"upload-by-put": true},
      nozzle: 0.4,
      mmu: false,
      serial: "1234567890"
    }
  end
end
