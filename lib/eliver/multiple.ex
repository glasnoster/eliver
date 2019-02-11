defmodule Eliver.Multiple do

  def list_sub_apps() do
    Mix.Project.apps_paths() |> IO.inspect()
    |> case do
      nil -> {:error, :unknown_app_structure}
      sub_apps -> {:ok, sub_apps}
    end
  end

end
