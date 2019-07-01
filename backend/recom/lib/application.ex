defmodule Recom.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Recom.Worker.start_link(arg)
      # {Recom.Worker, arg}
      Recom.Repo,
      Plug.Cowboy.child_spec(
        scheme: :https,
        plug: Recom.Api.Router,
        options: [
          port: 4001,
          otp_app: :recom,
          certfile: "priv/cert/selfsigned.pem",
          keyfile: "priv/cert/selfsigned_key.pem"
        ])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Recom.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
