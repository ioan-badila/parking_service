defmodule ParkingServiceWeb.Router do
  use ParkingServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ParkingServiceWeb do
    pipe_through :api

  end
end
