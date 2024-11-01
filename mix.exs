defmodule PrusaLink.MixProject do
  use Mix.Project

  def project do
    [
      app: :prusa_link,
      version: "0.2.0",
      name: "PrusaLink",
      description: "A wrapper for the local PrusaLink printer API",
      source_url: "https://github.com/emischorr/prusa_link",
      homepage_url: "https://github.com/emischorr/prusa_link",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      package: package(),
      docs: [
        # The main page in the docs
        main: "PrusaLink",
        # logo: "path/to/logo.png",
        extras: ["README.md"]
      ]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tesla, "~> 1.13"},
      {:jason, ">= 1.4.0"},
      {:mint, "~> 1.6"},
      {:castore, "~> 1.0"},
      {:bypass, "~> 2.1", only: :test},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp package() do
    [
      name: "prusa_link",
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/emischorr/prusa_link"}
    ]
  end
end
