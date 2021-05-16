defmodule ParkingService.Factories do
  @moduledoc """
  Construction helpers when testing
  """

  alias ParkingService.Resource
  alias ParkingService.ParkingPlaces

  ## Resources
  ##

  def resource(opts \\ []) do
    defaults = [refresh_period: 5]
    opts = Keyword.merge(defaults, opts)
    struct!(Resource, opts)
  end

  def reset_parking_place_store() do
    :ok = Supervisor.terminate_child(ParkingPlaces.Supervisor, ParkingPlaces.Store)
    {:ok, _child} = Supervisor.restart_child(ParkingPlaces.Supervisor, ParkingPlaces.Store)
  end

end
