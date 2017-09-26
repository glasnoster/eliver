defmodule Eliver.VersionFile do

  @version_regex ~r/([0-9]+\.[0-9]+\.[0-9]+)/

  def version(filename \\ "VERSION") do
    case File.read(filename) do
      {:ok, body} ->
        (Regex.run(@version_regex, body) || []) |> Enum.at(0)
      {:error, _} -> nil
    end
  end

  def bump(new_version, filename \\ "VERSION") do
    case File.read(filename) do
      {:ok, body} ->
        new_contents  = Regex.replace(@version_regex, body, new_version)
        File.write(filename, new_contents)
      {:error, _} -> nil
    end
  end

end

