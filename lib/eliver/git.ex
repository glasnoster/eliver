defmodule Eliver.Git do
  def index_dirty? do
    git_status = git "status", "--porcelain"
    case git_status do
      {:ok, value} -> Regex.match?(~r/^\s*(D|M|A|R|C)\s/, value)
      {:error, _}  -> false
    end
  end

  def upstream_changes? do
    count = git "rev-list", ["HEAD..@{u}", "--count"]
    case count do
      {:ok, count} -> count == "0"
      {:error, _}  -> true
    end
  end

  def is_tracking_branch? do
    tracking_check = git("rev-list", ["HEAD..@{u}", "--count"]) |> elem(0)
    tracking_check == :ok
  end

  def current_branch do
    git("symbolic-ref", ["--short", "HEAD"])
    |> elem(1)
    |> remove_trailing_newline
  end

  def on_master? do
    current_branch() == "master"
  end

  def fetch! do
    git "fetch", "-q"
  end

  def commit!(new_version, changelog_entries) do
    git "add", "CHANGELOG.md"
    git "add", "VERSION"
    git "commit", ["-m", commit_message(new_version, changelog_entries)]
    git "tag", ["#{new_version}", "-a", "-m", "Version: #{new_version}"]
  end

  def commit!(commit_changes) do
    for change <- commit_changes do
      git "add", "#{elem(change, 1)}/CHANGELOG.md"
      git "add", "#{elem(change, 1)}/VERSION"
    end

    umbrella_changes = Enum.find(commit_changes,
      fn({app, app_path, current_version, new_version, changelog_entries}) ->
        app == :umbrella
      end
    )
    app_changes = List.delete(commit_changes, umbrella_changes)

    git "commit", ["-m", aggregated_commit_message(umbrella_changes, app_changes)]

    for {app, app_path, _current_version, new_version, changelog_entries} <- commit_changes do
      if app == :umbrella do
        git "tag", ["#{new_version}", "-a", "-m", "Version: #{new_version}"]
      else
        git "tag", ["#{app_path}/#{new_version}", "-a", "-m", "Version(#{Atom.to_string(app)}): #{new_version}"]
      end
    end
  end

  def push!(new_version) do
    git "push", ["-q", "origin", current_branch(), new_version]
  end

  defp git(command, args) when is_list(args) do
    run_git_command(command, args)
  end

  defp git(command, args) do
    run_git_command(command, [args])
  end

  defp run_git_command(command, args) do
    result = System.cmd("git", [command] ++ args)
    case result do
      {value, 0} -> {:ok, value}
      {value, _} -> {:error, value}
    end
  end

  defp remove_trailing_newline(str) do
    String.replace_trailing(str, "\n", "")
  end

  def commit_message(new_version, changelog_entries) do
    """
Version #{new_version}:

#{Enum.map(changelog_entries, fn(x) -> "* " <> x end) |> Enum.join("\n")}
    """
  end
  defp aggregated_commit_message(umbrella_changes, app_changes) do
    """
Version #{elem(umbrella_changes, 3)}:

#{Enum.map(elem(umbrella_changes, 4), fn(x) -> "* " <> x end) |> Enum.join("\n")}

Nested Changes:
    #{Enum.flat_map(app_changes, fn(app_change) ->
      [nested_commit_version(elem(app_change, 1), elem(app_change, 3))]
      ++
      nested_commit_messages(elem(umbrella_changes, 4))
    end) |> Enum.join("\n")}
    """
  end

  defp nested_commit_version(app, version) do
    "\t#{app} - #{version}"
  end
  defp nested_commit_messages(change_strings) do
    Enum.map(change_strings, fn(change_string) -> "\t\t" <> change_string end)
  end

end
