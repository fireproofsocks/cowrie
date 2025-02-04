defmodule Cowrie.Transforms do
  @moduledoc """
  Defines functions that _transform_ (a.k.a. mutate) text. These functions do
  not print the text and they do not apply ANSI formatting.
  """
  use Gettext, backend: Cowrie.Gettext

  @doc """
  Prepends a Danger emoji to the given text.
  """
  def alert_danger(text, _opts), do: box("☠️  #{gettext("Danger!")}️ #{text}")

  @doc """
  Prepends an Info emoji to the given text.
  """
  def alert_info(text, _opts), do: box("ℹ️  #{gettext("Info:")}️ #{text}")

  @doc """
  Prepends a Success emoji to the given text.
  """
  def alert_success(text, _opts), do: box("☑️  #{gettext("Success!")}️ #{text}")

  @doc """
  Prepends a Warning emoji to the given text.
  """
  def alert_warning(text, _opts), do: box("⚠️  #{gettext("Warning!")}️ #{text}")

  @doc """
  Appends a newline to the text.
  """
  def append_newline(text, _opts), do: text <> "\n"

  @doc """
  Draws a box around the given text. The text must be less than one line and
  it should not contain newlines.

  Available configuration:

  `:box_chars` - a map with keys containing for the top(t), top-right(tr),
  right (right), bottom-right (br), bottom (b), bottom-left (bl), left (l),
  and top-left (tl) characters to be used when drawing the box.

  Default:
        %{
          t: "═",
          tr: "╗",
          r: "║",
          br: "╝",
          b: "═",
          bl: "╚",
          l: "║",
          tl: "╔"
        }

  `:box_padding` - integer representing the number of columns of empty space between
  the box's left and right borders and the text, default: `1`
  """
  def box(text, opts \\ []) when is_binary(text) do
    # See https://theasciicode.com.ar/ for box-drawing codes
    box_chars =
      Keyword.get(opts, :box_chars, %{
        t: "═",
        tr: "╗",
        r: "║",
        br: "╝",
        b: "═",
        bl: "╚",
        l: "║",
        tl: "╔"
      })

    padding = Keyword.get(opts, :box_padding, 1)
    length = String.length(text)

    box_chars.tl <>
      String.duplicate(box_chars.t, length + padding * 2) <>
      box_chars.tr <>
      "\n" <>
      box_chars.r <>
      String.duplicate(" ", padding) <>
      text <>
      String.duplicate(" ", padding) <>
      box_chars.l <>
      "\n" <>
      box_chars.bl <> String.duplicate(box_chars.b, length + padding * 2) <> box_chars.br
  end

  @doc """
  A wrapper for `String.capitalize/2`
  """
  def capitalize(text, _opts \\ []), do: String.capitalize(text)

  @doc """
  Centers the given text using the configured column width (:cols)
  """
  def center(text, opts \\ []) when is_binary(text) do
    cols = Keyword.get(opts, :cols, 80)
    length = String.length(text)
    l_pad = div(cols - length, 2)
    r_pad = cols - (l_pad + length)
    String.duplicate(" ", l_pad) <> text <> String.duplicate(" ", r_pad)
  end

  @doc """
  A wrapper for `String.downcase/2`
  """
  def downcase(text, _opts), do: String.downcase(text)

  @doc """
  Creates a horizontal line
  """
  def hr(char, opts) do
    cols = Keyword.get(opts, :cols, 80)
    pad_cnt = Keyword.get(opts, :hr_padding, 2)
    pad = String.duplicate(" ", pad_cnt)
    pad <> String.duplicate(char, cols - 2 * pad_cnt) <> pad
  end

  @doc """
  Formats a list item for an ordered list by applying the `:n` character.
  """
  def ol_li(text, opts) when is_binary(text) do
    n = Keyword.get(opts, :n, 1)
    "#{n}. #{text}"
  end

  @doc """
  Prepends a newline to the text.
  """
  def prepend_newline(text, _opts), do: "\n" <> text

  @doc """
  Formats a list item for an unordered list by applying the `:li_bullet` character.
  """
  def ul_li(text, opts) when is_binary(text) do
    bullet = Keyword.get(opts, :li_bullet, "-")
    "#{bullet} #{text}"
  end

  @doc """
  A wrapper for `String.upcase/2`
  """
  def upcase(text, _opts), do: String.upcase(text)
end
