# Eliver

[![CircleCI](https://circleci.com/gh/glasnoster/eliver.svg?style=svg)](https://circleci.com/gh/glasnoster/eliver)

Interactive semantic versioning for Elixir packages.

Eliver is an Elixir clone of [semvergen](https://github.com/brendon9x/semvergen)

Eliver...
* bumps the version in `mix.exs`
* prompts the user for changelog entries and updates `CHANGELOG.md`
* commits these changes
* creates a tag
* pushes to origin

## Installation

  1. Add `eliver` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:eliver, "~> 0.1.0"}]
    end
    ```

## Usage

```bash
$ mix eliver.bump
```

## TODO

* Add support to release the package to Hex
* Clean up prompt code (maybe create a separate package that provides a pretty dsl to prompt for user input?)

## Contributing

Please do.
