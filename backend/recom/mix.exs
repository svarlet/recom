defmodule Recom.MixProject do
  use Mix.Project

  def project do
    [
      app: :recom,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Recom.Application, []}
    ]
  end

  defp elixirc_paths(:test), do: ["test/support" | elixirc_paths(:dev)]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:timex, "~> 3.6"},
      {:mox, "~> 0.5.1", only: [:test]},
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:plug_cowboy, "~> 2.0"},
      {:plug, "~> 1.8.2"},
      {:x509, "~> 0.6.0", only: [:dev, :test]},
      {:jason, "~> 1.1"},
      {:dialyxir, "~> 1.0.0-rc.6", only: [:dev], runtime: false},
      {:httpoison, "~> 1.5", only: [:test]},
      {:exceptional, "~> 2.1"}
    ]
  end
end
