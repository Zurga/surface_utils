defmodule SurfaceUtils.MixProject do
  use Mix.Project

  def project do
    [
      app: :surface_utils,
      version: "0.1.0",
      description: "Helpers macros and functions that extend the Surface library",
      package: [
        links: %{},
        source_url: "https://github.com/Zurga/surface_utils",
        homepage_url: "https://github.com/Zurga/surface_utils",
        licenses: ["MIT"]
      ],
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      docs: [
        main: "SurfaceUtils"
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
      {:ex_doc, "> 0.0.0", only: [:dev]},
      {:surface, "~> 0.10.0", only: [:dev, :test]}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
