defmodule ParserTest do
  use ExUnit.Case

  test "Yecc a few statements and a function call" do
    code = """
    x = a, b => {
      (a + b) * (a * b)
    };

    x (3,4)
    """

    IO.inspect(Lexer.lex_and_parse(code))
  end
end
