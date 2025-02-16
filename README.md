# Cowrie

[![Module Version](https://img.shields.io/hexpm/v/cowrie.svg)](https://hex.pm/packages/cowrie)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/cowrie/)
[![Total Download](https://img.shields.io/hexpm/dt/cowrie.svg)](https://hex.pm/packages/cowrie)
[![License](https://img.shields.io/hexpm/l/cowrie.svg)](https://hex.pm/packages/cowrie)
[![Last Updated](https://img.shields.io/github/last-commit/fireproofsocks/cowrie.svg)](https://github.com/fireproofsocks/cowrie/commits/master)

`Cowrie` helps you print beautiful and consistent Terminal output to the Shell
of your Elixir apps using functions inspired by familiar HTML tags, e.g.

```elixir
import Cowrie

h1("This is a Heading")
ol(["This is", "an ordered", "list via ol/2"])
warning("Uh oh...")
```

All formatting is configurable, either via your application's configuration file,
or as arguments to the various functions. Sensible defaults are provided.
Try running the `Cowire/demo/0` function to inspect the styling of all the output.

All formatting styles rely on `IO.ANSI` formatting options, so you are free to
research and apply your own styles to match your personal preference.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `cowrie` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cowrie, "~> 0.5.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/cowrie](https://hexdocs.pm/cowrie).

## Image Attribution

The logo image is Cowry by Amos Kofi Commey from [the Noun Project](https://thenounproject.com/)
