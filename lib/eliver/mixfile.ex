defmodule Eliver.MixFile do
  def version_from_mixfile(filename \\ default_mixfile) do
    case File.read(filename) do
      {:ok, body} ->
        (Regex.run(version_regex, body) || []) |> Enum.at(0)
      {:error, _} -> nil
    end
  end

  def bump(new_version, filename \\ default_mixfile) do
    case File.read(filename) do
      {:ok, body} ->
        new_contents  = Regex.replace(version_regex, body, new_version)
        File.write(filename, new_contents)
      {:error, _} -> nil
    end
  end

  defp default_mixfile, do: "mix.exs"

  defp version_regex, do: ~r/(?<=version: ")(.*)(?=")/

end

