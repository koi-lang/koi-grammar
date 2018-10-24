grammar Koi;

/*
    Parser Rules
 */

program: line* EOF;
line: (comment | statement | expression | block | function_block | while_block | for_block | if_stream) (SEMICOLON line)*;
// ending: SEMICOLON? NEWLINE | SEMICOLON;

comment: COMMENT | MULTICOMMENT;

// var my_var := "My Var"
// var !var := "My Var"
name: ID | TEMP_ID | NOT keyword;
keyword: TRUE | FALSE
       // | PRINT | PRINTLN
       | VAR
       | CALL
       | RETURN
       | type_;

statement: function_call | local_asstmt;
function_call: CALL funcName=name OPEN_PARENTHESIS ((paramNames+=name EQUALS)? paramValues+=true_value COMMA)* ((paramNames+=name EQUALS)? paramValues+=true_value)? CLOSE_PARENTHESIS;

local_asstmt: // VAR name INFERRED true_value // var my_var := "Hello"
            // | name EQUALS true_value // my_var = "Hello"
            // | VAR name COLON type_ // var my_var: str
            VAR name COLON type_ EQUALS true_value; // var my_var: str = "Hello"

expression: arith_expr | compa_expr | value_change;
// FIXME: Should use true_value instead of value
arith_expr: value (ADD | SUB | MUL | DIV) true_value;
compa_expr: NOT? value (GREATER | LESSER | EQUALS | GREQ | LEEQ | EQUALITY | INEQUALITY | LESS_OR_EQUAL | GREAT_OR_EQUAL) true_value;

true_value: value (INCREASE | DECREASE)? | expression;
value: SINGLESTRING | LITSTRING | MULTISTRING
     | INTEGER | FLOAT | DECIMAL | NOT? (TRUE | FALSE)
     | name | list_
     ;
value_change: value (INCREASE | DECREASE);

list_: OPEN_BRACKET (value COMMA)* value? CLOSE_BRACKET;

type_: OBJ | CHAR | STR | INT | FLO | BOOL | NONE | ID | type_ OPEN_BRACKET CLOSE_BRACKET;

block: code_block | return_block | break_block;
code_block: OPEN_BRACE line* CLOSE_BRACE;
return_block: OPEN_BRACE line* return_stmt CLOSE_BRACE;
break_block: OPEN_BRACE line* BREAK? CLOSE_BRACE;

parameter_set: OPEN_PARENTHESIS (parameter COMMA)* parameter? CLOSE_PARENTHESIS;
parameter: name COLON type_ (EQUALS value)?;
function_block: FUNCTION name parameter_set (ARROW returnType=type_)? block;
return_stmt: RETURN true_value;

while_block: WHILE compa_list block;
for_block: FOR name COLON type_ IN (with_length | name) block;

range_: INTEGER DOUBLE_DOT INTEGER;
with_length: range_ | list_;

if_stream: if_block elf_block* else_block?;
if_block: IF compa_list block;
elf_block: ELF compa_list block;
else_block: ELSE block;

compa_list: (compa_expr | or_compa | and_compa)+;
or_compa: compa_expr OR compa_expr;
and_compa: compa_expr AND compa_expr;

/*
    Lexer Rules
 */

COMMENT: HASHTAG ~[\r\n]* -> skip;
MULTICOMMENT: HASHTAG DASH .*? DASH HASHTAG -> skip;

// NEWLINE: [\r\n]+ -> skip;

// Keywords
TRUE: 'true';
FALSE: 'false';

INPUT: 'input';
INPUTLN: 'inputln';

VAR: 'var';

CALL: 'call';

RETURN: 'return';

WHILE: 'while';
FOR: 'for';

IN: 'in';

BREAK: 'break';

IF: 'if';
ELF: 'elf';
ELSE: 'else';

// OR: 'or';
// AND: 'and';
// NOT: 'not';

    // Types
OBJ: 'obj';
CHAR: 'char';
STR: 'str';
INT: 'int';
FLO: 'float';
BOOL: 'bool';
NONE: 'none';

FUNCTION: 'fun';

// Symbols
ARROW: DASH GREATER;

// Punctuation
fragment HASHTAG: '#';
fragment DASH: '-';
SEMICOLON: ';';
COLON: ':';
fragment DOT: '.';
DOUBLE_DOT: '..';
fragment DOUBLE_QUOTE: '"';
fragment SINGLE_QUOTE: '\'';
fragment GRAVE: '`';
OPEN_PARENTHESIS: '(';
CLOSE_PARENTHESIS: ')';
COMMA: ',';
UNDERSCORE: '_';

EQUALS: '=';
INFERRED: ':=';
AND: '&&';
OR: '||';
NOT: '!';

EQUALITY: EQUALS EQUALS;
INEQUALITY: NOT EQUALS;
LESS_OR_EQUAL: LESSER EQUALS;
GREAT_OR_EQUAL: GREATER EQUALS;

GREATER: '>';
LESSER: '<';

OPEN_BRACKET: '[';
CLOSE_BRACKET: ']';

OPEN_BRACE: '{';
CLOSE_BRACE: '}';

GREQ: GREATER EQUALS;
LEEQ: LESSER EQUALS;
NOTEQ: NOT EQUALS;

ADD: '+';
SUB: '-';
MUL: '*';
DIV: '/';
MOD: '%';

INCREASE: '++';
DECREASE: '--';

fragment LOWERCASE: [a-z];
fragment UPPERCASE: [A-Z];
fragment LETTER: LOWERCASE | UPPERCASE;
fragment WORD: LETTER+;

SINGLESTRING: DOUBLE_QUOTE ~["\r\n]* DOUBLE_QUOTE;
LITSTRING: SINGLE_QUOTE ~['\r\n]* SINGLE_QUOTE;
MULTISTRING: GRAVE (~[`\r\n]+ | '\r'? '\n')* GRAVE;

// 1.0f/1f
FLOAT: INTEGER (DOT INTEGER)? 'f';
// 1.0d/1d
DECIMAL: INTEGER (DOT INTEGER)? 'd';
// 1
INTEGER: [0-9]+;
NUMBER: INTEGER | FLOAT | DECIMAL;
// true/false
BOOLEAN: TRUE | FALSE;

TEMP_ID: UNDERSCORE;
ID: UNDERSCORE? LETTER (LETTER | INTEGER | UNDERSCORE)*;

SPACE: [ \t\r\n] -> skip;
WS: [ \t\r\n\f]+ -> skip;
