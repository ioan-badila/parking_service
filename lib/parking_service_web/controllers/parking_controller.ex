defmodule ParkingServiceWeb.ParkingController do
  @moduledoc false

  use ParkingServiceWeb, :controller

  alias ParkingService.ParkingPlaces

  action_fallback ParkingServiceWeb.FallbackController

  def show(conn, %{"resource_id" => resource_id}) do
    with {:ok, resource_id} <- cast_int("id", resource_id),
         {:ok, resource} <- ParkingPlaces.get_resource(resource_id) do
      render(conn, "show.json", resource: resource)
    end
  end

  def update_refresh_period(conn, %{"resource_id" => resource_id, "refresh_period" => new_period}) do
    with {:ok, resource_id} <- cast_int("id", resource_id),
         {:ok, new_period} <- cast_int("refresh_period", new_period),
         {:ok, resource} <- ParkingPlaces.get_resource(resource_id),
         :ok <- ParkingPlaces.update_refresh_period(resource, new_period) do
      send_resp(conn, 200, "OK")
    end
  end

  defp cast_int(_key, value) when is_integer(value), do: {:ok, value}

  defp cast_int(key, value) do
    case Integer.parse(value) do
      {parsed, _} -> {:ok, parsed}
      _ -> {:error, {:not_an_integer, key}}
    end
  end
end
