defmodule EliverTest do
  use ExUnit.Case
  doctest Eliver

  describe "getting the current version number" do
    test "it gets the version number when the mix file exixts" do
      assert Eliver.MixFile.version_from_mixfile("test/support/test_with_version.exs") == "1.1.0"
    end

    test "it returns nil when the file does not exist" do
      assert Eliver.MixFile.version_from_mixfile("foo.exs") == nil
    end

    test "it returns nil if the version is not specified in the mix file" do
      assert Eliver.MixFile.version_from_mixfile("test/support/test_without_version.exs") == nil
    end
  end

  describe "bumping the version" do
    test "bumps a patch" do
      assert Eliver.Bump.next_version("1.0.1", :patch) == "1.0.2"
    end

    test "bumps a minor version" do
      assert Eliver.Bump.next_version("1.0.1", :minor) == "1.1.0"
    end

    test "bumps a major version" do
      assert Eliver.Bump.next_version("1.0.1", :major) == "2.0.0"
    end
  end

end
