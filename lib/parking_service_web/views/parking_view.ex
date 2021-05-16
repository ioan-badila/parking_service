defmodule ParkingServiceWeb.ParkingView do
  @moduledoc false

  use ParkingServiceWeb, :view

  def render("show.json", %{resource: resource}) do
    render_one(resource, __MODULE__, "resource.json", as: :resource)
  end

  def render("resource.json", %{resource: resource}) do
    %{
      total_places: resource.total_places,
      taken_places: resource.taken_places
    }
  end
end
