defmodule Cowrie do
  @moduledoc """
  `Cowrie` helps you print beautiful and consistent Terminal output to the Shell
  using familiar functions inspired by HTML.
  """
  require Logger

  @default_transform &Cowrie.Transforms.passthru/2

  @red IO.ANSI.color(162)
  @blue IO.ANSI.color(57)
  @green IO.ANSI.color(42)
  @yellow IO.ANSI.color(190)
  @grey IO.ANSI.color(246)
  @bold IO.ANSI.bright()

  @default_styles %{
    # For alert/2
    alert_danger: @red,
    alert_info: @blue,
    alert_success: @green,
    alert_warning: @yellow,
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
    comment: @grey,
    error: "",
    dt: @blue,
    dd: "    : " <> @grey,
    h1: @bold <> IO.ANSI.white_background() <> IO.ANSI.black(),
    h1_transform: &Cowrie.Transforms.upcase/2,
    h2: @bold,
    info: @green,
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
    warning: @yellow,
    yes?: "",
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
  }

  # See scripts/color_map.exs
  @color_map [
    %{index: 0, rgb: nil},
    %{index: 1, rgb: nil},
    %{index: 2, rgb: nil},
    %{index: 3, rgb: nil},
    %{index: 4, rgb: nil},
    %{index: 5, rgb: nil},
    %{index: 6, rgb: nil},
    %{index: 7, rgb: nil},
    %{index: 8, rgb: nil},
    %{index: 9, rgb: nil},
    %{index: 10, rgb: nil},
    %{index: 11, rgb: nil},
    %{index: 12, rgb: nil},
    %{index: 13, rgb: nil},
    %{index: 14, rgb: nil},
    %{index: 15, rgb: nil},
    %{index: 16, rgb: {0, 0, 0}},
    %{index: 17, rgb: {0, 0, 1}},
    %{index: 18, rgb: {0, 0, 2}},
    %{index: 19, rgb: {0, 0, 3}},
    %{index: 20, rgb: {0, 0, 4}},
    %{index: 21, rgb: {0, 0, 5}},
    %{index: 22, rgb: {0, 1, 0}},
    %{index: 23, rgb: {0, 1, 1}},
    %{index: 24, rgb: {0, 1, 2}},
    %{index: 25, rgb: {0, 1, 3}},
    %{index: 26, rgb: {0, 1, 4}},
    %{index: 27, rgb: {0, 1, 5}},
    %{index: 28, rgb: {0, 2, 0}},
    %{index: 29, rgb: {0, 2, 1}},
    %{index: 30, rgb: {0, 2, 2}},
    %{index: 31, rgb: {0, 2, 3}},
    %{index: 32, rgb: {0, 2, 4}},
    %{index: 33, rgb: {0, 2, 5}},
    %{index: 34, rgb: {0, 3, 0}},
    %{index: 35, rgb: {0, 3, 1}},
    %{index: 36, rgb: {0, 3, 2}},
    %{index: 37, rgb: {0, 3, 3}},
    %{index: 38, rgb: {0, 3, 4}},
    %{index: 39, rgb: {0, 3, 5}},
    %{index: 40, rgb: {0, 4, 0}},
    %{index: 41, rgb: {0, 4, 1}},
    %{index: 42, rgb: {0, 4, 2}},
    %{index: 43, rgb: {0, 4, 3}},
    %{index: 44, rgb: {0, 4, 4}},
    %{index: 45, rgb: {0, 4, 5}},
    %{index: 46, rgb: {0, 5, 0}},
    %{index: 47, rgb: {0, 5, 1}},
    %{index: 48, rgb: {0, 5, 2}},
    %{index: 49, rgb: {0, 5, 3}},
    %{index: 50, rgb: {0, 5, 4}},
    %{index: 51, rgb: {0, 5, 5}},
    %{index: 52, rgb: {1, 0, 0}},
    %{index: 53, rgb: {1, 0, 1}},
    %{index: 54, rgb: {1, 0, 2}},
    %{index: 55, rgb: {1, 0, 3}},
    %{index: 56, rgb: {1, 0, 4}},
    %{index: 57, rgb: {1, 0, 5}},
    %{index: 58, rgb: {1, 1, 0}},
    %{index: 59, rgb: {1, 1, 1}},
    %{index: 60, rgb: {1, 1, 2}},
    %{index: 61, rgb: {1, 1, 3}},
    %{index: 62, rgb: {1, 1, 4}},
    %{index: 63, rgb: {1, 1, 5}},
    %{index: 64, rgb: {1, 2, 0}},
    %{index: 65, rgb: {1, 2, 1}},
    %{index: 66, rgb: {1, 2, 2}},
    %{index: 67, rgb: {1, 2, 3}},
    %{index: 68, rgb: {1, 2, 4}},
    %{index: 69, rgb: {1, 2, 5}},
    %{index: 70, rgb: {1, 3, 0}},
    %{index: 71, rgb: {1, 3, 1}},
    %{index: 72, rgb: {1, 3, 2}},
    %{index: 73, rgb: {1, 3, 3}},
    %{index: 74, rgb: {1, 3, 4}},
    %{index: 75, rgb: {1, 3, 5}},
    %{index: 76, rgb: {1, 4, 0}},
    %{index: 77, rgb: {1, 4, 1}},
    %{index: 78, rgb: {1, 4, 2}},
    %{index: 79, rgb: {1, 4, 3}},
    %{index: 80, rgb: {1, 4, 4}},
    %{index: 81, rgb: {1, 4, 5}},
    %{index: 82, rgb: {1, 5, 0}},
    %{index: 83, rgb: {1, 5, 1}},
    %{index: 84, rgb: {1, 5, 2}},
    %{index: 85, rgb: {1, 5, 3}},
    %{index: 86, rgb: {1, 5, 4}},
    %{index: 87, rgb: {1, 5, 5}},
    %{index: 88, rgb: {2, 0, 0}},
    %{index: 89, rgb: {2, 0, 1}},
    %{index: 90, rgb: {2, 0, 2}},
    %{index: 91, rgb: {2, 0, 3}},
    %{index: 92, rgb: {2, 0, 4}},
    %{index: 93, rgb: {2, 0, 5}},
    %{index: 94, rgb: {2, 1, 0}},
    %{index: 95, rgb: {2, 1, 1}},
    %{index: 96, rgb: {2, 1, 2}},
    %{index: 97, rgb: {2, 1, 3}},
    %{index: 98, rgb: {2, 1, 4}},
    %{index: 99, rgb: {2, 1, 5}},
    %{index: 100, rgb: {2, 2, 0}},
    %{index: 101, rgb: {2, 2, 1}},
    %{index: 102, rgb: {2, 2, 2}},
    %{index: 103, rgb: {2, 2, 3}},
    %{index: 104, rgb: {2, 2, 4}},
    %{index: 105, rgb: {2, 2, 5}},
    %{index: 106, rgb: {2, 3, 0}},
    %{index: 107, rgb: {2, 3, 1}},
    %{index: 108, rgb: {2, 3, 2}},
    %{index: 109, rgb: {2, 3, 3}},
    %{index: 110, rgb: {2, 3, 4}},
    %{index: 111, rgb: {2, 3, 5}},
    %{index: 112, rgb: {2, 4, 0}},
    %{index: 113, rgb: {2, 4, 1}},
    %{index: 114, rgb: {2, 4, 2}},
    %{index: 115, rgb: {2, 4, 3}},
    %{index: 116, rgb: {2, 4, 4}},
    %{index: 117, rgb: {2, 4, 5}},
    %{index: 118, rgb: {2, 5, 0}},
    %{index: 119, rgb: {2, 5, 1}},
    %{index: 120, rgb: {2, 5, 2}},
    %{index: 121, rgb: {2, 5, 3}},
    %{index: 122, rgb: {2, 5, 4}},
    %{index: 123, rgb: {2, 5, 5}},
    %{index: 124, rgb: {3, 0, 0}},
    %{index: 125, rgb: {3, 0, 1}},
    %{index: 126, rgb: {3, 0, 2}},
    %{index: 127, rgb: {3, 0, 3}},
    %{index: 128, rgb: {3, 0, 4}},
    %{index: 129, rgb: {3, 0, 5}},
    %{index: 130, rgb: {3, 1, 0}},
    %{index: 131, rgb: {3, 1, 1}},
    %{index: 132, rgb: {3, 1, 2}},
    %{index: 133, rgb: {3, 1, 3}},
    %{index: 134, rgb: {3, 1, 4}},
    %{index: 135, rgb: {3, 1, 5}},
    %{index: 136, rgb: {3, 2, 0}},
    %{index: 137, rgb: {3, 2, 1}},
    %{index: 138, rgb: {3, 2, 2}},
    %{index: 139, rgb: {3, 2, 3}},
    %{index: 140, rgb: {3, 2, 4}},
    %{index: 141, rgb: {3, 2, 5}},
    %{index: 142, rgb: {3, 3, 0}},
    %{index: 143, rgb: {3, 3, 1}},
    %{index: 144, rgb: {3, 3, 2}},
    %{index: 145, rgb: {3, 3, 3}},
    %{index: 146, rgb: {3, 3, 4}},
    %{index: 147, rgb: {3, 3, 5}},
    %{index: 148, rgb: {3, 4, 0}},
    %{index: 149, rgb: {3, 4, 1}},
    %{index: 150, rgb: {3, 4, 2}},
    %{index: 151, rgb: {3, 4, 3}},
    %{index: 152, rgb: {3, 4, 4}},
    %{index: 153, rgb: {3, 4, 5}},
    %{index: 154, rgb: {3, 5, 0}},
    %{index: 155, rgb: {3, 5, 1}},
    %{index: 156, rgb: {3, 5, 2}},
    %{index: 157, rgb: {3, 5, 3}},
    %{index: 158, rgb: {3, 5, 4}},
    %{index: 159, rgb: {3, 5, 5}},
    %{index: 160, rgb: {4, 0, 0}},
    %{index: 161, rgb: {4, 0, 1}},
    %{index: 162, rgb: {4, 0, 2}},
    %{index: 163, rgb: {4, 0, 3}},
    %{index: 164, rgb: {4, 0, 4}},
    %{index: 165, rgb: {4, 0, 5}},
    %{index: 166, rgb: {4, 1, 0}},
    %{index: 167, rgb: {4, 1, 1}},
    %{index: 168, rgb: {4, 1, 2}},
    %{index: 169, rgb: {4, 1, 3}},
    %{index: 170, rgb: {4, 1, 4}},
    %{index: 171, rgb: {4, 1, 5}},
    %{index: 172, rgb: {4, 2, 0}},
    %{index: 173, rgb: {4, 2, 1}},
    %{index: 174, rgb: {4, 2, 2}},
    %{index: 175, rgb: {4, 2, 3}},
    %{index: 176, rgb: {4, 2, 4}},
    %{index: 177, rgb: {4, 2, 5}},
    %{index: 178, rgb: {4, 3, 0}},
    %{index: 179, rgb: {4, 3, 1}},
    %{index: 180, rgb: {4, 3, 2}},
    %{index: 181, rgb: {4, 3, 3}},
    %{index: 182, rgb: {4, 3, 4}},
    %{index: 183, rgb: {4, 3, 5}},
    %{index: 184, rgb: {4, 4, 0}},
    %{index: 185, rgb: {4, 4, 1}},
    %{index: 186, rgb: {4, 4, 2}},
    %{index: 187, rgb: {4, 4, 3}},
    %{index: 188, rgb: {4, 4, 4}},
    %{index: 189, rgb: {4, 4, 5}},
    %{index: 190, rgb: {4, 5, 0}},
    %{index: 191, rgb: {4, 5, 1}},
    %{index: 192, rgb: {4, 5, 2}},
    %{index: 193, rgb: {4, 5, 3}},
    %{index: 194, rgb: {4, 5, 4}},
    %{index: 195, rgb: {4, 5, 5}},
    %{index: 196, rgb: {5, 0, 0}},
    %{index: 197, rgb: {5, 0, 1}},
    %{index: 198, rgb: {5, 0, 2}},
    %{index: 199, rgb: {5, 0, 3}},
    %{index: 200, rgb: {5, 0, 4}},
    %{index: 201, rgb: {5, 0, 5}},
    %{index: 202, rgb: {5, 1, 0}},
    %{index: 203, rgb: {5, 1, 1}},
    %{index: 204, rgb: {5, 1, 2}},
    %{index: 205, rgb: {5, 1, 3}},
    %{index: 206, rgb: {5, 1, 4}},
    %{index: 207, rgb: {5, 1, 5}},
    %{index: 208, rgb: {5, 2, 0}},
    %{index: 209, rgb: {5, 2, 1}},
    %{index: 210, rgb: {5, 2, 2}},
    %{index: 211, rgb: {5, 2, 3}},
    %{index: 212, rgb: {5, 2, 4}},
    %{index: 213, rgb: {5, 2, 5}},
    %{index: 214, rgb: {5, 3, 0}},
    %{index: 215, rgb: {5, 3, 1}},
    %{index: 216, rgb: {5, 3, 2}},
    %{index: 217, rgb: {5, 3, 3}},
    %{index: 218, rgb: {5, 3, 4}},
    %{index: 219, rgb: {5, 3, 5}},
    %{index: 220, rgb: {5, 4, 0}},
    %{index: 221, rgb: {5, 4, 1}},
    %{index: 222, rgb: {5, 4, 2}},
    %{index: 223, rgb: {5, 4, 3}},
    %{index: 224, rgb: {5, 4, 4}},
    %{index: 225, rgb: {5, 4, 5}},
    %{index: 226, rgb: {5, 5, 0}},
    %{index: 227, rgb: {5, 5, 1}},
    %{index: 228, rgb: {5, 5, 2}},
    %{index: 229, rgb: {5, 5, 3}},
    %{index: 230, rgb: {5, 5, 4}},
    %{index: 231, rgb: {5, 5, 5}},
    %{index: 232, rgb: nil},
    %{index: 233, rgb: nil},
    %{index: 234, rgb: nil},
    %{index: 235, rgb: nil},
    %{index: 236, rgb: nil},
    %{index: 237, rgb: nil},
    %{index: 238, rgb: nil},
    %{index: 239, rgb: nil},
    %{index: 240, rgb: nil},
    %{index: 241, rgb: nil},
    %{index: 242, rgb: nil},
    %{index: 243, rgb: nil},
    %{index: 244, rgb: nil},
    %{index: 245, rgb: nil},
    %{index: 246, rgb: nil},
    %{index: 247, rgb: nil},
    %{index: 248, rgb: nil},
    %{index: 249, rgb: nil},
    %{index: 250, rgb: nil},
    %{index: 251, rgb: nil},
    %{index: 252, rgb: nil},
    %{index: 253, rgb: nil},
    %{index: 254, rgb: nil},
    %{index: 255, rgb: nil}
  ]

  @doc """
  Prints an alert box of the specified type to STDOUT
  (think [Bootstrap alert boxes](https://getbootstrap.com/docs/4.0/components/alerts/)).

  Options:
  - `:type` indicates the type of alert, one of `:danger`, `:info`, `:success`, `:warning`. default: `:warning`

  Formatting and transform options correspond to the given alert `type`:

  - `:alert_danger` for type `:danger`
  - `:alert_info` for type `:info`
  - `:alert_success` for type `:success`
  - `:alert_warning` for type `:warning`

  ## Examples

      iex(2)> alert("The answer is 42", type: :info)
      ╔═══════════════════════════╗
      ║ ℹ️  Info:️ The answer is 42 ║
      ╚═══════════════════════════╝
  """
  def alert(text, opts \\ []) when is_binary(text) do
    type = Keyword.get(opts, :type, :warning)

    # We have to translate the config key so we don't collide with the keys defined
    # for info/2, info/2, and warning/2
    key =
      Map.get(
        %{
          danger: :alert_danger,
          info: :alert_info,
          success: :alert_success,
          warning: :alert_warning
        },
        type
      )

    transform_print(text, opts, key)
  end

  @doc """
  Prints a line break (an empty line) to STDOUT.

  Formatting and transforms options: `:br`

  ## Examples

      iex> br
  """
  def br, do: transform_print("", [], :br)

  @doc """
  Outputs available ANSI colors, useful when you want to choose a color visually.

  ## Examples

      iex> colors
  """
  def colors do
    @color_map
    |> Enum.each(fn %{index: i, rgb: rgb} -> Mix.shell().info(color_swatch_text(i, rgb)) end)
  end

  @doc """
  Prints a comment to STDOUT, i.e. supplemental text regarded as non-essential.

  Formatting and transforms options: `:comment`

  ## Examples

      iex> comment("Objects are closer than they appear")
      Objects are closer than they appear
  """
  def comment(text, opts \\ []) when is_binary(text), do: transform_print(text, opts, :comment)

  @doc """
  Prints a dictionary term (dt) to STDOUT

  Formatting and transforms options: `:dt`

  ## Examples

      iex(5)> dt("Thonking", dt: ">>> " <> IO.ANSI.bright())
      >>> Thonking
  """
  def dt(text, opts \\ []) when is_binary(text), do: transform_print(text, opts, :dt)

  @doc """
  Prints a dictionary definition (dd) to STDOUT

  Formatting and transforms options: `:dd`
  """
  def dd(text, opts \\ []) when is_binary(text), do: transform_print(text, opts, :dd)

  @doc """
  Prints a demonstration of all output functions for visual inspection, useful when you
  are tweaking your styling.

  ## Examples
      iex> demo
  """
  def demo do
    h1("Cowrie Formatting h1/2")
    h2("Common Outputs h2/2)")
    line("This is a line of text line/2")
    info("This is an informational message info/2")
    warning("This is a warning/2")
    error("This is an error/2")
    line("Here comes an hr/2:")
    hr()
    h2("Alerts h2/2")
    alert("This is an info alert", type: :info)
    alert("This is a warning alert", type: :warning)
    alert("This is a danger alert", type: :danger)
    alert("This is a success alert", type: :success)
    hr()
    h2("Lists h2/2")
    ul(["This is", "an unordered", "list via ul/2"])
    br()
    ol(["This is", "an ordered", "list via ol/2"])
    hr()
    h2("Tables h2/2")
    table([["Max", "Mao", "Brutus"], ["Fido", "Whiskers", "Wilbur"]], ["Dogs", "Cats", "Pigs"])
    hr()
    h2("Definitions h2/2")
    dt("This is a term dt/2")
    dd("This is a term definition dd/2")
    hr()
    h2("Prompts h2/2")

    # We simulate these so we can inspect the formatting by using STDOUT instead of the various input streams
    transform_print("prompt/2 What's your name?", [], :prompt)
    transform_print("yes?/2 Ok to continue?", [], :yes?)
    transform_print("secret/2 Password:", [], :secret)
    hr()
    h2("Spinners h2/2")
    spinner(fn -> Process.sleep(:timer.seconds(5)) end)
    br()
  end

  @doc """
  Prints an error message to STDERR.

  Formatting and transforms options: `:error`
  """
  def error(text, opts \\ []) when is_binary(text),
    do: transform_print(text, opts, :error, :stderr)

  @doc """
  Prints a primary heading (h1) to STDOUT.

  Formatting and transforms options: `:h1`

  ## Examples

  Normally, you would put your pre- and post-transformation functions in your config, but you
  can pass them as arguments if you really want to:

      iex> h1("This is awesome!", pre_transforms: %{h1: &Cowrie.Transforms.upcase/2})

      THIS IS AWESOME!
  """
  def h1(text, opts \\ []) when is_binary(text), do: transform_print(text, opts, :h1)

  @doc """
  Prints a secondary heading (h2) to STDOUT.

  Formatting and transforms options: `:h2`
  """
  def h2(text, opts \\ []) when is_binary(text), do: transform_print(text, opts, :h2)

  @doc """
  Prints a horizontal rule (hr) to STDOUT.

  Formatting options:

  - `:hr` for the line as a whole
  - `:hr_char` specifies the character(s) to be repeated to form the line.
  - `:hr_padding` number of whitespace columns

  Transform key: `:hr`

  ## Examples

      iex> hr(hr_char: "~", hr_padding: 0)
                    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  """
  def hr(opts \\ []) do
    opts = Keyword.put(opts, :hr_padding, config(opts, :hr_padding))

    opts
    |> config(:hr_char)
    |> pre_transform(opts, :hr)
    |> format(opts, :hr)
    |> post_transform(opts, :hr)
    |> out(:stdout)
  end

  @doc """
  Prints informational text to STDOUT.

  Formatting and transforms options: `:info`
  """
  def info(text, opts \\ []) when is_binary(text), do: transform_print(text, opts, :info)

  @doc """
  Prints a line of "unformatted" text to STDOUT.

  Formatting and transforms options: `:line`
  """
  def line(text, opts \\ []) when is_binary(text), do: transform_print(text, opts, :line)

  @doc """
  Prints an ordered list of items (ul) to STDOUT.

  - `:ol_start` the integer used to start the lists. Default: 1
  - `:li` for formatting the individual list items.

  Pre- and post-transform key: `:ol_li`

  ## Examples

      iex> ol(["do", "re", "mi"])
      1. do
      2. re
      3. mi
  """
  def ol(items, opts \\ []) when is_list(items) do
    items
    |> Enum.with_index(config(opts, :ol_start))
    |> Enum.each(fn {li, index} ->
      opts = Keyword.put(opts, :n, index)

      li
      |> pre_transform(opts, :ol_li)
      |> format(opts, :li)
      |> post_transform(opts, :ol_li)
      |> out(:stdout)
    end)
  end

  @doc """
  Prompts the user for input. Input will be consumed until Enter is pressed.
  *Careful:* the returned value will include a newline (`\\n`)!

  Formatting and transforms options: `:prompt`
  """
  @spec prompt(text :: binary, opts :: keyword) :: binary
  def prompt(text, opts \\ []) when is_binary(text), do: transform_print(text, opts, :h1, :prompt)

  @doc """
  The user's input will not be visible to them as they type in the console.
  This method is useful when asking for sensitive information such as a password.

  Formatting and transforms options: `:secret`
  """
  @spec secret(text :: binary, opts :: keyword) :: binary
  def secret(text, opts \\ []) when is_binary(text) do
    transform_print(text, opts, :secret, :secret)
    # This erlang library returns a charlist
    :io.get_password()
    |> List.to_string()
  end

  @doc """
  Displays a spinner animation which offers visual feedback appropriate for long-
  running.  Displaying a spinner animation is most appropriate for tasks which do
  not provide their own console messaging or when you wish to silence the task's
  own messaging.

  The callback function must be a zero-arity anonymous function.

  Note: the task being executed should avoid any use of `IO.puts` and instead
  rely on `Mix.shell().info`; all console messages logged by the callback
  will be silenced via `Mix.Shell.Quiet`.

  ## Examples

  Using the function capture notation `&`:

      iex> spinner(&Heavy.work/0)

  Using an anonymous function:

      iex> spinner(fn -> Heavy.work() end)

  As used in the demo:

      iex> spinner(fn -> Process.sleep(:timer.seconds(5)) end)
  """
  def spinner(callback, opts \\ []) when is_function(callback) do
    spinner_module = config(opts, :spinner_module)
    cols = config(opts, :cols)
    timeout = config(opts, :timeout, :infinity)
    pid = spawn(fn -> spinner_module.start(cols: cols) end)

    task =
      Task.async(fn ->
        shell = Mix.shell()
        Mix.shell(Mix.Shell.Quiet)
        callback.()
        Mix.shell(shell)
      end)

    Task.await(task, timeout)
    Process.exit(pid, :kill)
  end

  @doc """
  Prints a table with the given rows to STDOUT (headers are optional).

  The first argument should be a list of lists, where each internal list represents a row of data.
  The second argument should be a list of headers -- the length of this list
  should match the length of the lists passed as rows.

  Formatting options:
  - `:th` for header cells
  - `:td` for data cells

  Transforms:
  - `:th` for header cells
  - `:td` for data cells

  ## Examples:

      iex(12)> table([["Max", "Mao", "Brutus"], ["Fido", "Whiskers", "Wilbur"]], ["Dogs", "Cats", "Pigs"])
      +------+----------+--------+
      | Dogs | Cats     | Pigs   |
      +------+----------+--------+
      | Max  | Mao      | Brutus |
      | Fido | Whiskers | Wilbur |
      +------+----------+--------+
  """
  def table(rows, headers \\ [], opts \\ []) when is_list(rows) and is_list(headers) do
    headers =
      headers
      |> Enum.map(fn th ->
        th
        |> pre_transform(opts, :th)
        |> format(opts, :th)
      end)

    rows
    |> Enum.map(fn tr ->
      tr
      |> Enum.map(fn td ->
        td
        |> pre_transform(opts, :td)
        |> format(opts, :td)
      end)
    end)
    |> TableRex.quick_render!(headers)
    |> out(:stdout)
  end

  @doc """
  Prints an unordered list of items (ul) to STDOUT.

  - `:li_bullet` the character used to denote each list item. Default: `-`
  - `:li` for formatting the individual list items.

  Transform key for each list item: `:ul_li`

  ## Examples

      iex(13)> ul(["Sunlight", "Water", "Soil"])
      - Sunlight
      - Water
      - Soil

      iex(14)> ul(["Sunlight", "Water", "Soil"], li_bullet: ">")
      > Sunlight
      > Water
      > Soil
  """
  def ul(items, opts \\ []) when is_list(items) do
    # Pass our config along to the transform function
    opts = Keyword.put(opts, :li_bullet, config(opts, :li_bullet))

    Enum.each(
      items,
      fn li ->
        li
        |> pre_transform(opts, :ul_li)
        |> format(opts, :li)
        |> out(:stdout)
      end
    )
  end

  @doc """
  Prints a warning to STDOUT.

  Formatting and transforms options: `:warning`
  """
  def warning(text, opts \\ []) when is_binary(text), do: transform_print(text, opts, :warning)

  @doc """
  Prompts the user to continue with a simple `Yes` or `No`.
  """
  @spec yes?(text :: binary, opts :: keyword) :: binary
  def yes?(text, opts \\ []) when is_binary(text), do: transform_print(text, opts, :yes?, :yes?)

  ################################################
  defp color_swatch_text(index, nil) do
    IO.ANSI.color(index) <>
      "████████████████████ Sample Text #{reset()} IO.ANSI.color(#{index}) -- no RBB alternative --"
  end

  defp color_swatch_text(index, {r, g, b}) do
    IO.ANSI.color(index) <>
      "████████████████████ Sample Text #{reset()} IO.ANSI.color(#{index}) or IO.ANSI.color(#{r}, #{
        g
      }, #{b})"
  end

  # Read from config, defer to opts
  defp config(opts, key, default \\ "") do
    Keyword.get(
      opts,
      key,
      Application.get_env(:cowrie, key, Map.get(@default_styles, key, default))
    )
  end

  # Applies any configured ANSI formatting to text with formatting reset
  defp format(text, opts, key) do
    "#{config(opts, key)}#{text}#{reset()}"
  end

  # Applies the transformation(s) to the text
  defp pre_transform(text, opts, key) do
    opts
    |> config(:pre_transforms)
    |> Map.get(key, @default_transform)
    |> List.wrap()
    |> Enum.reduce(text, fn
      callback, x when is_function(callback) ->
        apply(callback, [x, opts])

      _, x ->
        Logger.error("Pre-transform for key #{key} must be a function.")
        x
    end)
  end

  defp post_transform(text, opts, key) do
    opts
    |> config(:post_transforms)
    |> Map.get(key, @default_transform)
    |> List.wrap()
    |> Enum.reduce(text, fn
      callback, x when is_function(callback) ->
        apply(callback, [x, opts])

      _, x ->
        Logger.error("Post-transform for key #{key} must be a function.")
        x
    end)
  end

  # Resets any applied ANSI formatting so the next line starts fresh.
  defp reset, do: IO.ANSI.default_background() <> IO.ANSI.normal() <> IO.ANSI.reset()

  # The base functions to route to STDOUT, STDERR, and some other Mix.Shell callbacks
  defp out(text, :stdout), do: Mix.shell().info("#{text}#{reset()}")
  defp out(text, :stderr), do: Mix.shell().error("#{text}#{reset()}")
  defp out(text, :prompt), do: Mix.shell().prompt("#{text}#{reset()}")
  defp out(text, :yes?), do: Mix.shell().yes?("#{text}#{reset()}")
  defp out(text, :secret), do: IO.write("#{text}#{reset()}")

  # Applies a transformation, applies formatting, then prints to STDOUT
  # Most functions will use the same key for formatting and transformations.
  defp transform_print(text, opts, key, stream \\ :stdout) do
    text
    |> pre_transform(opts, key)
    |> format(opts, key)
    |> post_transform(opts, key)
    |> out(stream)
  end
end
