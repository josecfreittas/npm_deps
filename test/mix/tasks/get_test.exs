defmodule Mix.Tasks.NpmDeps.GetTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog
  import Mock

  describe "run/1" do
    test "it prints and error if the project is not properly configured" do
      with_mock Mix.Project, config: fn -> [] end do
        assert capture_log(fn ->
                 Mix.Tasks.NpmDeps.Get.run([])
               end) =~ "The key :npm_deps was not found in the project."
      end
    end

    test "it prints an alert if no dependencies are found" do
      with_mock Mix.Project, config: fn -> [npm_deps: []] end do
        assert capture_log(fn ->
                 Mix.Tasks.NpmDeps.Get.run([])
               end) =~ "No NPM dependencies found to be fetched."
      end
    end

    test "it calls NpmDeps.get with the dependencies" do
      with_mock Mix.Project, config: fn -> [npm_deps: [{:alpinejs, "3.10.4"}]] end do
        with_mock NpmDeps, get: fn deps -> deps end do
          assert Mix.Tasks.NpmDeps.Get.run([]) == [{:alpinejs, "3.10.4"}]
        end
      end
    end
  end
end
