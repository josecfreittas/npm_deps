defmodule NpmDeps.MixProject do
  use Mix.Project

  @version "0.2.0"
  @source_url "https://github.com/josecfreittas/npm_deps"

  def project do
    [
      app: :npm_deps,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "NpmDeps",
      source_url: @source_url,
      description:
        "A tool to help you manage your NPM dependencies in Elixir projects. Without Node.js or NPM.",
      package: [
        links: %{"GitHub" => @source_url},
        licenses: ["MIT"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:castore, ">= 0.0.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end
end
