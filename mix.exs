defmodule Eliver.Mixfile do
  use Mix.Project

  def project do
    [app: :eliver,
     version: "1.0.4",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     decription: "Interactive semantic versioning for Elixir packages",
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger]]
  end

  def package do
    [
      maintainers: ["Martin Pretorius"],
      licenses:    ["MIT"],
      links:       %{"GitHub" => "https://github.com/glasnoster/eliver"}
    ]
  end

  defp deps do
    []
  end
end
