defmodule ParkingService.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    instal_crawler_fuse()

    children = [
      ParkingService.Supervisor,
      ParkingServiceWeb.Supervisor
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    ParkingServiceWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp instal_crawler_fuse() do
    fuse_options = {
      {:standard, 10, 10_000},
      {:reset, :timer.minutes(10)}
    }

    :fuse.install(ParkingService.Crawler, fuse_options)
  end
end
