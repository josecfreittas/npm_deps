defmodule NpmDepsTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO
  import Mock

  alias NpmDeps.Downloader

  describe "get/1" do
    test "it downloads dependencies and prints a message for each one" do
      deps = [{"foo", "1.0.0"}, {:bar, "2.0.0"}]

      with_mock Downloader,
        get: fn namespace, version -> {:ok, {namespace, version}} end do
        output = capture_io(fn -> NpmDeps.get(deps) end)
        assert output =~ "Downloaded foo 1.0.0"
        assert output =~ "Downloaded bar 2.0.0"
      end
    end

    test "it doesn't print anything if no dependencies are provided" do
      with_mock Downloader,
        get: fn _namespace, _version -> {:ok, {nil, nil}} end do
        output = capture_io(fn -> NpmDeps.get([]) end)
        refute output =~ "Downloaded"
      end
    end
  end
end
