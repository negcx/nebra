defmodule KernelTest do
  use ExUnit.Case

  test "Kernel put_in test" do
    assert Nebra.Kernel.put_in(%{}, ["hello", "there", "bob"], 5) == %{
             "hello" => %{"there" => %{"bob" => 5}}
           }
  end

  test "Put a map where there was a regular key" do
    map = Nebra.Kernel.put_in(%{}, ["hello", "there"], 5)
    map = Nebra.Kernel.put_in(map, ["hello", "there", "bob"], 10)

    assert map == %{"hello" => %{"there" => %{"bob" => 10}}}
  end
end
