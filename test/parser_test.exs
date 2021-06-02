defmodule ParserTest do
  use ExUnit.Case

  defp lex(code) do
    Lexer.lexer(code)
    |> Lexer.strip(:whitespace)
    |> Lexer.strip(:comment)
    |> Lexer.strip(:block_comment)
  end

  test "Simple calculation" do
    assert = {:*, _, [{:+, _, [3, 4]}, {:+, _, [5, 9]}]} = Parser.parse(lex("(3 + 4) * (5 + 9)"))
  end
end
