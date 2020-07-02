# This script generates a map of all ANSI color_map so that the `IO.ANSI.color/1` and
# the `IO.ANSI.color/3` variants appear side-by-side
#
# To run:
# mix run scripts/color_map.exs

default = %{
  index: nil,
  rgb: nil
}
color_map = Enum.reduce(
  0..255,
  %{},
  fn color, acc ->
    key = IO.ANSI.color(color)
    record = Map.get(acc, key, default)
    record = Map.put(record, :index, color)
    Map.put(acc, key, record)
  end
)

color_map = Enum.reduce(0..5, color_map, fn r, acc1 ->
  Enum.reduce(0..5, acc1, fn g, acc2 ->
    Enum.reduce(0..5, acc2, fn b, acc3 ->
      key = IO.ANSI.color(r, g, b)
      record = Map.get(acc3, key, default)
      record = Map.put(record, :rgb, {r, g, b})
      Map.put(acc3, key, record)
    end)
  end)
end)


color_map
|> Map.values()
|> Enum.sort_by(fn(r) -> r[:index] end, &<=/2)
|> IO.inspect(limit: :infinity)

