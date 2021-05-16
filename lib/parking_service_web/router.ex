defmodule ParkingServiceWeb.Router do
  use ParkingServiceWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ParkingServiceWeb do
    pipe_through :api

    get "/parkings/:resource_id", ParkingController, :show
    post "/crawlers/:resource_id", ParkingController, :update_refresh_period
  end
end
