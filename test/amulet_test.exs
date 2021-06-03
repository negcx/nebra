defmodule AmuletTest do
  use ExUnit.Case
  doctest Amulet

  test "Let's do it" do
    code = """
    ? = items => {
        recurse = (hd, remaining) => {
            if(hd == null or hd == undefined and remaining != []) {
                recurse(remaining->hd(), remaining->tail())
            }
            else hd // A comment here
        }
        recurse(items->hd(), items->tail()) // recurse it up
    }

    /* Just adding a block comment */

    s = "A string here!"

    map_literal = {
      [s]: "A value",
      another_key: 3, // Trailing commas are ok.
    }

    unwrap = (i, f) => {
        if(i != null and i != undefined) f()
        else undefined
    }
    """

    tokens =
      Lexer.lexer(code)
      |> Lexer.strip(:whitespace)
      |> Lexer.strip(:comment)
      |> Lexer.strip(:block_comment)
  end
end
