defmodule Eliver do

  def main(args) do
    args |> parse_args |> process
  end

  def process([]) do
    IO.puts "No arguments given"
  end

  def process(args) do
    case hd(args) do
      "bump" ->
        new_version = get_new_version
        IO.puts "New version: #{new_version}"

        changelog_entries = get_changelog_entries
        Eliver.MixFile.bump(new_version)
        Eliver.ChangeLogFile.bump(new_version, changelog_entries)
        # if release?
    end
  end

  defp release? do
    release = IO.gets("Release? (Y/n) ") |> remove_trailing_newline
    case release do
      ""  -> true
      "Y" -> true
      "y" -> true
      "n" -> false
      "N" -> false
      _   -> release?
    end
  end

  defp get_new_version do
    Eliver.MixFile.version_from_mixfile |> Eliver.Bump.next_version(get_bump_type)
  end

  defp parse_args(args) do
    {_, args, _} = OptionParser.parse(args)
    args
  end

  defp get_changelog_entries do
    IO.puts("Enter the changes")
    opts = do_get_changelog_entries
  end

  defp do_get_changelog_entries do
    option = IO.gets("* ") |> remove_trailing_newline
    if option != "", do: [option] ++ do_get_changelog_entries, else: []
  end

  defp get_bump_type do
    selected_option = IO.gets("""
    Select release type:
      1. Patch: Bug fixes, recommended for all (default)
      2. Minor: New features, but backwards compatible
      3. Major: Breaking changes
    """) |> remove_trailing_newline

    %{"1" => :patch, "2" => :minor, "3" => :major}[selected_option] || get_bump_type
  end

  defp remove_trailing_newline(str) do
    String.replace_trailing(str, "\n", "")
  end

end

