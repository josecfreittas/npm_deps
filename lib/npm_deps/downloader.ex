defmodule NpmDeps.Downloader do
  @moduledoc """
  This module is responsible for downloading the NPM packages.
  """

  @registry "https://registry.npmjs.org"

  def get(namespace, version) when is_atom(namespace),
    do: get(to_string(namespace), version)

  def get(namespace, version) do
    name = namespace |> String.split("/") |> List.last()
    tmp_dir = temp_dir(name)

    with tar <- fetch_body!("#{@registry}/#{namespace}/-/#{name}-#{version}.tgz"),
         :ok <- extract(tar, tmp_dir),
         :ok <- copy_to_deps(tmp_dir, namespace) do
      {:ok, {namespace, version}}
    end
  end

  def copy_to_deps(tmp_dir, namespace) do
    with package_path <- Path.expand("deps/#{namespace}"),
         :ok <- File.mkdir_p(Path.dirname(package_path)),
         {:ok, _binary} <- File.cp_r(Path.join(tmp_dir, "package"), package_path) do
      :ok
    end
  end

  def extract(tar, tmp_dir),
    do: :erl_tar.extract({:binary, tar}, [:compressed, cwd: to_charlist(tmp_dir)])

  def fetch_body!(url) do
    ensure_required_apps()
    set_http_and_https_proxies()

    url = String.to_charlist(url)

    case :httpc.request(:get, {url, []}, http_options(), body_format: :binary) do
      {:ok, {{_, 200, _}, _headers, body}} -> body
      error -> raise "Couldn't fetch #{url}: #{inspect(error)}"
    end
  end

  def temp_dir(name) do
    tmp_opts = if System.get_env("MIX_XDG"), do: %{os: :linux}, else: %{}

    freshdir_path(name, :filename.basedir(:user_cache, "npm_deps", tmp_opts)) ||
      freshdir_path(name, Path.join(System.tmp_dir!(), "npm_deps")) ||
      raise "Could not install package. Set MIX_XGD=1 and then set XDG_CACHE_HOME to the path you want to use as cache"
  end

  defp freshdir_path(name, path) do
    with path <- Path.join(path, name),
         {:ok, _} <- File.rm_rf(path),
         :ok <- File.mkdir_p(path) do
      path
    else
      _ -> nil
    end
  end

  defp ensure_required_apps() do
    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)
  end

  defp set_http_and_https_proxies() do
    if proxy = System.get_env("HTTP_PROXY") || System.get_env("http_proxy"),
      do: :httpc.set_options([{:proxy, httpc_proxy(proxy)}])

    if proxy = System.get_env("HTTPS_PROXY") || System.get_env("https_proxy"),
      do: :httpc.set_options([{:https_proxy, httpc_proxy(proxy)}])
  end

  defp httpc_proxy(proxy) do
    %{host: host, userinfo: userinfo, port: port} = URI.parse(proxy)
    authority = if userinfo, do: "#{userinfo}@#{host}", else: host
    {{String.to_charlist(authority), port}, []}
  end

  defp http_options() do
    [
      ssl: [
        verify: :verify_peer,
        cacertfile: String.to_charlist(CAStore.file_path()),
        depth: 2,
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ]
    ]
  end
end
