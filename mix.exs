defmodule Cowrie.MixProject do
  use Mix.Project

  @version "0.2.0"

  def project do
    [
      app: :cowrie,
      description: "Simple stylable formatting for your CLI, Terminal, or Shell output",
      package: package(),
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        source_ref: "v#{@version}",
        main: "overview",
        logo: "docs/logo.png",
        extras: extras()
      ],
      compilers: [:gettext] ++ Mix.compilers(),
      aliases: aliases()
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
      {:credo, "~> 1.3", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.22", only: [:dev, :test], runtime: false},
      {:gettext, ">= 0.0.0"},
      {:table_rex, "~> 3.0"}
    ]
  end

  defp aliases do
    [
      lint: ["format --check-formatted", "credo --strict"]
    ]
  end
end
