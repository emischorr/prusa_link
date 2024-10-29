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
  def new(host_or_ip, password) do
    client =
      Tesla.client(
        [
          {Tesla.Middleware.BaseUrl, "http://#{host_or_ip}"},
          Tesla.Middleware.DecodeJson,
          {Tesla.Middleware.Headers, [{"X-Api-Key", password}]},
          {Tesla.Middleware.Timeout, timeout: 5_000}
          # {Tesla.Middleware.BasicAuth, %{username: user, password: password}}
        ],
        Tesla.Adapter.Mint
      )

    with {:ok, version_resp} <- Api.api_version(client),
         {:ok, info_resp} <- Api.info(client, 1) do
      {:ok, build_printer(client, version_resp, info_resp)}
    else
      {:error, {:error, :timeout}} ->
        {:not_reachable, struct(__MODULE__, %{client: client, api_version: 1})}

      {:error, error} ->
        {:error, error}
    end
  end

  @doc """
  Retuns the meta information retrieved from the printer when connecting to it the first time.
  """
  @spec specs(%Printer{}) :: map()
  def specs(%__MODULE__{} = printer) do
    printer
    |> Map.from_struct()
    |> Map.drop([:client])
  end

  defp build_printer(client, version_resp, info_resp) do
    fields = %{
      client: client,
      name: version_resp["hostname"],
      # api_version: version_resp["api"],
      api_version: 1,
      capabilities: version_resp["capabilities"],
      nozzle: version_resp["nozzle_diameter"],
      mmu: info_resp["mmu"],
      serial: info_resp["serial"]
    }

    struct(__MODULE__, fields)
  end
end
