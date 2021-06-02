global = %{}

global = Map.put(global, "z", 5)

global =
  Map.put(global, "calc", fn arg1 ->
    scope1 = %{}
    scope1 = Map.put(scope1, "x", arg1 + 9)
    Map.get(scope1, "x") * 3 * Map.get(scope1, "z", Map.get(global, "z"))
  end)

calc = fn x ->
  x = x + 9
  x * 3
end

IO.puts(calc.(5))

IO.puts(global["calc"].(5))
