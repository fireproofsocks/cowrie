defmodule CowrieTest do
  use ExUnit.Case

  import Cowrie

  setup do
    on_exit(fn ->
      Mix.shell().flush()
    end)
  end

  describe "error/2" do
    test "no formatting applied to error messages" do
      error("xyz")
      assert_received {:mix_shell, :error, ["xyz"]}
    end
  end
end
