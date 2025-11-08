defmodule Pathfinding.MixProject do
  use Mix.Project

  def project do
    [
      app: :pathfinding,
      version: "4.14.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: "Pathfinding, flow, and graph algorithms",
      package: package(),
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["Apache-2.0", "MIT"],
      links: %{
        "GitHub" => "https://github.com/evenfurther/pathfinding",
        "Homepage" => "https://rfc1149.net/devel/pathfinding.html"
      }
    ]
  end

  defp docs do
    [
      main: "Pathfinding",
      extras: ["README.md", "GRAPH_GUIDE.md", "CHANGELOG.md"]
    ]
  end
end
