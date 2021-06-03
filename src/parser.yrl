Nonterminals E P_list F S S_list B E_list Call.
Terminals '+' '*' '-' '/' '(' ')' '{' '}' ',' '=>' '=' ';' int number id.
Rootsymbol S_list.
Endsymbol '$end'.

Left 100 '+'.
Left 100 '-'.
Left 200 '/'.
Left 200 '*'.
Right 100 '='.

B -> '{' S_list '}' : {block, metadata_of('$1'), '$2'}.

S -> id '=' E : {'=', ['$1', '$3']}.
S -> E : '$1'.
S -> S ';' : '$1'.
S_list -> S : ['$1'].
S_list -> S ';' S_list : ['$1' | '$3'].

E -> E '+' E : {'$2', ['$1', '$3']}.
E -> E '-' E : {'$2', ['$1', '$3']}.
E -> E '*' E : {'$2', ['$1', '$3']}.
E -> E '/' E : {'$2', ['$1', '$3']}.
E -> '(' E ')' : '$2'.
E -> int : value_of('$1').
E -> number : value_of('$1').
E -> id : '$1'.
E -> F : '$1'.
E -> Call : '$1'.
E_list -> E : ['$1'].
E_list -> E ',' E_list : ['$1' | '$3'].

P_list -> id : ['$1'].
P_list -> id ',' P_list : ['$1' | '$3'].

F -> id '=>' B : {'=>', metadata_of('$1'), ['$1', '$3']}.
F -> id '=>' E : {'=>', metadata_of('$1'), ['$1', '$3']}.

F -> P_list '=>' B : {'=>', metadata_of('$2'), ['$1', '$3']}.
F -> P_list '=>' E : {'=>', metadata_of('$2'), ['$1', '$3']}.

Call -> id '(' E_list ')' : {'()', metadata_of('$1'), ['$1', '$3']}.

Erlang code.
value_of({_Token, _Metadata, Value}) -> Value.
metadata_of(Token) -> element(2, Token).