defmodule Cowrie.MixProject do
  use Mix.Project

  @version "0.4.0"

  def project do
    [
      aliases: aliases(),
      app: :cowrie,
      description: "Simple stylable formatting for your CLI, Terminal, or Shell output",
      package: package(),
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        plt_add_apps: [:mix]
      ],
      docs: [
        source_ref: "v#{@version}",
        main: "overview",
        logo: "docs/logo.png",
        extras: extras()
      ]
    ]
  end

  defp package do
    [
      maintainers: ["Everett Griffiths"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/fireproofsocks/cowrie"}
    ]
  end

  # Extra pages for the docs
  def extras do
    [
      "docs/overview.md",
      "docs/config.md"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.5", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.36", only: [:dev, :test], runtime: false},
      {:gettext, "~> 0.26.2"},
      {:table_rex, "~> 4.0"}
    ]
  end

  defp aliases do
    [
      lint: ["format --check-formatted", "credo --strict"]
    ]
  end
end
