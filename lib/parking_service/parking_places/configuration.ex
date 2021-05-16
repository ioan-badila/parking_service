defmodule ParkingService.ParkingPlaces.Configuration do
  @moduledoc false

  alias ParkingService.Resource

  def get_resources() do
    resources = Application.get_env(:parking_service, :resources, [])

    for resource <- resources do
      Resource.new(resource)
    end
  end

  def get_endpoint() do
    Application.get_env(:parking_service, :endpoint_url)
  end
end
