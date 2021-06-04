defmodule CompilerTest do
  use ExUnit.Case

  test "Complex map access" do
    assert {"Hello, it works.", _} =
             Nebra.go("""
             x["hello"] = "greeting";
             y.greeting = "Hello, it works.";
             y[x.hello]
             """)
  end
end
