defmodule ParkingServiceWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ParkingServiceWeb, :controller

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(ParkingServiceWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, {:not_an_integer, key}}) do
    conn
    |> put_status(400)
    |> put_view(ParkingServiceWeb.ErrorView)
    |> render(:"400", message: "#{key} is invalid")
  end
end
