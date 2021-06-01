defmodule Lexer do
  require Lexer.Helpers
  import Lexer.Helpers

  @reserved %{
    "true" => true,
    "false" => false,
    "if" => :if,
    "else" => :else,
    "null" => :null,
    "undefined" => :undefined,
    "or" => :or,
    "and" => :and,
    "not" => :not
  }

  def code_with_metadata(code, metadata \\ []),
    do:
      code_with_metadata(
        String.graphemes(code),
        Keyword.merge([line: 1, column: 1], metadata),
        []
      )

  def code_with_metadata([], _, stack), do: stack

  def code_with_metadata(["\n" | rest], metadata, stack) do
    code_with_metadata(
      rest,
      Keyword.update!(metadata, :column, fn _ -> 1 end) |> Keyword.update!(:line, &(&1 + 1)),
      stack ++ [{"\n", metadata}]
    )
  end

  def code_with_metadata([head | rest], metadata, stack) do
    code_with_metadata(
      rest,
      Keyword.update!(metadata, :column, &(&1 + 1)),
      stack ++ [{head, metadata}]
    )
  end

  def finalize_token({:number, value, metadata}) do
    if String.contains?(value, ".") do
      [{String.to_float(value), metadata}]
    else
      [{String.to_integer(value), metadata}]
    end
  end

  def finalize_token(nil), do: []

  def finalize_token({:id, value, metadata}) do
    case Map.get(@reserved, value) do
      nil -> [{{:id, value}, metadata}]
      reserved -> [{reserved, metadata}]
    end
  end

  def finalize_token(t), do: [t]

  # Comments
  def lexer([{"/", metadata}, {"/", _} | rest], token, tokens) do
    {rest, comment} = comment_lexer(rest, "")
    lexer(rest, nil, tokens ++ finalize_token(token) ++ [{{:comment, comment}, metadata}])
  end

  def lexer([{"/", metadata}, {"*", _} | rest], token, tokens) do
    {rest, comment} = block_comment_lexer(rest, "")
    lexer(rest, nil, tokens ++ finalize_token(token) ++ [{{:block_comment, comment}, metadata}])
  end

  # Operators
  lex("=>", :"=>")
  lex("->", :->)
  lex("==", :==)
  lex("!=", :!=)
  lex("=", :=)
  lex(">=", :>=)
  lex("<=", :<=)
  lex(">", :>)
  lex("<", :<)
  lex(":", :":")
  lex("(", :"(")
  lex(")", :")")
  lex(".", :.)
  lex("+", :+)
  lex("-", :-)
  lex("/", :/)
  lex("*", :*)
  lex(",", :",")
  lex("{", :"{")
  lex("}", :"}")
  lex("[", :"[")
  lex("]", :"]")
  lex(" ", :whitespace)
  lex("\t", :whitespace)
  lex("\r\n", :newline)
  lex("\n", :newline)

  # Strings
  def lexer([{"\"", metadata} | rest], token, tokens) do
    {rest, string} = string_lexer(rest, "")
    tokens = tokens ++ finalize_token(token) ++ [{string, metadata}]
    lexer(rest, nil, tokens)
  end

  # Numbers and Identifiers
  def lexer([{char, metadata} | rest], nil, tokens) do
    if Enum.member?(String.graphemes("0123456789"), char) do
      lexer(rest, {:number, char, metadata}, tokens)
    else
      lexer(rest, {:id, char, metadata}, tokens)
    end
  end

  def lexer([{char, cmetadata} | rest], {:number, number, metadata}, tokens) do
    if Enum.member?(String.graphemes("0123456789."), char) do
      lexer(rest, {:number, number <> char, metadata}, tokens)
    else
      raise "Expected a number, got: #{char} at #{inspect(cmetadata)}"
    end
  end

  def lexer([{char, _meta} | rest], {:id, id, metadata}, tokens),
    do: lexer(rest, {:id, id <> char, metadata}, tokens)

  # EOF
  def lexer([], token, tokens),
    do: tokens ++ finalize_token(token)

  def lexer(code, metadata \\ []) do
    code = code_with_metadata(code, metadata)

    lexer(code, nil, [])
  end

  string_lex("\\\"", "\"")
  string_lex("\\n", "\n")
  string_lex("\\\\", "\\")
  string_lex("\\t", "\t")
  string_lex("\\r", "\r")
  def string_lexer([{"\"", _meta} | rest], string), do: {rest, string}
  def string_lexer([], string), do: raise("Expected end quote \", string: #{string}")
  def string_lexer([{char, _meta} | rest], string), do: string_lexer(rest, string <> char)

  def comment_lexer([], comment), do: {[], comment}
  def comment_lexer([{"\n", _} | _] = rest, comment), do: {rest, comment}
  def comment_lexer([{c, _} | rest], comment), do: comment_lexer(rest, comment <> c)

  def block_comment_lexer([], _comment), do: raise("Expected end of block comment")
  def block_comment_lexer([{"*", _}, {"/", _} | rest], comment), do: {rest, comment}
  def block_comment_lexer([{c, _} | rest], comment), do: block_comment_lexer(rest, comment <> c)

  def strip_token({{token, _}, _}, type), do: token != type
  def strip_token({token, _}, type), do: token != type

  def strip(tokens, type) do
    tokens
    |> Enum.filter(&strip_token(&1, type))
  end
end
