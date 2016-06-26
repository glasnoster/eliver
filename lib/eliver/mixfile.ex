defmodule Eliver.MixFile do
  def version_from_mixfile(filename \\ default_mixfile) do
    case File.read(filename) do
      {:ok, body} ->
        (Regex.run(version_regex, body) || []) |> Enum.at(0)
      {:error, reason} -> nil
    end
  end

  defp default_mixfile, do: "mix.exs"

  defp version_regex, do: ~r/(?<=version: ")(.*)(?=")/

end

