# Cowrie Overview

`Cowrie` helps you print beautiful and consistent Terminal output to the Shell
of your Elixir apps using functions inspired by familiar HTML tags, e.g.

```elixir
import Cowrie

h1("This is a Heading")
ol(["This is", "an ordered", "list via ol/2"])
warning("Uh oh...")
```
![Cowrie Demo](https://www.udrop.com/plugins/imageviewer/site/show_image.php?idt=31c70a72005f18fecf68c47d6c735ea1&f=9913)

All formatting is [configurable](config.md), either via your application's configuration file, 
or as arguments to the various functions. Sensible defaults are provided, but check out the [configuration options](config.md).

All formatting styles rely on `IO.ANSI` formatting options, so you are free to
research and apply your own styles to match your personal preference.

## Usage

Use `Cowrie` functions in your custom `Mix.Task` -- importing `Cowrie` makes its 
functions easier to use.

```
defmodule Mix.Tasks.MyApp.Example do
  use Mix.Task
  import Cowrie

  @shortdoc "Example mix task using Cowrie"


  def run(opts) do
    h1("My Custom Task")
    warning("The following issues were found:")
    ul(["Lions", "Tigers", "Bears"])
    spinner(fn -> MyApp.long_task() end)
  end
end
```

Ready? Check out the `Cowrie` API.
