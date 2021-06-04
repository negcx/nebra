defmodule CompilerTest do
  use ExUnit.Case

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
end
