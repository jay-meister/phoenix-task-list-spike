# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :spike,
  ecto_repos: [Spike.Repo]

# Configures the endpoint
config :spike, Spike.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "2X8N3WOzswiBUvEdW5ZX4kjEDlbSJ63blEs3jUiSiwIwb4B8KHawrT1dM5I0LhGi",
  render_errors: [view: Spike.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Spike.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
