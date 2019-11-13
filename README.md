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
  [{:eliver, "~> 2.0.0", only: :dev}]
end
```

  2. Create a VERSION file with the initial version in the root of the project
  3. In `mix.exs`, read the version from `VERSION`
```elixir
version: String.trim(File.read!("VERSION")),
```

## Usage - Normal Apps

```bash
$ mix eliver.bump
```

## Usage - Umbrella Apps

In umbrella apps there are two supported use-cases:

  1. A single version file is provided, with all sub-apps sharing the same version number.
  2. Sub-app versions are managed seperately. In this case, each app has a seperate `VERSION` and `CHANGELOG.md` file.

  For option 1, eliver is used in the same manner as for normal Elixir apps.

  For option 2, eliver provides a `--multi` flag.  

```bash
$ mix eliver.bump --multi
```

## Contributing

Please do.
