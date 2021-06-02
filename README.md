block             (statement | expression)*

statement         ID = expression

expression        ID
                  | literal
                  | if-else
                  | function
                  | function call