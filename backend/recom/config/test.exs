use Mix.Config

# Configure your database
config :recom, Recom.Repo,
  username: "postgres",
  password: "password",
  database: "recom_test",
  hostname: "postgres",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :recom, RecomWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
