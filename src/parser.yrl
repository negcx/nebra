Nonterminals Statement Statements Expression Block Function FunctionCall List Literal Elements MapElement MapElements Map Dispatch Access Uminus If Cond CondExpression CondExpressions Start.
Terminals '+' '*' '-' '/' '(' ')' '{' '}' ':' ',' '=>' '=' ';' int number string id '[' ']' '->' '.' 'if' else 'or' 'and' 'not' '==' '!=' '>=' '>' '<=' '<' true false 'null' 'cond' '(\\' '$start' '.(' '|'.
Rootsymbol Start.
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
Left 600 '.'.
Left 600 '->'.
Left 600 '['.
Left 800 '.('.

Start -> '$start' Statements : {start, metadata('$1'), '$2'}.

Block -> '{' Statements '}' : {block, metadata('$1'), '$2'}.
Statement -> Statement ';' : '$1'.
Statement -> Expression : '$1'.
Statements -> Statement : ['$1'].
Statements -> Statement ';' Statements : ['$1' | '$3'].

Expression -> Expression '=' Expression : {token('$2'), metadata('$2'), ['$1', '$3']}.
Expression -> Expression '+' Expression : {token('$2'), metadata('$2'), ['$1', '$3']}.
Expression -> Expression '-' Expression : {token('$2'), metadata('$2'), ['$1', '$3']}.
Expression -> Expression '*' Expression : {token('$2'), metadata('$2'), ['$1', '$3']}.
Expression -> Expression '/' Expression : {token('$2'), metadata('$2'), ['$1', '$3']}.
Expression -> Expression '==' Expression : {token('$2'), metadata('$2'), ['$1', '$3']}.
Expression -> Expression '!=' Expression : {token('$2'), metadata('$2'), ['$1', '$3']}.
Expression -> Expression '>' Expression : {token('$2'), metadata('$2'), ['$1', '$3']}.
Expression -> Expression '<' Expression : {token('$2'), metadata('$2'), ['$1', '$3']}.
Expression -> Expression '>=' Expression : {token('$2'), metadata('$2'), ['$1', '$3']}.
Expression -> Expression '<=' Expression : {token('$2'), metadata('$2'), ['$1', '$3']}.
Expression -> Expression 'and' Expression : {token('$2'), metadata('$2'), ['$1', '$3']}.
Expression -> Expression 'or' Expression : {token('$2'), metadata('$2'), ['$1', '$3']}.
Expression -> '(' Expression ')' : '$2'.
Expression -> Literal : '$1'.
Expression -> id : '$1'.
Expression -> Function : '$1'.
Expression -> FunctionCall : '$1'.
Expression -> Dispatch : '$1'.
Expression -> Access : '$1'.
Expression -> 'not' Expression : {'not', metadata('$1'), ['$2']}.
Expression -> Uminus : '$1'.
Expression -> If : '$1'.
Expression -> Cond : '$1'.

Uminus -> '-' Expression : {uminus, metadata('$1'), ['$2']}.

Literal -> int : value('$1').
Literal -> number : value('$1').
Literal -> string : value('$1').
Literal -> List : '$1'.
Literal -> Map : '$1'.
Literal -> true : '$1'.
Literal -> false : '$1'.
Literal -> 'null' : '$1'.

List -> '[' ']' : [].
List -> '[' Elements ']' : {'[]', metadata('$1'), '$2'}.
Elements -> Expression : ['$1'].
Elements -> Expression ',' Elements : ['$1' | '$3'].

Function -> '(' ')' '=>' Block : {'=>', metadata('$3'), [[], '$4']}.
Function -> '(' ')' '=>' Expression : {'=>', metadata('$3'), [[], '$4']}.
Function -> '(\\' ')' '=>' Block : {'=>', metadata('$3'), [[], '$4']}.
Function -> '(\\' ')' '=>' Expression : {'=>', metadata('$3'), [[], '$4']}.
Function -> id '=>' Block : {'=>', metadata('$2'), [['$1'], '$3']}.
Function -> id '=>' Expression : {'=>', metadata('$2'), [['$1'], '$3']}.
Function -> '(\\' Elements ')' '=>' Expression : {'=>', metadata('$4'), ['$2', '$5']}.
Function -> '(\\' Elements ')' '=>' Block : {'=>', metadata('$4'), ['$2', '$5']}.
Function -> '|' '|' '=>' Block : {'=>', metadata('$3'), [[], '$4']}.
Function -> '|' '|' '=>' Expression : {'=>', metadata('$3'), [[], '$4']}.
Function -> '|' Elements '|' '=>' Expression : {'=>', metadata('$4'), ['$2', '$5']}.
Function -> '|' Elements '|' '=>' Block : {'=>', metadata('$4'), ['$2', '$5']}.

FunctionCall -> Expression '.(' ')' : {'()', metadata('$1'), ['$1', []]}.
FunctionCall -> Expression '.(' Elements ')' : {'()', metadata('$1'), ['$1', '$3']}.

MapElement -> Expression ':' Expression : {'{}_child', metadata('$2'), ['$1', '$3']}.
MapElements -> MapElement : ['$1'].
MapElements -> MapElement ',' MapElements : ['$1' | '$3'].
Map -> '{' MapElements '}' : {'{}', metadata('$1'), '$2'}.
Map -> '{' '}' : {'{}', metadata('$1'), []}.

Dispatch -> Expression '->' Expression '(' ')' : {'->', metadata('$2'), ['$1', '$3', []]}.
Dispatch -> Expression '->' Expression '(' Elements ')' : {'->', metadata('$2'), ['$1', '$3', '$5']}.

Access -> Expression '.' id : {'.', metadata('$2'), ['$1', '$3']}.
Access -> Expression '[' Expression ']' : {'.', metadata('$2'), ['$1', '$3']}.

If -> 'if' '(' Expression ')' Block 'else' Expression : {'if', metadata('$1'), ['$3', '$5', '$7']}. 
If -> 'if' '(' Expression ')' Expression 'else' Block : {'if', metadata('$1'), ['$3', '$5', '$7']}. 
If -> 'if' '(' Expression ')' Block 'else' Block : {'if', metadata('$1'), ['$3', '$5', '$7']}. 
If -> 'if' '(' Expression ')' Block : {'if', metadata('$1'), ['$3', '$5']}.
If -> 'if' '(' Expression ')' Expression : {'if', metadata('$1'), ['$3', '$5']}.
If -> 'if' '(' Expression ')' Expression 'else' Expression : {'if', metadata('$1'), ['$3', '$5', '$7']}. 


Cond -> 'cond' '{' CondExpressions '}' : {'cond_block', metadata('$1'), '$3'}.
CondExpression -> '(' Expression ')' Block : {'cond', metadata('$1'), ['$2', '$4']}.
CondExpression -> '(' Expression ')' Expression : {'cond', metadata('$1'), ['$2', '$4']}.
CondExpressions -> CondExpression : ['$1'].
CondExpressions -> CondExpression CondExpressions : ['$1' | '$2'].

Erlang code.
value({_Token, _Metadata, Value}) -> Value.
metadata(Token) -> element(2, Token).
token(Token) -> element(1, Token).