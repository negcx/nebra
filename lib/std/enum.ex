defmodule Std.Enum do
  def map(e, f) when is_list(e), do: Enum.map(e, f)

  def map(e, f) when is_map(e),
    do: Enum.map(e, fn {k, v} -> f.(k, v) end)

  def reduce(enum, initial, f) when is_list(enum), do: Enum.reduce(enum, initial, f)

  def reduce(enum, initial, f) when is_map(enum),
    do: Enum.reduce(enum, initial, fn {k, v}, acc -> f.(k, v, acc) end)

  def nebra do
    %{
      "Enum" => %{
        "map" => &map/2,
        "reduce" => &reduce/3
      }
    }
  end
end
