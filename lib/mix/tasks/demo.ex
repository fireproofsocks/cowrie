defmodule Mix.Tasks.Cowrie.Demo do
  @moduledoc false

  use Mix.Task

  import Cowrie

  @shortdoc false

  def run(_) do
    # spinner(fn -> Process.sleep(:timer.seconds(5)) end)
    # demo()
    # prompt("Are you sure?")

    if yes?("Ok?") do
      IO.puts("OK...")
    end
  end
end
