defmodule Recom.Repo do
  use Ecto.Repo,
    otp_app: :recom,
    adapter: Ecto.Adapters.Postgres
end
