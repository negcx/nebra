defmodule KernelTest do
  use ExUnit.Case

  test "Kernel put_in test" do
    assert Nebra.Kernel.put_in(%{}, ["hello", "there", "bob"], 5) == %{
             "hello" => %{"there" => %{"bob" => 5}}
           }
  end
end
