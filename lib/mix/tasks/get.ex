defmodule Mix.Tasks.NpmDeps.Get do
  @moduledoc """
  Fetches the NPM dependencies listed in the mix.exs file
  """

  use Mix.Task

  @impl true
  def run(_args) do
    case Keyword.get(Mix.Project.config(), :npm_deps) do
      nil ->
        IO.puts("""
        The key :npm_deps was not found in the project.

        You can go to your mix.exs file and add the following line inside your project/0 function:

        npm_deps: npm_deps()


        then add the following function to your mix.exs file:

        def npm_deps do
          [
            {:alpinejs, "3.10.4"}
          ]
        end

        alpinejs is a example dependency. You can add as many dependencies as you want.
        """)

      [] ->
        IO.puts("No NPM dependencies found to be fetched.")

      deps ->
        NpmDeps.get(deps)
    end
  end
end
