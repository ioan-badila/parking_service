defmodule ParkingService.ParkingPlaces.Supervisor do
  @moduledoc false

  use Supervisor

  alias ParkingService.ParkingPlaces.Store

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      Store,
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
