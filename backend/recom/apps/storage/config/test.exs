use Mix.Config

config :storage, Storage.Repo,
  database: "storage_repo",
  username: "postgres",
  password: "password",
  hostname: "docker",
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false
