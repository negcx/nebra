# nebra
A sandboxed language in Elixir that has support for functions, maps, and lists. You can create bindings to Elixir code and safely call it from Nebra code. Nebra does not expose anything to the sandbox without you explicitly exposing those functions. In addition, Nebra does not allow the user to create atoms or other dynamics that would potentially cause the BEAM to crash.

block             (statement | expression)*

statement         ID = expression

expression        ID
                  | literal
                  | if-else
                  | function
                  | function call
