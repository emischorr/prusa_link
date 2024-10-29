defmodule PrusaLink do
  @moduledoc """
  PrusaLink module to interface with a Prusa 3D printer via local PrusaLink.
  To start setup a printer by calling `PrusaLink.printer(host_or_ip, pw)`.
  The result is a printer struct you can pass to any other method to interact with that printer.
  """
  alias PrusaLink.Printer
  alias PrusaLink.Api

  defdelegate printer(host_or_ip, pw), to: Printer, as: :new
  defdelegate specs(printer), to: Printer
  defdelegate status(printer), to: Api
  defdelegate job(printer), to: Api
  defdelegate job_stop(printer, job_id), to: Api
  defdelegate job_pause(printer, job_id), to: Api
  defdelegate job_resume(printer, job_id), to: Api
  defdelegate storage(printer), to: Api
  defdelegate files(printer, storage, path), to: Api
  def files(printer, path \\ "/"), do: files(printer, "usb", path)
  defdelegate print(printer, storage, path), to: Api
  @doc since: "0.1.1"
  defdelegate upload(printer, storage, path, content), to: Api
  @doc since: "0.1.1"
  def upload(printer, path, content), do: upload(printer, "usb", path, content)

  @doc """
  Upload a file to the given printer.

  Automatically extracts the target filename on the printer from the given path.
  Uploads to usb storage.
  See also: `PrusaLink.Api.upload/4`
  """
  @doc since: "0.1.1"
  def upload(printer, file) do
    case File.read(file) do
      {:ok, content} -> upload(printer, Path.basename(file), content)
      {:error, :enoent} -> {:error, :file_not_found}
      error -> {:error, error}
    end
  end
end
