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

  def compile({:id, %{assign: true}, id}), do: ["#{quotes(id)}"]

  def compile({:id, _metadata, id}), do: "#{@symbol_t}[#{quotes(id)}]"

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
  def compile(s) when is_binary(s), do: quotes(s)

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

  def compile({:., %{assign: true}, [{:id, _, left_id}, {:id, _, right_id}]}),
    do: [left_id, right_id]

  def compile({:., _, [{:id, _, _} = left, {:id, _, right_id}]}),
    do: "#{compile(left)}[#{quotes(right_id)}]"

  def compile({:., %{assign: true}, [left, {:id, _, right_id}]}),
    do: [compile(apply_metadata(left, assign: true)), quotes(right_id)]

  def compile({:., _, [left, {:id, _, right_id}]}),
    do: "#{compile(left)}[#{quotes(right_id)}]"

  def compile({:., %{assign: true}, [left, right]}),
    do:
      [compile(apply_metadata(left, assign: true))] ++
        [compile(right)]

  def compile({:., _, [left, right]}),
    do: "#{compile(left)}[#{compile(right)}]"

  def compile({:=, _metadata, [left, right]}) do
    path =
      compile(apply_metadata(left, assign: true))
      |> List.flatten()
      |> Enum.join(", ")

    "#{@symbol_t} = put_in(#{@symbol_t}, [#{path}], #{compile(right)})"
  end

  defp quotes(s), do: "\"#{s}\""

  defp apply_metadata({token, old_metadata, children}, new_metadata) do
    {token, Map.merge(old_metadata, Enum.into(new_metadata, %{})), children}
  end

  defp apply_metadata(node, _new_metadata), do: node
end
