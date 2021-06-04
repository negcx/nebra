defmodule Nebra.Kernel do
  def put_in(data, keys, value), do: put_in(data, keys, value, [])

  defp put_in(data, [head], value, path),
    do: Kernel.put_in(data, path ++ [head], value)

  defp put_in(data, [head | tail], value, path = path) do
    {_, data} =
      get_and_update_in(data, path ++ [head], fn
        nil -> {nil, %{}}
        value -> {value, value}
      end)

    put_in(data, tail, value, path ++ [head])
  end
end
