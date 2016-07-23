defmodule Eliver.Mixfile do
  use Mix.Project

  def project do
    [
      app: :eliver,
      version: "1.1.2",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: "Interactive semantic versioning for Elixir packages",
      deps: deps(),
      package: package()
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp package do
    [
      maintainers: ["Martin Pretorius"],
      licenses:    ["MIT"],
      links:       %{"GitHub" => "https://github.com/glasnoster/eliver"}
    ]
  end

  defp deps do
    [
      {:enquirer, path: "/Users/martin/work/enquirer"}
    ]
  end
end
