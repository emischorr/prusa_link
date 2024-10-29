# PrusaLink

A wrapper around the local PrusaLink API of a supported Prusa 3D printer (MK4/S, MK3.9/S, MK3.5/S, XL, MINI / MINI +, SL1, SL1S SPEED).
For further instructions how to setup PrusaLink (and obtain IP and password) have a look at the official [Guide](https://help.prusa3d.com/guide/wi-fi-and-prusalink-setup-mk4-mk3-9-mk3-5-xl-mini_413293) from Prusa.

Currently supports:
- status info
- job info
- start print job
- stop, pause, continue a job
- retrieve storage info
- file and directory listing
- file upload (since v0.1.1)

## Usage

```elixir
{:ok, mk4} = PrusaLink.printer("192.168.10.10", "your_password")

PrusaLink.specs(mk4)
> %{
    name: "prusa-mk4",
    serial: "10000-1111444433332222",
    api_version: 1,
    capabilities: %{"upload-by-put" => true},
    mmu: false,
    nozzle: 0.4
  }

PrusaLink.status(mk4)
> {:ok,
    %{
      "printer" => %{
        "axis_x" => 241.0,
        "axis_y" => 170.0,
        "axis_z" => 61.5,
        "fan_hotend" => 0,
        "fan_print" => 0,
        "flow" => 100,
        "speed" => 100,
        "state" => "FINISHED",
        "target_bed" => 0.0,
        "target_nozzle" => 0.0,
        "temp_bed" => 23.9,
        "temp_nozzle" => 25.0
      },
      "storage" => %{"name" => "usb", "path" => "/usb/", "read_only" => false}
  }}
```

## Installation

The package can be installed by adding `prusa_link` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:prusa_link, "~> 0.1.1"}
  ]
end
```

Documentation can be found at <https://hexdocs.pm/prusa_link>.

