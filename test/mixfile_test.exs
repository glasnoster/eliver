defmodule Eliver.MixFileTest do
  use ExUnit.Case
  doctest Eliver

  setup do
    File.copy("test/support/test_with_version_template.exs", "test/support/test_with_version.exs")
    File.copy("test/support/test_without_version_template.exs", "test/support/test_without_version.exs")

    on_exit fn ->
      File.rm("test/support/test_with_version.exs")
      File.rm("test/support/test_without_version.exs")
    end
    :ok
  end

  describe "getting the current version number" do
    test "it gets the version number when the mix file exists" do
      assert Eliver.MixFile.version("test/support/test_with_version.exs") == "1.1.0"
    end

    test "it returns nil when the file does not exist" do
      assert Eliver.MixFile.version("foo.exs") == nil
    end

    test "it returns nil if the version is not specified in the mix file" do
      assert Eliver.MixFile.version("test/support/test_without_version.exs") == nil
    end
  end

  describe "bumping the mixfile" do
    def mixfile_contents do
      case File.read("test/support/test_with_version.exs") do
        {:ok, body} ->
          body
        {:error, _} -> nil
      end
    end

    def expected_mixfile_contents do
      """
      2.0.0
      """
    end

    test "it updates the mixfile" do
      Eliver.MixFile.bump("2.0.0", "test/support/test_with_version.exs")
      assert mixfile_contents() == expected_mixfile_contents()
    end

  end

end