defmodule Mix.Tasks.NpmDeps.Get do
  @moduledoc """
  Fetches the NPM dependencies listed in the mix.exs file
  """

  use Mix.Task

  @impl true
  def run(_args) do
    deps = Keyword.get(Mix.Project.config(), :npm_deps)
    NpmDeps.get(deps)
  end
end
