defmodule NpmDeps.MixProject do
  use Mix.Project

  @version "0.3.3"
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

  def application do
    [
      extra_applications: [:inets, :ssl]
    ]
  end

  defp deps do
    [
      {:castore, ">= 0.0.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:mock, "~> 0.3.7", only: :test}
    ]
  end
end
