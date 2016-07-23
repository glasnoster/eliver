defmodule Mix.Tasks.Eliver.Bump do
  use Mix.Task
  import Enquirer

  def run(args) do
    args |> parse_args |> bump
  end

  defp bump(_) do
    git_fail = cond do
      !Eliver.Git.is_tracking_branch? ->
        say "This branch is not tracking a remote branch. Aborting...", :red
      !Eliver.Git.on_master? && !continue_on_branch? ->
        say "Aborting...", :red
      Eliver.Git.index_dirty? ->
        say "Git index dirty. Commit changes before continuing", :red
      Eliver.Git.fetch! && Eliver.Git.upstream_changes? ->
        say "This branch is not up to date with upstream", :red
      true ->
        false
    end

    unless git_fail do
      new_version = get_new_version
      say "New version: #{new_version}", :green

      changelog_entries = get_changelog_entries
      Eliver.MixFile.bump(new_version)
      Eliver.ChangeLogFile.bump(new_version, changelog_entries)

      Eliver.Git.commit!(new_version, changelog_entries)

      say "Pushing to origin..."
      Eliver.Git.push!(new_version)
    end
  end

  defp continue_on_branch? do
    question = "You are not on master. It is not recommended to create releases from a branch unless they're maintenance releases. Continue?"
    result = ask question, false
    case result do
      {:ok, value} -> value
      {:error, _}  -> continue_on_branch?
    end
  end

  defp get_new_version do
    Eliver.MixFile.version_from_mixfile |> Eliver.next_version(get_bump_type)
  end

  defp get_changelog_entries do
    {:ok, result} = get_list "Enter the changes"
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
      {:error, _}  -> get_bump_type
    end
  end

  defp parse_args(args) do
    {_, args, _} = OptionParser.parse(args)
    args
  end
end