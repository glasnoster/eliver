require IEx
defmodule Eliver.ChangeLogFile do
  def bump(new_version, changelog_entries, filename \\ default_changelog_file) do
    case File.read(filename) do
      {:ok, body} ->
        bump_entry = make_bump_entry(new_version, changelog_entries)
        new_body = String.replace(body, "# Changelog\n", bump_entry)
        File.write(filename, new_body)
      {:error, reason} -> nil
    end
  end

  defp make_bump_entry(new_version, changelog_entries) do
    """
    # Changelog

    # #{new_version}
    #{Enum.map(changelog_entries, fn(x) -> "* " <> x end) |> Enum.join("\n")}
    """
  end

  defp default_changelog_file, do: "CHANGELOG.md"

end