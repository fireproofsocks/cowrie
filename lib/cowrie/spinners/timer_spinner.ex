defmodule Cowrie.TimerSpinner do
  @moduledoc """
  This module implements an animation (a spinner) which includes an HH:MM:SS
  timer to show elapsed time.

  Warning: this spinner does not display properly when the screen becomes too
  narrow!
  """
  use Gettext, backend: Cowrie.Gettext

  @behaviour Cowrie.SpinnerBehaviour

  # The character repeated for the animation
  @char "═"
  # How many instances of each color variation
  @char_repeat 3
  # How many milliseconds to wait between ticks
  @pause 20
  # The generator series
  @colors [1, 2, 3, 4, 5, 4, 3, 2, 1]

  @impl Cowrie.SpinnerBehaviour
  def start(opts) when is_list(opts) do
    cols = Keyword.get(opts, :cols, 80) - 20
    bar_as_list = List.duplicate(" ", cols) ++ Enum.map(@colors, &bit/1)
    tick(bar_as_list, 0, :os.system_time(:second))
  end

  defp tick([head | tail] = bar, i, unix_start_time) do
    elapsed_seconds = :os.system_time(:second) - unix_start_time
    IO.write("\r#{bar} #{reset()}#{gettext("Elapsed")}: #{secs_to_clock(elapsed_seconds)}")
    Process.sleep(@pause)
    tick(tail ++ [head], i + 1, unix_start_time)
  end

  defp secs_to_clock(elapsed_seconds) do
    ss =
      rem(elapsed_seconds, 60)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    mm =
      div(elapsed_seconds, 60)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    hh =
      div(elapsed_seconds, 3600)
      |> Integer.to_string()
      |> String.pad_leading(2, "0")

    "#{hh}:#{mm}:#{ss}"
  end

  defp bit(n) do
    IO.ANSI.color(0, 0, n) <> String.duplicate(@char, @char_repeat)
  end

  defp reset do
    IO.ANSI.default_background() <> IO.ANSI.normal() <> IO.ANSI.reset()
  end
end
