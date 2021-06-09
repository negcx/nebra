defmodule Nebra do
  def compile(code) do
    {:ok, code} = Lexer.lex_and_parse(code)
    compiled = Compiler.compile(code)

    if IEx.started?() do
      IO.puts(compiled)
    end

    compiled
  end

  def go(code, bindings \\ %{}),
    do: compile(code) |> Code.eval_string(s: bindings)
end
