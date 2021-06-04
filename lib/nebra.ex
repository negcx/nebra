defmodule Nebra do
  def compile(code) do
    {:ok, code} = Lexer.lex_and_parse(code)
    compiled = Compiler.compile(code)
    IO.puts(compiled)
    compiled
  end

  def go(code) do
    compile(code) |> Code.eval_string()
  end
end
