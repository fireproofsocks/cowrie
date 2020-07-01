defmodule Cowrie do
  @moduledoc """
  `Cowrie` helps you print beautiful and consistent Terminal output to the Shell
  using familiar functions inspired by HTML. All formatting is configurable,
  either via your application's configuration file, or as arguments to the
  output function. Sensible defaults are provided.

  All formatting styles rely on `IO.ANSI` formatting options, so you are free to
  research and apply your own styles to match your personal preference.

  ## Usage

  Use `Cowrie` functions in our custom `Mix.Task` -- importing them makes them
  easier to use.

  ```
  defmodule Mix.Tasks.MyApp.Example do
    use Mix.Task
    import Cowrie

    @shortdoc "Example mix task using Cowrie"


    def run(opts) do
      h1("My Custom Task")
      warning("The following issues were found:")
      ul(["Lions", "Tigers", "Bears"])
    end
  ```
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

  @doc """
  Prints an alert box of the specified type to STDOUT
  (think [Bootstrap alert boxes](https://getbootstrap.com/docs/4.0/components/alerts/)).

  Formatting options correspond to the given alert `type`:

  - `:alert_danger` for type `:danger`
  - `:alert_info` for type `:info`
  - `:alert_success` for type `:success`
  - `:alert_warning` for type `:warning`

  Transformation options are the same as the above.
  """
  def alert(text, type, opts \\ [])
      when is_binary(text) and type in [:danger, :info, :success, :warning] do
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
  """
  def br, do: transform_print("", [], :br)

  @doc """
  Outputs available ANSI colors, useful when you want to choose a color visually.
  You can specify a pattern for the output:
    - `:code` (default) lists indexed color codes from 0 to 255
    - `:rgb` lists colors in terms of individual red, green, and blue values
  """
  def colors(pattern \\ :code)

  def colors(:code) do
    Enum.each(
      0..255,
      fn color ->
        Mix.shell().info(
          "Color " <>
            String.pad_leading("#{color}", 3) <>
            ": " <>
            IO.ANSI.color(color) <>
            "████████████████████ Sample Text" <>
            reset()
        )
      end
    )
  end

  def colors(:rgb) do
    for r <- 0..5, g <- 0..5, b <- 0..5 do
      IO.puts(
        "RGB #{r},#{g},#{b}: " <>
          IO.ANSI.color(r, g, b) <>
          "████████████████████ Sample Text" <>
          reset()
      )
    end
  end

  @doc """
  Prints a comment to STDOUT, i.e. supplemental text regarded as non-essential.

  Formatting and transforms options: `:comment`
  """
  def comment(text, opts \\ []) when is_binary(text), do: transform_print(text, opts, :comment)

  @doc """
  Prints a dictionary term (dt) to STDOUT

  Formatting and transforms options: `:dt`
  """
  def dt(text, opts \\ []) when is_binary(text), do: transform_print(text, opts, :dt)

  @doc """
  Prints a dictionary definition (dd) to STDOUT

  Formatting and transforms options: `:dd`
  """
  def dd(text, opts \\ []) when is_binary(text), do: transform_print(text, opts, :dd)

  @doc """
  Prints an error message to STDERR.

  Formatting and transforms options: `:error`
  """
  def error(text, opts \\ []) when is_binary(text) do
    text
    |> pre_transform(opts, :error)
    |> format(opts, :error)
    |> stderr()
  end

  @doc """
  Prints a primary heading (h1) to STDOUT.

  Formatting and transforms options: `:h1`
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
    |> stdout()
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

  Transform key: `:ol_li`
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
      |> stdout()
    end)
  end

  @doc """
  Prompts the user for input. Input will be consumed until Enter is pressed.
  The returned value will include a `\n`.

  Formatting and transforms options: `:prompt`
  """
  @spec prompt(text :: binary, opts :: keyword) :: binary
  def prompt(text, opts \\ []) when is_binary(text) do
    text =
      text
      |> pre_transform(opts, :prompt)
      |> format(opts, :prompt)
      |> post_transform(opts, :prompt)

    Mix.shell().prompt("#{text}#{reset()}")
  end

  @doc """
  The user's input will not be visible to them as they type in the console.
  This method is useful when asking for sensitive information such as a password.

  Formatting and transforms options: `:secret`
  """
  @spec secret(text :: binary, opts :: keyword) :: binary
  def secret(text, opts \\ []) when is_binary(text) do
    text =
      text
      |> pre_transform(opts, :secret)
      |> format(opts, :secret)
      |> post_transform(opts, :secret)

    # Can't use info() because it adds a newline
    IO.write("#{text}#{reset()} ")

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

      iex> Cowrie.spinner(&Heavy.work/0)

  Using an anonymous function:

      iex> Cowrie.spinner(fn -> Heavy.work() end)
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
  Prints a demonstration of all output functions for visual evaluation.
  """
  def style_guide do
    h1("Cowrie Formatting h1/2")
    h2("Common Outputs h2/2)")
    line("This is a line of text line/2")
    info("This is an informational message info/2")
    warning("This is a warning/2")
    error("This is an error/2")
    line("Here comes an hr/2:")
    hr()
    h2("Alerts h2/2")
    alert("This is an info alert", :info)
    alert("This is a warning alert", :warning)
    alert("This is a danger alert", :danger)
    alert("This is a success alert", :success)
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
    br()
  end

  @doc """
  Prints a table with the given rows to STDOUT (headers are optional).

  Formatting options:
  - `:th` for header cells
  - `:td` for data cells

  Transforms:
  - `:th` for header cells
  - `:td` for data cells
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
    |> stdout()
  end

  @doc """
  Prints an unordered list of items (ul) to STDOUT.

  - `:ol_start` the integer used to start the lists. Default: 1
  - `:li` for formatting the individual list items.

  Transform key for each list item: `:ul_li`
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
        |> stdout()
      end
    )
  end

  @doc """
  Prints a warning to STDOUT.

  Formatting and transforms options: `:warning`
  """
  def warning(text, opts \\ []) when is_binary(text), do: transform_print(text, opts, :warning)

  @doc """
  Prompts the user for input. Input will be consumed until Enter is pressed.
  The returned value will include a `\n`.
  """
  @spec yes?(text :: binary, opts :: keyword) :: binary
  def yes?(text, opts \\ []) when is_binary(text) do
    text =
      text
      |> pre_transform(opts, :yes?)
      |> format(opts, :yes?)
      |> post_transform(opts, :yes?)

    Mix.shell().yes?("#{text}#{reset()}")
  end

  ################################################
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
  defp reset do
    IO.ANSI.default_background() <> IO.ANSI.normal() <> IO.ANSI.reset()
  end

  # The base function to print to STDERR
  defp stderr(text) do
    Mix.shell().error("#{text}#{reset()}")
  end

  # The base function to print to STDOUT with formatting reset
  defp stdout(text) do
    Mix.shell().info("#{text}#{reset()}")
  end

  # Applies a transformation, applies formatting, then prints to STDOUT
  # Most functions will use the same key for formatting and transformations.
  defp transform_print(text, opts, key) do
    text
    |> pre_transform(opts, key)
    |> format(opts, key)
    |> post_transform(opts, key)
    |> stdout()
  end
end
