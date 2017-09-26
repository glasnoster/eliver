defmodule Eliver.VersionFileTest do
  use ExUnit.Case
  doctest Eliver

  setup do
    File.copy("test/support/test_with_version_template", "test/support/test_with_version")
    File.copy("test/support/test_without_version_template", "test/support/test_without_version")

    on_exit fn ->
      File.rm("test/support/test_with_version")
      File.rm("test/support/test_without_version")
    end
    :ok
  end

  describe "getting the current version number" do
    test "it gets the version number when the version file exists" do
      assert Eliver.VersionFile.version("test/support/test_with_version") == "1.1.0"
    end

    test "it returns nil when the file does not exist" do
      assert Eliver.VersionFile.version("foo.exs") == nil
    end

    test "it returns nil if the version is not specified in the version file" do
      assert Eliver.VersionFile.version("test/support/test_without_version") == nil
    end
  end

  describe "bumping the mixfile" do
    def versionfile_contents do
      case File.read("test/support/test_with_version") do
        {:ok, body} ->
          body
        {:error, _} -> nil
      end
    end

    def expected_versionfile_contents do
      """
      2.0.0
      """
    end

    test "it updates the mixfile" do
      Eliver.VersionFile.bump("2.0.0", "test/support/test_with_version")
      assert versionfile_contents() == expected_versionfile_contents()
    end

  end

end
