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
  """
  @spec status(%PrusaLink.Printer{}) ::
          {:ok, any()}
          | {:error,
             :not_found | :timeout | :unauthorized | {:error, any()} | {:ok, Tesla.Env.t()}}
  def status(%Printer{} = printer), do: call(printer, :get, "/status") |> handle_resp()

  @doc """
  Returns information about the current printing job if one is running.
  Otherwise it returns an emtpy list.
  """
  @spec job(%PrusaLink.Printer{}) ::
          {:ok, any()}
          | {:error,
             :not_found | :timeout | :unauthorized | {:error, any()} | {:ok, Tesla.Env.t()}}
  def job(%Printer{} = printer), do: call(printer, :get, "/job") |> handle_resp()

  def job_stop(%Printer{} = printer, job_id),
    do: call(printer, :delete, "/job/#{job_id}") |> handle_resp()

  def job_pause(%Printer{} = printer, job_id),
    do: call(printer, :put, "/job/#{job_id}/pause") |> handle_resp()

  def job_resume(%Printer{} = printer, job_id),
    do: call(printer, :put, "/job/#{job_id}/resume") |> handle_resp()

  def storage(%Printer{} = printer), do: call(printer, :get, "/storage") |> handle_resp()

  def files(%Printer{} = printer, storage, path),
    do: call(printer, :get, "/files/#{storage}/#{path}") |> handle_resp()

  def upload(%Printer{} = printer, storage, path, content),
    do: call(printer, :put, "/files/#{storage}/#{path}", content) |> handle_resp()

  def print(%Printer{} = printer, storage, path),
    do: call(printer, :post, "/files/#{storage}/#{path}") |> handle_resp()

  defp handle_resp({:ok, %Tesla.Env{status: status, body: body}}) when status in [200, 201],
    do: {:ok, body}

  defp handle_resp({:ok, %Tesla.Env{status: 204}}), do: {:ok, []}

  defp handle_resp({:ok, %Tesla.Env{status: status}}) when status in [403, 404],
    do: {:error, :not_found}

  defp handle_resp({:ok, %Tesla.Env{status: 401}}), do: {:error, :unauthorized}

  defp handle_resp({:error, {:error, %{reason: :timeout}}}),
    do: {:error, :timeout}

  defp handle_resp(error), do: {:error, error}

  defp call(%Printer{client: client} = printer, method, endpoint) do
    request(client, method: method, url: "/api/v#{printer.api_version}#{endpoint}")
  end

  # upload
  defp call(%Printer{client: client} = printer, :put, endpoint, content) do
    request(client,
      method: :put,
      headers: [{"Overwrite", "?0"}, {"Print-After-Upload", "?0"}],
      url: "/api/v#{printer.api_version}#{endpoint}",
      body: content
    )
  end
end
