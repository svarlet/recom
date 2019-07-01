use Mix.Config

config :recom, Recom.Repo,
  database: "recom_repo",
  username: "postgres",
  password: "password",
  hostname: "docker",
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false
