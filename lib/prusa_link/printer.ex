defmodule PrusaLink.Printer do
  @moduledoc """
  Representation of a Prusa 3D printer and how to connect to it.
  """
  alias PrusaLink.Printer
  alias PrusaLink.Api

  defstruct [:client, :name, :api_version, :capabilities, :nozzle, :mmu, :serial]

  @doc """
  Create a new printer representation.
  It tries to connect to two endpoints (version & info) to retrieve meta information.

  Returns a %PrusaLink.Printer{} struct including the information to connect to the printer as well as some meta information.
  If the printer can not be reached it returns a tuple with {:unreachable, %Printer{}}.
  The printer struct can still be used to connect to the printer later assuming the giving information is correct.
  """
  @spec new(host_or_ip :: binary(), password :: binary()) ::
          {:ok,
           %PrusaLink.Printer{
             client: Tesla.Client.t(),
             api_version: integer()
           }}
          | {:not_reachable,
             %PrusaLink.Printer{
               client: Tesla.Client.t(),
               api_version: integer()
             }}
          | {:error, reason :: any()}
  def new(_host_or_ip, nil), do: {:error, :no_password}

  def new(host_or_ip, password) do
    Tesla.client(
      [
        {Tesla.Middleware.BaseUrl, "http://#{host_or_ip}"},
        {Tesla.Middleware.DecodeJson, engine_opts: [keys: :atoms]},
        {Tesla.Middleware.Headers, [{"X-Api-Key", password}]},
        {Tesla.Middleware.Timeout, timeout: 5_000}
        # {Tesla.Middleware.BasicAuth, %{username: user, password: password}}
      ],
      Tesla.Adapter.Mint
    )
    |> fetch_printer_info()
  end

  @doc """
  Connect to the printer to update meta data and specs.
  Useful if you called `PrusaLink.Printer.new/2` before and received a `{:not_reachable, printer_struct}`,
  you can pass the printer_struct in and try again.
  """
  @doc since: "0.1.3"
  @spec refresh(%Printer{}) ::
          {:ok,
           %PrusaLink.Printer{
             client: Tesla.Client.t(),
             api_version: integer()
           }}
          | {:not_reachable,
             %PrusaLink.Printer{
               client: Tesla.Client.t(),
               api_version: integer()
             }}
          | {:error, reason :: any()}
  def refresh(%__MODULE__{client: client}) do
    fetch_printer_info(client)
  end

  @doc """
  Retuns the meta information retrieved from the printer when connecting to it the first time.

  ## Examples

      iex> PrusaLink.Printer.specs(mk4)
      %{
        name: "prusa-mk4",
        serial: "1234567890",
        api_version: 1,
        capabilities: %{"upload-by-put": true},
        nozzle: 0.4,
        mmu: false
      }
  """
  @spec specs(%Printer{}) :: map()
  def specs(%__MODULE__{} = printer) do
    printer
    |> Map.from_struct()
    |> Map.drop([:client])
  end

  defp fetch_printer_info(client) do
    with {:ok, version_resp} <- Api.api_version(client),
         {:ok, info_resp} <- Api.info(client, 1) do
      {:ok, build_printer(client, version_resp, info_resp)}
    else
      {:error, {:error, :timeout}} ->
        {:not_reachable, struct(__MODULE__, %{client: client, api_version: 1})}

      {:error, {:error, %Mint.TransportError{reason: :ehostunreach}}} ->
        {:not_reachable, struct(__MODULE__, %{client: client, api_version: 1})}

      {:error, error} ->
        {:error, error}
    end
  end

  defp build_printer(client, version_resp, info_resp) do
    fields = %{
      client: client,
      name: version_resp[:hostname],
      # api_version: version_resp["api"],
      api_version: 1,
      capabilities: version_resp[:capabilities],
      nozzle: version_resp[:nozzle_diameter],
      mmu: info_resp[:mmu],
      serial: info_resp[:serial]
    }

    struct(__MODULE__, fields)
  end
end
