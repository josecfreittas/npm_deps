defmodule NpmDeps do
  @external_resource "README.md"
  @moduledoc "README.md"
             |> File.read!()
             |> String.split("<!-- MDOC !-->")
             |> Enum.fetch!(1)

  require Logger

  def get(deps) do
    Logger.info("Downloading NPM packages...")

    deps
    |> Task.async_stream(fn {name, version} -> get(name, version) end, timeout: 60_000)
    |> Enum.each(fn {:ok, {:ok, {name, version}}} ->
      Logger.info("Downloaded #{name} #{version}")
    end)
  end

  def get(name, version) when is_atom(name), do: get(to_string(name), version)

  def get(name, version) do
    tmp_opts = if System.get_env("MIX_XDG"), do: %{os: :linux}, else: %{}

    tmp_dir =
      freshdir_path(:filename.basedir(:user_cache, "npm-pkgs", tmp_opts)) ||
        freshdir_path(Path.join(System.tmp_dir!(), "npm-pkgs")) ||
        raise "could not install package. Set MIX_XGD=1 and then set XDG_CACHE_HOME to the path you want to use as cache"

    with tar <- fetch_body!("https://registry.npmjs.org/#{name}/-/#{name}-#{version}.tgz"),
         :ok <- :erl_tar.extract({:binary, tar}, [:compressed, cwd: to_charlist(tmp_dir)]),
         package_path <- package_path(name),
         :ok <- File.mkdir_p(Path.dirname(package_path)),
         {:ok, _binary} <- File.cp_r(Path.join(tmp_dir, "package"), package_path) do
      {:ok, {name, version}}
    end
  end

  defp freshdir_path(path) do
    with {:ok, _} <- File.rm_rf(path),
         :ok <- File.mkdir_p(path) do
      path
    else
      _ -> nil
    end
  end

  defp fetch_body!(url) do
    url = String.to_charlist(url)

    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)

    if proxy = System.get_env("HTTP_PROXY") || System.get_env("http_proxy") do
      Logger.debug("Using HTTP_PROXY: #{proxy}")
      :httpc.set_options([{:proxy, httpc_proxy(proxy)}])
    end

    if proxy = System.get_env("HTTPS_PROXY") || System.get_env("https_proxy") do
      Logger.debug("Using HTTPS_PROXY: #{proxy}")
      :httpc.set_options([{:https_proxy, httpc_proxy(proxy)}])
    end

    # https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/inets
    cacertfile = String.to_charlist(CAStore.file_path())

    http_options = [
      ssl: [
        verify: :verify_peer,
        cacertfile: cacertfile,
        depth: 2,
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ]
    ]

    options = [body_format: :binary]

    case :httpc.request(:get, {url, []}, http_options, options) do
      {:ok, {{_, 200, _}, _headers, body}} ->
        body

      other ->
        raise "couldn't fetch #{url}: #{inspect(other)}"
    end
  end

  defp httpc_proxy(proxy) do
    %{host: host, userinfo: userinfo, port: port} = URI.parse(proxy)
    authority = if userinfo, do: "#{userinfo}@#{host}", else: host
    {{String.to_charlist(authority), port}, []}
  end

  @doc """
  Returns the path to the package.
  The package may not be available if it was not yet installed.
  """
  def package_path(name), do: Path.expand("deps/#{name}")
end
