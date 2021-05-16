defmodule ParkingService.Supervisor do
  @moduledoc false

  use Supervisor

  alias ParkingService.ParkingPlaces

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      ParkingPlaces.Supervisor,
      ParkingService.Crawler
    ]

    Supervisor.init(children, strategy: :rest_for_one)
  end
end
