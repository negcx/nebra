defmodule Lexer.Helpers do
  defmacro lex(input, output) do
    case String.length(input) do
      1 ->
        quote do
          defp lexer([{unquote(input), metadata} | rest], token, tokens) do
            lexer(rest, nil, tokens ++ finalize_token(token) ++ [{unquote(output), metadata}])
          end
        end

      2 ->
        [char1, char2] = String.graphemes(input)

        quote do
          defp lexer(
                 [{unquote(char1), metadata}, {unquote(char2), _metadata} | rest],
                 token,
                 tokens
               ) do
            lexer(rest, nil, tokens ++ finalize_token(token) ++ [{unquote(output), metadata}])
          end
        end
    end
  end

  defmacro string_lex(input, output) do
    case String.length(input) do
      1 ->
        quote do
          defp string_lexer([{unquote(input), metadata} | rest], string) do
            string_lexer(rest, string <> unquote(output))
          end
        end

      2 ->
        [char1, char2] = String.graphemes(input)

        quote do
          defp string_lexer(
                 [{unquote(char1), metadata}, {unquote(char2), _metadata} | rest],
                 string
               ) do
            string_lexer(rest, string <> unquote(output))
          end
        end
    end
  end

  
end
