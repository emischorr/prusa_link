defmodule PrusaLink.Api do
  @moduledoc """
  Endpoint implementation according to the openapi spec from Prusa:
  https://github.com/prusa3d/Prusa-Link-Web/blob/master/spec/openapi.yaml
  """

  use Tesla, docs: false
  alias PrusaLink.Printer

  def api_version(client), do: get(client, "/api/version") |> handle_resp()
  def info(client, api_version), do: get(client, "api/v#{api_version}/info") |> handle_resp()

  @doc """
  Retrieves current status from the printer.

  ## Examples

      iex> PrusaLink.status(printer)
      {:ok, %{
        job: %{
          id: 297,
          progress: 91.00,
          time_remaining: 600,
          time_printing: 7718
        },
        storage: %{
          path: "/usb/",
          name: "usb",
          read_only: false
        },
        printer: %{
          state: "PRINTING",
          temp_bed: 60.0,
          target_bed: 60.0,
          temp_nozzle: 209.9,
          target_nozzle: 210.0,
          axis_z: 2.4,
          flow: 100,
          speed: 100,
          fan_hotend: 3099,
          fan_print: 5964
        }
      }}
  """
  @spec status(%PrusaLink.Printer{}) ::
          {:ok, any()}
          | {:error,
             :not_found
             | :timeout
             | :not_reachable
             | :unauthorized
             | {:error, any()}
             | {:ok, Tesla.Env.t()}}
  def status(%Printer{} = printer), do: call(printer, :get, "/status") |> handle_resp()

  @doc """
  Returns information about the current printing job if one is running.
  Otherwise it returns an emtpy list.
  """
  @spec job(%PrusaLink.Printer{}) ::
          {:ok, any()}
          | {:error,
             :not_found
             | :timeout
             | :not_reachable
             | :unauthorized
             | {:error, any()}
             | {:ok, Tesla.Env.t()}}
  def job(%Printer{} = printer), do: call(printer, :get, "/job") |> handle_resp()

  @doc """
  Stops a currently running job.
  The job can not be resumed.
  """
  @spec job_stop(%PrusaLink.Printer{}, job_id :: integer()) ::
          {:ok, any()}
          | {:error,
             :not_found
             | :timeout
             | :not_reachable
             | :unauthorized
             | {:error, any()}
             | {:ok, Tesla.Env.t()}}
  def job_stop(%Printer{} = printer, job_id),
    do: call(printer, :delete, "/job/#{job_id}") |> handle_resp()

  @doc """
  Pauses the execution of a currently running job.
  Can be resumed later.
  """
  @spec job_pause(%PrusaLink.Printer{}, job_id :: integer()) ::
          {:ok, any()}
          | {:error,
             :not_found
             | :timeout
             | :not_reachable
             | :unauthorized
             | {:error, any()}
             | {:ok, Tesla.Env.t()}}
  def job_pause(%Printer{} = printer, job_id),
    do: call(printer, :put, "/job/#{job_id}/pause") |> handle_resp()

  @doc """
  Resumes a job that was paused before.
  """
  @spec job_resume(%PrusaLink.Printer{}, job_id :: integer()) ::
          {:ok, any()}
          | {:error,
             :not_found
             | :timeout
             | :not_reachable
             | :unauthorized
             | {:error, any()}
             | {:ok, Tesla.Env.t()}}
  def job_resume(%Printer{} = printer, job_id),
    do: call(printer, :put, "/job/#{job_id}/resume") |> handle_resp()

  @doc """
  Returns storage information.
  """
  @spec storage(%PrusaLink.Printer{}) ::
          {:ok, any()}
          | {:error,
             :not_found
             | :timeout
             | :not_reachable
             | :unauthorized
             | {:error, any()}
             | {:ok, Tesla.Env.t()}}
  def storage(%Printer{} = printer), do: call(printer, :get, "/storage") |> handle_resp()

  @doc """
  Retuns a file listing for the given storage and path.
  To find out which storage options are connected to the printer see `PrusaLink.Api.storage/1`
  """
  @spec files(%PrusaLink.Printer{}, storage :: binary(), path :: binary()) ::
          {:ok, any()}
          | {:error,
             :not_found
             | :timeout
             | :not_reachable
             | :unauthorized
             | {:error, any()}
             | {:ok, Tesla.Env.t()}}
  def files(%Printer{} = printer, storage, path),
    do: call(printer, :get, "/files/#{storage}/#{path}") |> handle_resp()

  @doc """
  Upload a file to the given printer storage.
  The given path should include the target filename of the file on the printer and not just the folder.

  NOTE:
  Does not override existing file and does not start printing automatically after upload.

  ## Examples

      iex> PrusaLink.Api.upload(printer, "usb", "/model.bgcode", file_content)
      {:ok, []}
  """
  @doc since: "0.1.1"
  @spec upload(%PrusaLink.Printer{}, storage :: binary(), path :: binary(), content :: any()) ::
          {:ok, any()}
          | {:error,
             :not_found
             | :timeout
             | :not_reachable
             | :unauthorized
             | {:error, any()}
             | {:ok, Tesla.Env.t()}}
  def upload(%Printer{} = printer, storage, path, content),
    do: call(printer, :put, "/files/#{storage}/#{path}", content) |> handle_resp()

  @doc """
  Starts a print job with the given file.

  ## Examples

      iex> PrusaLink.Api.print(printer, "usb", "/model.bgcode")
      {:ok, []}
  """
  @spec print(%PrusaLink.Printer{}, storage :: binary(), path :: binary()) ::
          {:ok, any()}
          | {:error,
             :not_found
             | :timeout
             | :not_reachable
             | :unauthorized
             | {:error, any()}
             | {:ok, Tesla.Env.t()}}
  def print(%Printer{} = printer, storage, path),
    do: call(printer, :post, "/files/#{storage}/#{path}") |> handle_resp()

  defp handle_resp({:ok, %Tesla.Env{status: status, body: body}}) when status in [200, 201],
    do: {:ok, body}

  defp handle_resp({:ok, %Tesla.Env{status: 204}}), do: {:ok, []}

  defp handle_resp({:ok, %Tesla.Env{status: status}}) when status in [403, 404],
    do: {:error, :not_found}

  defp handle_resp({:ok, %Tesla.Env{status: 401}}), do: {:error, :unauthorized}

  defp handle_resp({:error, :timeout}), do: {:error, :not_reachable}

  defp handle_resp({:error, %Mint.TransportError{reason: reason}})
       when reason in [:ehostunreach, :ehostdown],
       do: {:error, :not_reachable}

  defp handle_resp(error), do: error

  defp call(%Printer{client: client} = printer, method, endpoint) do
    request(client, method: method, url: "/api/v#{printer.api_version}#{endpoint}")
  end

  # upload
  defp call(%Printer{client: client} = printer, :put, endpoint, content) do
    request(client,
      method: :put,
      headers: [
        {"Overwrite", "?0"},
        {"Print-After-Upload", "?0"},
        {"Content-Type", "application/octet-stream"}
      ],
      url: "/api/v#{printer.api_version}#{endpoint}",
      body: content
    )
  end
end
