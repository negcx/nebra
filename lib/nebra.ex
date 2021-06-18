defmodule Nebra do
  def compile(code) do
    {:ok, code} = Lexer.lex_and_parse(code)
    compiled = Compiler.compile(code)

    if IEx.started?() do
      IO.puts(compiled)
    end

    compiled
  end

  def load_module(bindings, name, module) do
    mod_functions =
      module.__info__(:functions)
      |> Enum.reduce(%{}, fn {fun, arity}, acc ->
        acc
        |> Map.put(Atom.to_string(fun) <> to_string(arity), Function.capture(module, fun, arity))
      end)

    bindings |> Map.merge(%{name => mod_functions})
  end

  def go(code, bindings \\ %{}) do
    if String.length(String.trim(code)) > 0 do
      compiled_code = compile(code)
      IO.puts(compiled_code)

      if String.length(compiled_code) > 0 do
        {result, bindings} = compiled_code |> Code.eval_string(s: bindings)

        {result, bindings[:s]}
      else
        {nil, bindings}
      end
    else
      {nil, bindings}
    end
  end

  def repl do
    bindings = load_module(%{}, "Map", Map)
    repl(s: bindings)
  end

  def repl(bindings) do
    code = IO.gets("nebra> ")

    try do
      {result, bindings} = compile(code) |> Code.eval_string(bindings)
      IO.inspect(result)
      repl(bindings)
    rescue
      e ->
        IO.inspect(e, label: "Exception")
        repl(bindings)
    end
  end
end
