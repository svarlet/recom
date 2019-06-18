defmodule Api.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Api.Worker.start_link(arg)
      # {Api.Worker, arg}
      Plug.Cowboy.child_spec(
        scheme: :https,
        plug: Api.Router,
        options: [
          port: 4001,
          otp_app: :api,
          certfile: "priv/cert/selfsigned.pem",
          keyfile: "priv/cert/selfsigned_key.pem"
        ])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Api.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
