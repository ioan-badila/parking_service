defmodule ParkingServiceWeb.Supervisor do
  @moduledoc false

  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    [
      ParkingServiceWeb.Telemetry,
      {Phoenix.PubSub, name: ParkingService.PubSub},
      ParkingServiceWeb.Endpoint
    ]
    |> Supervisor.init(strategy: :one_for_one)
  end
end
