defmodule Eliver do

  def next_version(version_number, bump_type) do
    [major, minor, patch] = String.split(version_number, ".") |> Enum.map(&String.to_integer/1)
    case bump_type do
      :major -> [major + 1, 0, 0]
      :minor -> [major, minor + 1, 0]
      :patch -> [major, minor, patch + 1]
    end |> Enum.join(".")
  end

end

