grammar Koi;

/*
    Parser Rules
 */

program: line* EOF;
line: (comment | statement | expression | block | function_block | procedure_block | while_block | for_block | if_stream | class_block) (SEMICOLON line)*;
// ending: SEMICOLON? NEWLINE | SEMICOLON;

comment: COMMENT | MULTICOMMENT;

// var my_var := "My Var"
// var !var := "My Var"
name: (THIS DOT)? (ID | TEMP_ID | NOT keyword);
keyword: TRUE | FALSE
       // | PRINT | PRINTLN
       | VAR
       | CALL
       | RETURN
       | type_;

statement: function_call | local_asstmt | import_stmt | class_new;
call_parameter_set: ((paramNames+=name EQUALS)? paramValues+=true_value COMMA)* ((paramNames+=name EQUALS)? paramValues+=true_value)?;
method_call: funcName=name OPEN_PARENTHESIS call_parameter_set CLOSE_PARENTHESIS;
function_call: CALL method_call;
class_new: NEW className=name OPEN_PARENTHESIS call_parameter_set CLOSE_PARENTHESIS (DOT method_call)*;

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
     | name | list_ | function_call
     ;
value_change: value (INCREASE | DECREASE);

list_: OPEN_BRACKET (value COMMA)* value? CLOSE_BRACKET;

type_: OBJ | CHAR | STR | INT | FLO | BOOL | NONE | ID | type_ OPEN_BRACKET CLOSE_BRACKET;

block: code_block | return_block | break_block | inner_class_block;
code_block: OPEN_BRACE line* CLOSE_BRACE;
return_block: OPEN_BRACE line* return_stmt CLOSE_BRACE;
break_block: OPEN_BRACE line* BREAK? CLOSE_BRACE;
inner_class_block: OPEN_BRACE constructor_block method_block* CLOSE_BRACE;

parameter_set: OPEN_PARENTHESIS (parameter COMMA)* parameter? CLOSE_PARENTHESIS;
parameter: name COLON type_ (EQUALS value)? #parameterNorm
         | name COLON type_ TRIPLE_DOT #parameterVarArg
         ;
function_block: FUNCTION name parameter_set (ARROW returnType=type_) block
              | NATIVE FUNCTION name parameter_set (ARROW returnType=type_)
              ;
procedure_block: PROCEDURE name parameter_set block
               | NATIVE PROCEDURE name parameter_set
               ;
return_stmt: RETURN true_value;

while_block: WHILE compa_list block;
for_block: FOR name COLON type_ IN (with_length | name) block;

range_: INTEGER DOUBLE_DOT INTEGER;
with_length: range_ | list_;

if_stream: if_block elf_block* else_block?;
if_block: IF compa_list block;
elf_block: ELF compa_list block;
else_block: ELSE block;

compa_list: comparisons+=compa_expr (settings+=(OR | AND) comparisons+=compa_expr)*;

package_name: (folders+=ID DOUBLE_COLON)* last=ID;
import_stmt: (CORE | STANDARD | LOCAL) IMPORT package_name;

class_block: CLASS name block;
method_block: METH procedure_block
            | METH function_block
            ;
constructor_block: CONSTRUCTOR parameter_set block;

/*
    Lexer Rules
 */

COMMENT: HASHTAG ~[\r\n]* -> skip;
MULTICOMMENT: HASHTAG DASH .*? DASH HASHTAG -> skip;

// NEWLINE: [\r\n]+ -> skip;

// Keywords
NATIVE: 'native';

TRUE: 'true';
FALSE: 'false';

VAR: 'var';

WHILE: 'while';
FOR: 'for';

IN: 'in';
BREAK: 'break';

FUNCTION: 'fun';
PROCEDURE: 'pro';

CLASS: 'class';
CONSTRUCTOR: 'constructor';
METH: 'meth';
THIS: 'this';
NEW: 'new';

CALL: 'call';
RETURN: 'return';

IF: 'if';
ELF: 'elf';
ELSE: 'else';

IMPORT: 'import';
CORE: 'core';
STANDARD: 'std';
LOCAL: 'local';

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

// Symbols
ARROW: DASH GREATER;

// Punctuation
fragment HASHTAG: '#';
fragment DASH: '-';
SEMICOLON: ';';
COLON: ':';
DOUBLE_COLON: '::';
DOT: '.';
DOUBLE_DOT: '..';
TRIPLE_DOT: '...';
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
