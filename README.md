# Eliver

[![CircleCI](https://circleci.com/gh/glasnoster/eliver.svg?style=svg)](https://circleci.com/gh/glasnoster/eliver)
[![Hex.pm](https://img.shields.io/hexpm/v/eliver.svg?style=flat-square)](https://hex.pm/packages/eliver)

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
  [{:eliver, "~> 2.0.0"}]
end
```

  2. Create a VERSION file with the initial version in the root of the project
  3. In `mix.exs`, read the version from `VERSION`
```elixir
version: String.trim(File.read!("VERSION")),
```

## Usage

```bash
$ mix eliver.bump
```

## TODO

* Add support to release the package to Hex

## Contributing

Please do.
