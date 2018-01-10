defmodule Flaggy.Mixfile do
  use Mix.Project

  def project do
    [
      app: :flaggy,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Flaggy, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:protein, "~> 0.9.0", optional: true},
      {:yaml_elixir, "~> 1.3.1"}
    ]
  end
end
