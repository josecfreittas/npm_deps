defmodule NpmDeps do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  alias NpmDeps.Downloader

  def get(deps) do
    IO.puts("Downloading NPM packages...")

    deps
    |> Task.async_stream(
      fn {namespace, version} -> Downloader.get(namespace, version) end,
      timeout: 60_000
    )
    |> Enum.each(fn {:ok, {:ok, {namespace, version}}} ->
      IO.puts("Downloaded #{namespace} #{version}")
    end)
  end
end
