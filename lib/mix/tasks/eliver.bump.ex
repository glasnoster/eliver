defmodule Mix.Tasks.Eliver.Bump do
  use Mix.Task

  def run(args) do
    args |> parse_args |> bump
  end

  defp bump(_) do
    git_fail = cond do
      !Eliver.Git.is_tracking_branch? ->
        IO.puts "This branch is not tracking a remote branch. Aborting..."
      !Eliver.Git.on_master? && !continue_on_branch? ->
        IO.puts "Aborting..."
      Eliver.Git.index_dirty? ->
        IO.puts "Git index dirty. Commit changes before continuing"
      Eliver.Git.fetch! && Eliver.Git.upstream_changes? ->
        IO.puts "This branch is not up to date with upstream"
      true ->
        false
    end

    unless git_fail do
      new_version = get_new_version
      IO.puts "New version: #{new_version}"

      changelog_entries = get_changelog_entries
      Eliver.MixFile.bump(new_version)
      Eliver.ChangeLogFile.bump(new_version, changelog_entries)

      Eliver.Git.commit!(new_version, changelog_entries)

      IO.puts "Pushing to origin..."
      Eliver.Git.push!(new_version)
    end
  end

  defp continue_on_branch? do
    ask "You are not on master. It is not recommended to create releases from a branch unless they're maintenance releases. Continue? (Y/n) "
  end

  defp ask(question) do
    result = IO.gets(question) |> remove_trailing_newline
    case result do
      ""  -> true
      "Y" -> true
      "y" -> true
      "n" -> false
      "N" -> false
      _   -> ask(question)
    end
  end

  defp get_new_version do
    Eliver.MixFile.version_from_mixfile |> Eliver.next_version(get_bump_type)
  end

  defp get_changelog_entries do
    IO.puts("Enter the changes")
    do_get_changelog_entries
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

  defp parse_args(args) do
    {_, args, _} = OptionParser.parse(args)
    args
  end
end