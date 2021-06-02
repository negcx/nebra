Nonterminals E.
Terminals '+' '*' '(' ')' int number.
Rootsymbol E.
Endsymbol '$end'.

Left 100 '+'.
Left 200 '*'.
E -> E '+' E : {'$2', ['$1', '$3']}.
E -> E '*' E : {'$2', ['$1', '$3']}.
E -> '(' E ')' : '$2'.
E -> int : value_of('$1').
E -> number : value_of('$1').

Erlang code.
value_of({_Token, _Metadata, Value}) ->
    Value.