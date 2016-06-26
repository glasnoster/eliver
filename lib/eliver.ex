defmodule Eliver do

  def main(args) do
    args |> parse_args |> process
  end

  def process([]) do
    IO.puts "No arguments given"
  end

  def process(args) do
    case hd args do
      "bump" ->
        IO.puts Eliver.MixFile.version_from_mixfile
        |> Eliver.Bump.next_version(get_bump_type)
    end
  end

  defp parse_args(args) do
    {_, args, _} = OptionParser.parse(args)
    args
  end

  defp get_bump_type do
    selected_option = (IO.gets """
    Select release type:
      1. Patch: Bug fixes, recommended for all (default)
      2. Minor: New features, but backwards compatible
      3. Major: Breaking changes
    """) |> String.replace_trailing("\n", "")

    %{"1" => :patch, "2" => :minor, "3" => :major}[selected_option] || get_bump_type
  end

end

