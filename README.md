# Eliver

An Elixir clone of [semvergen](https://github.com/glasnoster/semvergen) in order to learn the basics of the language.

I hope it will be useful someday

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `eliver` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:eliver, "~> 0.1.0"}]
    end
    ```

  2. Ensure `eliver` is started before your application:

    ```elixir
    def application do
      [applications: [:eliver]]
    end
    ```

## Usage

```bash
$ ./eliver bump
```

