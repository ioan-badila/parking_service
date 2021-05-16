# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :parking_service, ParkingServiceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Clc8DcngywKJGoo+zaQ5ZriXcqlRdCDpDLvDAPKwxyzLjeTCw/qLCzGFhkjavn8w",
  render_errors: [view: ParkingServiceWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: ParkingService.PubSub,
  live_view: [signing_salt: "xezUoe/7"]

config :parking_service,
  endpoint_url: "http://private-b2c96-mojeprahaapi.apiary-mock.com/pr-parkings/",
  resources: [
    %{id: 534_001, refresh_period: 1},
    %{id: 534_002, refresh_period: 4},
    %{id: 534_003, refresh_period: 5},
    %{id: 534_004, refresh_period: 6},
    %{id: 534_005, refresh_period: 5},
    %{id: 534_013, refresh_period: 5},
    %{id: 534_007, refresh_period: 6}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
