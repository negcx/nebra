defmodule Nebra.Kernel do
  def put_in(data, keys, value), do: put_in(data, keys, value, [])

  defp put_in(data, [head], value, path),
    do: Kernel.put_in(data, path ++ [head], value)

  defp put_in(data, [head | tail], value, path = path) do
    {_, data} =
      get_and_update_in(data, path ++ [head], fn
        value when is_map(value) -> {value, value}
        value -> {value, %{}}
      end)

    put_in(data, tail, value, path ++ [head])
  end

  def dispatch(self, method, args),
    do: apply(self[method], [self | args])

  def add(left, right) when is_binary(left) and is_binary(right),
    do: left <> right

  def add(left, right)
      when (is_integer(left) or is_float(left)) and (is_integer(right) or is_float(right)),
      do: left + right

  def add(left, right) when is_list(left) and not is_list(right),
    do: left ++ [right]

  def add(left, right) when is_list(left) and is_list(right),
    do: left ++ right

  def add(left, right) when not is_list(left) and is_list(right),
    do: [left | right]
end
