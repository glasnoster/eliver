defmodule Eliver.ChangeLogFileTest do
  use ExUnit.Case
  doctest Eliver

  setup do
    File.copy("test/support/CHANGELOG_template.md", "test/support/CHANGELOG.md")
    File.copy("test/support/CHANGELOG2_template.md", "test/support/CHANGELOG2.md")
    File.rm("test/support/test.md")
    on_exit fn ->
      File.rm("test/support/CHANGELOG.md")
      File.rm("test/support/CHANGELOG2.md")
      File.rm("test/support/test.md")
    end
    :ok
  end

  describe "bumping an existing changelog file" do
    def expected_existing_changelog_contents do
      """
      # Changelog

      ## 1.1.0
      * e1
      * e2

      ## 1.0.1
      * Entry 1
      * Entry 2

      ## 1.0.0
      * Entry 1
      """
    end

    test "it updates the changelog" do
      Eliver.ChangeLogFile.bump("1.1.0", ["e1", "e2"], "test/support/CHANGELOG.md")
      {:ok, changelog_contents} = File.read("test/support/CHANGELOG.md")
      assert changelog_contents == expected_existing_changelog_contents()
    end

    test "it is case insensitive and updates the changelog" do
      Eliver.ChangeLogFile.bump("1.1.0", ["e1", "e2"], "test/support/CHANGELOG2.md")
      {:ok, changelog_contents} = File.read("test/support/CHANGELOG2.md")
      assert changelog_contents == expected_existing_changelog_contents()
    end
  end

  describe "when the changelog files does not exist" do
    def expected_new_changelog_contents do
      """
      # Changelog

      ## 1.1.0
      * e1
      * e2
      """
    end
    test "it creates the changelog file if it doesn't exist" do
      Eliver.ChangeLogFile.bump("1.1.0", ["e1", "e2"], "test/support/test.md")
      {:ok, new_change_log_contents} = File.read("test/support/test.md")
      assert new_change_log_contents == expected_new_changelog_contents()
    end
  end

end