defmodule Mix.Tasks.Eliver.Bump do
  use Mix.Task
  import Enquirer

  def run(args) do
    args |> parse_args |> bump
  end

  defp bump(args) do
    case check_for_git_problems() do
      {:error, message} ->
        say message, :red
      {:ok} ->
        do_bump(args)
    end
  end

  defp do_bump(args) do
    case Keyword.get(args, :multi) do
      true -> bump_multiple()
      nil -> bump_normal()
    end
  end

  defp bump_multiple() do
    Eliver.Multiple.list_sub_apps()
    |> case  do
      {:ok, sub_apps} ->
        sub_apps = Map.put(sub_apps, :umbrella, ".")

        changes = Enum.map(sub_apps, fn

          {:umbrella, app_path} ->
            # Note changes re required for the umbrella app
            {current_version, new_version, changelog_entries} = get_changes(app_path, :normal)
            {:umbrella, app_path, current_version, new_version, changelog_entries}

          {app, app_path} ->

          say "\n\n=============================================="
          say "Bump details for #{Atom.to_string(app)}"
          say "=============================================="

          get_changes(app_path, :multi)
          |> case  do
            nil -> nil
            {current_version, new_version, changelog_entries} ->
              {app, app_path, current_version, new_version, changelog_entries}
          end


        end)
        |> Enum.filter(fn(change) -> not is_nil(change) end)

        if allow_changes?(changes) do
          make_changes(changes)
        end

      {:error, :unknown_app_structure} ->
        say "Please note that only standard umbrella app directory structures are supported. Please refer to the documentation for details", :red
    end
  end
  defp bump_normal() do
    {current_version, new_version, changelog_entries} = get_changes()
    if allow_changes?(new_version, changelog_entries) do
      make_changes(new_version, changelog_entries)
    end
  end

  defp get_changes(root_for_changes \\ ".", bump_type \\ :normal) do
    {current_version, new_version} = get_new_version(root_for_changes, bump_type)

    if current_version == new_version do
      nil
    else
      {current_version, new_version, get_changelog_entries()}
    end
  end

  defp allow_changes?(changes) when is_list(changes) do
    say "\n"
    say "=============================================="
    say "Summary of changes:"
    say "=============================================="

    Enum.each(changes, fn(app_changes) ->
      display_change(app_changes)
    end)

    say "\n"
    result = ask "Continue?", false
    case result do
      {:ok, value} -> value
      {:error, _}  -> false
    end
  end
  defp allow_changes?(new_version, changelog_entries) do
    current_version = Eliver.VersionFile.version
    say "\n"
    say "Summary of changes:"
    display_change(current_version, new_version, changelog_entries)
    result = ask "Continue?", false
    case result do
      {:ok, value} -> value
      {:error, _}  -> false
    end
  end

  defp display_change({app, app_path, current_version, new_version, changelog_entries}) do
    say "\n#{Atom.to_string(app)} (#{app_path})"
    say "=============================================="
    display_change(current_version, new_version, changelog_entries)
  end
  defp display_change(current_version, new_version, changelog_entries) do
    say "Bumping version #{current_version} → #{new_version}", :green
    say ("#{Enum.map(changelog_entries, fn(x) -> "* " <> x end) |> Enum.join("\n")}"), :green
    say "\n"
  end

  defp make_changes(changes) when is_list(changes) do
    for {app, app_path, current_version, new_version, changelog_entries} <- changes do
      Eliver.VersionFile.bump(new_version, "#{app_path}/VERSION")
      Eliver.ChangeLogFile.bump(new_version, changelog_entries, "#{app_path}/CHANGELOG.md")
    end

    Eliver.Git.commit!(changes)
    say "Pushing to origin..."
    Eliver.Git.push!(Eliver.VersionFile.version())
  end

  defp make_changes(new_version, changelog_entries) do
    Eliver.VersionFile.bump(new_version)
    Eliver.ChangeLogFile.bump(new_version, changelog_entries)
    Eliver.Git.commit!(new_version, changelog_entries)
    say "Pushing to origin..."
    Eliver.Git.push!(new_version)
  end

  defp check_for_git_problems do
    # cond do
    #   !Eliver.Git.is_tracking_branch? ->
    #     {:error, "This branch is not tracking a remote branch. Aborting..."}
    #   !Eliver.Git.on_master? && !continue_on_branch?() ->
    #     {:error, "Aborting"}
    #   Eliver.Git.index_dirty? ->
    #     {:error, "Git index dirty. Commit changes before continuing"}
    #   Eliver.Git.fetch! && Eliver.Git.upstream_changes? ->
    #     {:error, "This branch is not up to date with upstream"}
    #   true ->
        {:ok}
    # end
  end

  defp continue_on_branch? do
    question = "You are not on master. It is not recommended to create releases from a branch unless they're maintenance releases. Continue?"
    result = ask question, false
    case result do
      {:ok, value} -> value
      {:error, _}  -> continue_on_branch?()
    end
  end

  defp get_new_version(dir, type) do
    {
      Eliver.VersionFile.version("#{dir}/VERSION"),
      Eliver.VersionFile.version("#{dir}/VERSION") |> Eliver.next_version(get_bump_type(type))
    }
  end

  defp get_changelog_entries do
    {:ok, result} = get_list "Enter the changes, enter a blank line when you're done"
    result
  end

  defp get_bump_type(:multi) do
    result = choose "Select release type",
      patch:   "Bug fixes, recommended for all",
      minor:   "New features, but backwards compatible",
      major:   "Breaking changes",
      none:   "None",
      default: :none

    case result do
      {:ok, value} -> value
      {:error, _}  -> get_bump_type(:multi)
    end
  end

  defp get_bump_type(:normal) do
    result = choose "Select release type",
      patch:   "Bug fixes, recommended for all",
      minor:   "New features, but backwards compatible",
      major:   "Breaking changes",
      default: :patch

    case result do
      {:ok, value} -> value
      {:error, _}  -> get_bump_type(:normal)
    end
  end

  defp parse_args(args) do
    {args, _, _} = OptionParser.parse(args)
    args
  end
end
