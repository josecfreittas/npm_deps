defmodule NpmDeps.DownloaderTest do
  use ExUnit.Case, async: false

  import Mock

  alias NpmDeps.Downloader

  describe "get/2" do
    setup do
      with_mock Downloader,
        temp_dir: fn _name -> "/tmp" end,
        fetch_body!: fn _url -> "body" end,
        extract: fn _tar, _tmp_dir -> :ok end,
        copy_to_deps: fn _tmp_dir, _namespace -> :ok end do
        :ok
      end
    end

    test "handles atom namespace" do
      assert {:ok, {"foo", "1.0.0"}} = Downloader.get(:foo, "1.0.0")
    end

    test "handles string namespace" do
      assert {:ok, {"foo", "1.0.0"}} = Downloader.get("foo", "1.0.0")
    end

    test "raises error for invalid HTTP response" do
      with_mock :httpc,
        request: fn _method, _req, _opts, _options ->
          {:ok, {{~c"HTTP/1.1", 404, ~c"Not Found"}, [], "body"}}
        end do
        assert_raise(RuntimeError, ~r/Couldn't fetch/, fn ->
          Downloader.get("foo", "1.0.0")
        end)
      end
    end
  end
end
