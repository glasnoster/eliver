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
    tracking_check = git "rev-list", ["HEAD..@{u}", "--count"]
    elem(tracking_check, 0) == :ok
  end

  def current_branch do
    elem(git("symbolic-ref", ["--short", "HEAD"]), 1) |> remove_trailing_newline
  end

  def on_master? do
    current_branch == "master"
  end

  def fetch! do
    git "fetch", "-q"
  end

  def commit!(new_version, changelog_entries) do
    git "add", "CHANGELOG.md"
    git "add", "mix.exs"
    git "commit", ["-m", commit_message(new_version, changelog_entries)]
    git "tag", ["#{new_version}", "-a", "-m", "Version: #{new_version}"]
  end

  def push!(new_version) do
    # git "push", ["-q", "origin", current_branch, new_version]
  end

  defp git(command, args) when is_list(args) do
    run_git_command(command, args)
  end

  defp git(command, args) do
    run_git_command(command, [args])
  end

  defp run_git_command(command, args \\ []) do
    result = System.cmd("git", [command] ++ args)
    case result do
      {value, 0} -> {:ok, value}
      {value, _} -> {:error, value}
    end
  end

  defp remove_trailing_newline(str) do
    String.replace_trailing(str, "\n", "")
  end

  defp commit_message(new_version, changelog_entries) do
    """
Version #{new_version}:

#{Enum.map(changelog_entries, fn(x) -> "* " <> x end) |> Enum.join("\n")}
    """
  end


end