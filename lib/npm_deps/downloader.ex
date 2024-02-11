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
    with package_path <- Path.join(Mix.Project.deps_path(), "#{namespace}"),
         :ok <- File.mkdir_p(Path.dirname(package_path)),
         {:ok, _binary} <- File.cp_r(Path.join(tmp_dir, "package"), package_path) do
      :ok
    end
  end

  def extract(tar, tmp_dir),
    do: :erl_tar.extract({:binary, tar}, [:compressed, cwd: to_charlist(tmp_dir)])

  def fetch_body!(url) do
    scheme = URI.parse(url).scheme

    ensure_required_apps()
    set_http_or_https_proxy(scheme)

    http_options = http_options(scheme)

    url = String.to_charlist(url)

    case :httpc.request(:get, {url, []}, http_options, body_format: :binary) do
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

  defp set_http_or_https_proxy(scheme) do
    if proxy = proxy_for_scheme(scheme) do
      %{host: host, port: port} = URI.parse(proxy)
      IO.puts("Using #{String.upcase(scheme)}_PROXY: #{proxy}")
      set_option = if "https" == scheme, do: :https_proxy, else: :proxy
      :httpc.set_options([{set_option, {{String.to_charlist(host), port}, []}}])
    end
  end

  defp proxy_for_scheme("http"),
    do: System.get_env("HTTP_PROXY") || System.get_env("http_proxy")

  defp proxy_for_scheme("https"),
    do: System.get_env("HTTPS_PROXY") || System.get_env("https_proxy")

  defp http_options(scheme) do
    maybe_add_proxy_auth(
      [
        ssl: [
          verify: :verify_peer,
          cacertfile: String.to_charlist(CAStore.file_path()),
          depth: 2,
          customize_hostname_check: [
            match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
          ],
          versions: protocol_versions()
        ]
      ],
      scheme
    )
  end

  defp maybe_add_proxy_auth(http_options, scheme) do
    case proxy_auth(scheme) do
      nil -> http_options
      auth -> [{:proxy_auth, auth} | http_options]
    end
  end

  defp proxy_auth(scheme) do
    with proxy when is_binary(proxy) <- proxy_for_scheme(scheme),
         %{userinfo: userinfo} when is_binary(userinfo) <- URI.parse(proxy),
         [username, password] <- String.split(userinfo, ":") do
      {String.to_charlist(username), String.to_charlist(password)}
    else
      _ -> nil
    end
  end

  defp protocol_versions do
    if otp_version() < 25,
      do: [:"tlsv1.2"],
      else: [:"tlsv1.2", :"tlsv1.3"]
  end

  defp otp_version, do: :erlang.system_info(:otp_release) |> List.to_integer()
end
