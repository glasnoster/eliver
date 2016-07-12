require IEx
defmodule Eliver.ChangeLogFile do
  def bump(new_version, changelog_entries, filename \\ "CHANGELOG.md") do
    bump_entry = make_bump_entry(new_version, changelog_entries)
    new_body = case File.read(filename) do
      {:ok, body} ->
        Regex.replace(~r/\# changelog\n/i, body, bump_entry)
      {:error, _} ->
        bump_entry
    end
    File.write(filename, new_body)
  end

  defp make_bump_entry(new_version, changelog_entries) do
    """
    # Changelog

    # #{new_version}
    #{Enum.map(changelog_entries, fn(x) -> "* " <> x end) |> Enum.join("\n")}
    """
  end

end