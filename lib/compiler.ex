defmodule Compiler do
  @symbol_t "s"
  defp initial_code do
    """
    #{@symbol_t} = %{}
    """
  end

  def compile({:start, _, children}) do
    initial_code() <>
      (children
       |> Enum.map(&compile/1)
       |> Enum.join("\n"))
  end

  def compile({:block, _, children}) do
    children
    |> Enum.map(&compile/1)
    |> Enum.join("\n")
  end

  def compile([child | ast]), do: compile(child) <> compile(ast)
  def compile([]), do: ""

  def compile({:=, _metadata, [left, right]}) do
    stack = assign_stack(left) |> IO.inspect(label: "Stack")
    output = stack |> compile_assign_stack(compile(right))
    root_item = Enum.reverse(stack) |> hd()

    "Map.get(#{@symbol_t} = #{output}, #{root_item})"
  end

  def compile({:., _, _} = node) do
    access =
      dot_stack(node)
      |> Enum.reverse()
      |> Enum.map(fn item ->
        "Map.get(#{item})"
      end)
      |> Enum.join(" |> ")

    "(s |> #{access})"
  end

  def compile({:access, _, [{:id, _, id}, right]}) do
    "(s |> Map.get(\"#{id}\") |> Map.get(#{compile(right)}))"
  end

  def compile({:access, _, [left, right]}) do
    "(s |> #{compile(left)} |> Map.get(#{compile(right)}))"
  end

  def compile({:id, _metadata, id}), do: "Map.get(#{@symbol_t}, \"#{id}\")"

  def compile({:+, _, [left, right]}),
    do: compile(left) <> " + " <> compile(right)

  def compile({:"()", _, [f, params]}) do
    call_params =
      params
      |> Enum.map(&compile/1)
      |> Enum.join(", ")

    compile(f) <> ".(" <> call_params <> ")"
  end

  def compile(i) when is_integer(i), do: Integer.to_string(i)
  def compile(n) when is_float(n), do: Float.to_string(n)
  def compile(s) when is_binary(s), do: "\"" <> s <> "\""

  def compile({:"=>", metadata, [params, body]}) do
    {bindings, _} =
      params
      |> Enum.map(fn
        {:id, _, id} -> id
        _ -> raise "Invalid function parameter #{inspect(metadata)}"
      end)
      |> Enum.reduce({[], 0}, fn elem, {elems, index} ->
        {elems ++ [{"a#{index}", elem}], index + 1}
      end)

    fn_params =
      bindings
      |> Enum.map(&elem(&1, 0))
      |> Enum.join(", ")

    bindings_str =
      bindings
      |> Enum.map(fn {arg_name, s_name} ->
        "\"#{s_name}\" => #{arg_name}"
      end)
      |> Enum.join(", ")

    binding_body = "#{@symbol_t} = Map.merge(#{@symbol_t}, %{#{bindings_str}})"

    "(fn #{fn_params} -> #{binding_body}\n#{compile(body)} end)"
  end

  # Handle the case of assigning to a multi-nested map
  # on the left hand side. i.e. x.y.z = 3
  def dot_stack({:., _, [left, right]}) do
    dot_stack(right) ++ dot_stack(left)
  end

  def dot_stack({:id, _, id}), do: ["\"#{id}\""]

  def dot_stack(node), do: [compile(node)]

  def assign_stack({:., _, [left, right]}) do
    assign_stack(right) ++ assign_stack(left)
  end

  def assign_stack({:access, _, [left, right]}) do
    assign_stack(right) ++ assign_stack(left)
  end

  def assign_stack({:id, _, id}), do: ["\"#{id}\""]

  def assign_stack(node), do: [compile(node)]

  def compile_assign_stack([head], right),
    do: "#{@symbol_t} |> Map.put(#{head}, #{right})"

  def compile_assign_stack([head | tail], right) do
    path =
      Enum.reverse(tail)
      |> Enum.map(fn item ->
        " |> Map.get(#{item}, %{})"
      end)

    compile_assign_stack(tail, "s #{path} |> Map.put(#{head}, #{right})")
  end
end
