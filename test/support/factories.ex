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

  def becomes_true(timeout, _predicate) when timeout < 0, do: false

  def becomes_true(timeout, predicate) do
    case predicate.() do
      true ->
        true

      false ->
        Process.sleep(10)
        becomes_true(timeout - 10, predicate)
    end
  end
end
