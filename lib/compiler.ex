defmodule Compiler do
  @symbol_t "s"

  require Compiler.Macros
  import Compiler.Macros

  def compile({:start, _, children}) do
    children
    |> Enum.map(&Task.async(fn -> compile(&1) end))
    |> Enum.map(&Task.await/1)
    |> Enum.join("\n")
  end

  def compile({:block, _, children}) do
    children
    |> Enum.map(&compile/1)
    |> Enum.join("\n")
  end

  def compile([child | ast]), do: compile(child) <> compile(ast)
  def compile([]), do: ""

  def compile({:id, %{assign: true}, id}), do: ["#{quotes(id)}"]
  def compile({:id, %{map: true}, id}), do: quotes(id)
  def compile({:id, %{dispatch: true}, id}), do: quotes(id)

  def compile({:id, _metadata, id}), do: "#{@symbol_t}[#{quotes(id)}]"

  def compile({:+, _, [left, right]}),
    do: "(Nebra.Kernel.add(#{compile(left)}, #{compile(right)}))"

  binary_op(:-)
  binary_op(:/)
  binary_op(:*)
  binary_op(:and)
  binary_op(:or)
  binary_op(:==)
  binary_op(:!=)
  binary_op(:>)
  binary_op(:<)
  binary_op(:>=)
  binary_op(:<=)
  binary_op(:++)
  unary_op(:-)
  unary_op(:not)

  def compile({:"()", _, [f, params]}) do
    call_params =
      params
      |> Enum.map(&compile/1)
      |> Enum.join(", ")

    compile(f) <> ".(" <> call_params <> ")"
  end

  def compile({:->, _, [self, method, params]}) do
    call_params =
      params
      |> Enum.map(&compile/1)
      |> Enum.join(", ")

    compiled_self = compile(self)

    compiled_method = compile(apply_metadata(method, dispatch: true))

    "Nebra.Kernel.dispatch((#{compiled_self}), #{compiled_method}, [#{call_params}])"
  end

  def compile(i) when is_integer(i), do: Integer.to_string(i)
  def compile(n) when is_float(n), do: Float.to_string(n)
  def compile(s) when is_binary(s), do: quotes(s)
  def compile({true, _}), do: "true"
  def compile({false, _}), do: "false"
  def compile({:null, _}), do: "nil"

  def compile({:"[]", _, elements}) do
    inside =
      elements
      |> Enum.map(&compile/1)
      |> Enum.join(", ")

    "[ #{inside} ]"
  end

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
    do: [quotes(left_id), quotes(right_id)]

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

    first_item = hd(path)

    path = Enum.join(path, ", ")

    "(#{@symbol_t} = Nebra.Kernel.put_in(#{@symbol_t}, [#{path}], #{compile(right)}))[#{first_item}]"
  end

  def compile({:{}, _, []}), do: "%{}"

  def compile({:{}, _, children}) do
    inner =
      children
      |> Enum.map(&compile/1)
      |> Enum.join(", ")

    "%{ #{inner} }"
  end

  def compile({:"{}_child", _, [key, value]}),
    do: "#{compile(apply_metadata(key, map: true))} => #{compile(value)}"

  def compile({:if, _, [condition, expr]}),
    do: "if #{compile(condition)} do\n#{compile(expr)}\nend"

  def compile({:if, _, [condition, expr, else_expr]}),
    do: "if #{compile(condition)} do\n#{compile(expr)}\nelse\n#{compile(else_expr)}\nend"

  def compile({:cond_block, _, children}) do
    expressions = children |> Enum.map(&compile/1) |> Enum.join("\n")
    "cond do\n#{expressions}\nend"
  end

  def compile({:cond, _, [condition, expr]}),
    do: "#{compile(condition)} ->\n#{compile(expr)}"

  defp quotes(s), do: "\"" <> s <> "\""

  defp apply_metadata({token, old_metadata, children}, new_metadata) do
    {token, Map.merge(old_metadata, Enum.into(new_metadata, %{})), children}
  end

  defp apply_metadata(node, _new_metadata), do: node
end
