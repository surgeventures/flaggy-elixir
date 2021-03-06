defmodule Flaggy.Mixfile do
  use Mix.Project

  def project do
    [
      app: :flaggy,
      version: "0.1.0",
      elixir: "~> 1.5",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Flaggy, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:credo, "~> 0.8", only: [:dev, :test]},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:excoveralls, "~> 0.7", only: :test},
      {:junit_formatter, "~> 2.1", only: :test},
      {:protein, "~> 0.10", optional: true},
      {:recon, "~> 2.3", optional: true},
      {:poison, ">= 1.0.0"}
    ]
  end
end
