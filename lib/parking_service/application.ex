defmodule ParkingService.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
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
end
