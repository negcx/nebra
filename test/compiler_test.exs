defmodule CompilerTest do
  use ExUnit.Case

  test "Basic . pattern" do
    assert Nebra.compile("x1.x2.x3.x4") ==
             """
             s["x1"]["x2"]["x3"]["x4"]
             """
             |> String.trim_trailing("\n")

    assert Nebra.compile("blah().x1.x2") ==
             """
             s["blah"].()["x1"]["x2"]
             """
             |> String.trim_trailing("\n")
  end

  test "Complex map access" do
    assert {"Hello, it works.", _} =
             Nebra.go("""
             x["hello"] = "greeting";
             y.greeting = "Hello, it works.";
             y[x.hello]
             """)

    assert {"A demon wrote this code", _} =
             Nebra.go("""
             (x)["hello"] = "greeting";
             (y).greeting = "Hello, it works.";
             (((y)[(x).hello]).x)[(y.greeting)] = "A demon wrote this code";
             (((y)["greeting"])["x"])["Hello, it works."]
             """)
  end

  test "Order of operations" do
    {result, _} = Nebra.go("(3 + 5) * 6 + 9 * 45")
    assert result == (3 + 5) * 6 + 9 * 45
  end
end
