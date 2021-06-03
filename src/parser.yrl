Nonterminals Statement Statements Expression Block Function FunctionCall List Literal Elements Parameters MapElement MapElements Map Dispatch Access Uminus If Cond CondExpression CondExpressions.
Terminals '+' '*' '-' '/' '(' ')' '{' '}' ':' ',' '=>' '=' ';' int number string id '[' ']' '->' '.' 'if' else 'or' 'and' 'not' '==' '!=' '>=' '>' '<=' '<' true false null 'cond'.
Rootsymbol Statements.
Endsymbol '$end'.

Right 100 '='.
Left 120 'and'.
Left 140 'or'.
Left 200 '==' '!='.
Left 250 '>' '>=' '<' '<='.
Left 300 '+'.
Left 300 '-'.
Left 400 '*'.
Left 400 '/'.
Unary 500 Uminus.
Unary 500 'not'.

Block -> '{' Statements '}' : {block, metadata_of('$1'), '$2'}.
Statement -> Statement ';' : '$1'.
Statement -> Expression : '$1'.
Statements -> Statement : ['$1'].
Statements -> Statement ';' Statements : ['$1' | '$3'].

Expression -> Expression '=' Expression : {'$2', ['$1', '$3']}.
Expression -> Expression '+' Expression : {'$2', ['$1', '$3']}.
Expression -> Expression '-' Expression : {'$2', ['$1', '$3']}.
Expression -> Expression '*' Expression : {'$2', ['$1', '$3']}.
Expression -> Expression '/' Expression : {'$2', ['$1', '$3']}.
Expression -> Expression '==' Expression : {'$2', ['$1', '$3']}.
Expression -> Expression '!=' Expression : {'$2', ['$1', '$3']}.
Expression -> Expression '>' Expression : {'$2', ['$1', '$3']}.
Expression -> Expression '<' Expression : {'$2', ['$1', '$3']}.
Expression -> Expression '>=' Expression : {'$2', ['$1', '$3']}.
Expression -> Expression '<=' Expression : {'$2', ['$1', '$3']}.
Expression -> Expression 'and' Expression : {'$2', ['$1', '$3']}.
Expression -> Expression 'or' Expression : {'$2', ['$1', '$3']}.
Expression -> '(' Expression ')' : '$2'.
Expression -> Literal : '$1'.
Expression -> id : '$1'.
Expression -> Function : '$1'.
Expression -> FunctionCall : '$1'.
Expression -> Dispatch : '$1'.
Expression -> Access : '$1'.
Expression -> 'not' Expression : {'not', metadata_of('$1'), ['$2']}.
Expression -> Uminus : '$1'.
Expression -> If : '$1'.
Expression -> Cond : '$1'.

Uminus -> '-' Expression : {uminus, metadata_of('$1'), ['$2']}.

Literal -> int : value_of('$1').
Literal -> number : value_of('$1').
Literal -> string : value_of('$1').
Literal -> List : '$1'.
Literal -> Map : '$1'.
Literal -> true : '$1'.
Literal -> false : '$1'.
Literal -> null : '$1'.

List -> '[' ']' : [].
List -> '[' Elements ']' : '$2'.
Elements -> Expression : ['$1'].
Elements -> Expression ',' Elements : ['$1' | '$3'].

Parameters -> id : ['$1'].
Parameters -> id ',' Parameters : ['$1' | '$3'].

Function -> '(' ')' '=>' Block : {'=>', metadata_of('$1'), [[], '$4']}.
Function -> '(' ')' '=>' Expression : {'=>', metadata_of('$1'), [[], '$4']}.
Function -> id '=>' Block : {'=>', metadata_of('$2'), [['$1'], '$3']}.
Function -> id '=>' Expression : {'=>', metadata_of('$2'), [['$1'], '$3']}.
Function -> Parameters '=>' Expression : {'=>', metadata_of('$2'), ['$1', '$3']}.
Function -> Parameters '=>' Block : {'=>', metadata_of('$2'), ['$1', '$3']}.

FunctionCall -> id '(' ')' : {'()', metadata_of('$1'), ['$1', []]}.
FunctionCall -> id '(' Elements ')' : {'()', metadata_of('$1'), ['$1', '$3']}.

MapElement -> Expression ':' Expression : {'$1', '$3'}.
MapElements -> MapElement : ['$1'].
MapElements -> MapElement ',' MapElements : ['$1' | '$3'].
Map -> '{' MapElements '}' : {'{}', metadata_of('$1'), '$2'}.
Map -> '{' '}' : {'{}', metadata_of('$1'), []}.

Dispatch -> Expression '->' FunctionCall : {'->', metadata_of('$2'), ['$1', '$3']}.

Access -> Expression '.' id : {'.', metadata_of('$2'), ['$1', '$3']}.
Access -> Expression '[' Expression ']' : {'.', metadata_of('$2'), ['$1', '$3']}.

If -> 'if' '(' Expression ')' Block : {'if', metadata_of('$1'), ['$3', '$5']}.
If -> 'if' '(' Expression ')' Block 'else' Block : {'if', metadata_of('$1'), ['$3', '$5', '$7']}. 
If -> 'if' '(' Expression ')' Expression : {'if', metadata_of('$1'), ['$3', '$5']}.
If -> 'if' '(' Expression ')' Expression 'else' Expression : {'if', metadata_of('$1'), ['$3', '$5', '$7']}. 
If -> 'if' '(' Expression ')' Block 'else' Expression : {'if', metadata_of('$1'), ['$3', '$5', '$7']}. 
If -> 'if' '(' Expression ')' Expression 'else' Block : {'if', metadata_of('$1'), ['$3', '$5', '$7']}. 

Cond -> 'cond' '{' CondExpressions '}' : {'cond_block', metadata_of('$1'), '$3'}.
CondExpression -> '(' Expression ')' Block : {'cond', metadata_of('$1'), ['$2', '$4']}.
CondExpression -> '(' Expression ')' Expression : {'cond', metadata_of('$1'), ['$2', '$4']}.
CondExpressions -> CondExpression : ['$1'].
CondExpressions -> CondExpression CondExpressions : ['$1' | '$2'].

Erlang code.
value_of({_Token, _Metadata, Value}) -> Value.
metadata_of(Token) -> element(2, Token).