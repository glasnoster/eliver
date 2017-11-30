defmodule Mix.Tasks.Eliver.Bump do
  use Mix.Task
  import Enquirer

  def run(args) do
    args |> parse_args |> bump
  end

  defp bump(_) do
    case check_for_git_problems() do
      {:error, message} ->
        say message, :red
      {:ok} ->
        {new_version, changelog_entries} = get_changes()
        if allow_changes?(new_version, changelog_entries) do
          make_changes(new_version, changelog_entries)
        end
    end
  end

  defp get_changes do
    {get_new_version(), get_changelog_entries()}
  end

  defp allow_changes?(new_version, changelog_entries) do
    current_version = Eliver.VersionFile.version
    say "\n"
    say "Summary of changes:"
    say "Bumping version #{current_version} → #{new_version}", :green
    say ("#{Enum.map(changelog_entries, fn(x) -> "* " <> x end) |> Enum.join("\n")}"), :green
    say "\n"
    result = ask "Continue?", false
    case result do
      {:ok, value} -> value
      {:error, _}  -> false
    end
  end

  defp make_changes(new_version, changelog_entries) do
    Eliver.VersionFile.bump(new_version)
    Eliver.ChangeLogFile.bump(new_version, changelog_entries)
    Eliver.Git.commit!(new_version, changelog_entries)
    say "Pushing to origin..."
    Eliver.Git.push!(new_version)
  end

  defp check_for_git_problems do
    cond do
      !Eliver.Git.is_tracking_branch? ->
        {:error, "This branch is not tracking a remote branch. Aborting..."}
      !Eliver.Git.on_master? && !continue_on_branch?() ->
        {:error, "Aborting"}
      Eliver.Git.index_dirty? ->
        {:error, "Git index dirty. Commit changes before continuing"}
      Eliver.Git.fetch! && Eliver.Git.upstream_changes? ->
        {:error, "This branch is not up to date with upstream"}
      true ->
        {:ok}
    end
  end

  defp continue_on_branch? do
    question = "You are not on master. It is not recommended to create releases from a branch unless they're maintenance releases. Continue?"
    result = ask question, false
    case result do
      {:ok, value} -> value
      {:error, _}  -> continue_on_branch?()
    end
  end

  defp get_new_version do
    Eliver.VersionFile.version |> Eliver.next_version(get_bump_type())
  end

  defp get_changelog_entries do
    {:ok, result} = get_list "Enter the changes, enter a blank line when you're done"
    result
  end

  defp get_bump_type do
    result = choose "Select release type",
      patch:   "Bug fixes, recommended for all",
      minor:   "New features, but backwards compatible",
      major:   "Breaking changes",
      default: :patch

    case result do
      {:ok, value} -> value
      {:error, _}  -> get_bump_type()
    end
  end

  defp parse_args(args) do
    {_, args, _} = OptionParser.parse(args)
    args
  end
end
