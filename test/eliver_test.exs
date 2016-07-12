require IEx
defmodule EliverTest do
  use ExUnit.Case
  doctest Eliver

  describe "getting the next version" do
    test "bumps a patch" do
      assert Eliver.next_version("1.0.1", :patch) == "1.0.2"
    end

    test "bumps a minor version" do
      assert Eliver.next_version("1.0.1", :minor) == "1.1.0"
    end

    test "bumps a major version" do
      assert Eliver.next_version("1.0.1", :major) == "2.0.0"
    end
  end

end
