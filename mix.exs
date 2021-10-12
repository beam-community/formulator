defmodule Formulator.Mixfile do
  use Mix.Project

  @source_url "https://github.com/thoughtbot/formulator"
  @version "0.3.0"

  def project do
    [
      app: :formulator,
      version: @version,
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:gettext, ">= 0.11.0"},
      {:phoenix_html, "~> 2.4 or ~> 3.0"},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
      {:ecto, "~> 2.1", only: :test, optional: true},
      {:phoenix_ecto, "~> 3.2", only: :test, optional: true}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: "#{@version}",
      extras: ["README.md"]
    ]
  end

  defp package do
    [
      description: "A form helper for creating labels and inputs with errors",
      maintainers: ["Jason Draper", "Ashley Ellis", "Josh Steiner"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Made by thoughtbot" => "https://thoughtbot.com/services/elixir-phoenix"
      }
    ]
  end
end
