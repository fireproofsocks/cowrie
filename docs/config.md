# Configuration

`Cowrie` is built to be stylable. Instead of a Cascading Style Sheets (CSS), we have configuration details.

Most of the functions will pass their text through the following pipeline:

1. Pre-transformation (where one or more functions modifies the input text)
2. Formatting (where `IO.ANSI` codes are applied as a prefix to the input text)
3. Post-format (where `IO.ANSI` reset codes are applied as a suffix to the input text) 
4. Post-transformation (where one or more functions modifies the formatted text)

The configuration settings have sections corresponding to these steps.


## Pre-Transformations

Pre-transformations are functions that alter the text _before_ it is formatted. These functions are appropriate for tasks such as capitalizing words or centering the output by padding it with spaces.

Pre-transformations are defined inside the `:pre_transforms` configuration option; most functions in `Cowrie` accept a key inside `:pre_transforms` corresponding to their function name.

These pre-transformations are called _before_ the corresponding formatting function is applied.

The values here should either be callbacks using the [`&` capture operator](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#&/1) syntax pointing to a function with an arity of 2 (e.g. `&Mod.fun/arity`, OR a list of such callbacks.


### Formatting

Most functions in `Cowrie` include a formatting configuration key corresponding to their name.

The bulk of `Cowrie`'s configuration options expect `IO.ANSI` functions to render ANSI escape sequences. These functions return special text that cause your terminal to format and/or colorize the output that follows.  You can try this out in `iex` -- just concatenate the functions' outputs with the string you wish to format, e.g.

```iex
iex> IO.ANSI.bright() <> IO.ANSI.blue() <> "Big Blue!"
"\e[1m\e[34mBig Blue!"
iex> Mix.shell().info(IO.ANSI.bright() <> IO.ANSI.blue() <> "Big Blue!")
Big Blue!
:ok
```

The raw return value is a strange-looking string: `"\e[1m\e[34mBig Blue!"`.  It isn't until you pass that to your `Mix.Shell` that you will actually see the result of this formatting.

## Post-Format

If no key is defined inside the `post_format` map, the following ANSI reset codes will be appended to the formatted text:
```
IO.ANSI.default_background() <> IO.ANSI.normal() <> IO.ANSI.reset()
```

Even though the reset codes are not normally visible, there are times when you may not wish them to precisely symmetrical or not there at all.  One case is for error messages (which you may have tests that assert for). Also, error messages should receive some default coloring from Elixir already.  For this reason, the formatting and `post_format` options for the `error/2` are disabled: the post_format option is set to `""`.  Otherwise all error messages would include the ANSI reset `"\e[49m\e[22m\e[0m"` appended to them, and that could easily make testing a nightmare. Consider disabling ANSI entirely for your test environment.

## Post-Transformation

Post-transformations are functions that alter the text _after_ it has been formatted. These functions can be used for final formatting touches such as adding an extra newline to the formatted text to give it the desired spacing.

Post-transformations are defined inside the `:post_transforms` configuration option; most functions in `Cowrie` accept a key inside `:post_transforms` corresponding to their function name.

## Other Settings

There are a few other options that exist: mostly these exist so that `Cowrie` functions can dispatch to 
modules that implement a specific behaviour.  For example the `:spinner_module` option must point to a 
module that can properly draw a spinner animation.

```
config :cowrie,
    # Must implement the `Cowrie.SpinnerBehaviour` behaviour
    spinner_module: Cowrie.TimerSpinner
```
 
---------

## Sample Configuration

Inside your `config/config.exs` (or environment-specific config), you may define any (or none) of the following:

```elixir
config :cowrie,
  alert_danger: IO.ANSI.red(),
  alert_info: IO.ANSI.blue(),
  alert_success: IO.ANSI.green(),
  alert_warning: IO.ANSI.yellow(),
  box_chars: %{
    t: "═",
    tr: "╗",
    r: "║",
    br: "╝",
    b: "═",
    bl: "╚",
    l: "║",
    tl: "╔"
  },
  box_padding: 1,
  br: "",
  cols: 80,
  comment: IO.ANSI.color(246),
  error: "",
  dt: IO.ANSI.blue(),
  dd: "    : " <> IO.ANSI.color(246),
  h1: IO.ANSI.bright() <> IO.ANSI.white_background() <> IO.ANSI.black(),
  h1_transform: &Cowrie.Transforms.upcase/2,
  h2: IO.ANSI.bright(),
  info: IO.ANSI.blue(),
  hr: IO.ANSI.color(236),
  hr_char: "─",
  hr_padding: 4,
  li: "",
  li_bullet: "-",
  line: "",
  ol_start: 1,
  prompt: "",
  secret: "",
  th: IO.ANSI.bright(),
  td: "",
  warning: IO.ANSI.red(),
  yes?: "",
  # The post_format map can define custom formatting resets.
    post_format: %{
      error: ""
    },
  # The pre_transforms map can define callbacks to functions that modify the text
  # before formatting it.
  pre_transforms: %{
    alert_danger: &Cowrie.Transforms.alert_danger/2,
    alert_info: &Cowrie.Transforms.alert_info/2,
    alert_success: &Cowrie.Transforms.alert_success/2,
    alert_warning: &Cowrie.Transforms.alert_warning/2,
    h1: &Cowrie.Transforms.center/2,
    hr: &Cowrie.Transforms.hr/2,
    ol_li: &Cowrie.Transforms.ol_li/2,
    ul_li: &Cowrie.Transforms.ul_li/2
  },
  post_transforms: %{
    h1: [&Cowrie.Transforms.prepend_newline/2, &Cowrie.Transforms.append_newline/2],
    h2: &Cowrie.Transforms.append_newline/2,
    hr: &Cowrie.Transforms.append_newline/2
  },
  # Must implement the `Cowrie.SpinnerBehaviour` behaviour
  spinner_module: Cowrie.TimerSpinner
```

Remember to try out `Cowrie.demo/0` to visually inspect the results of your styling. You can also use `Cowrie.colors/0` to display a list of all available color swatches.
