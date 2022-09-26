grammar Koi;

/*
    Parser Rules
 */

program: line* EOF;
line: (comment | statement | expression | block | function_block | procedure_block | while_block | for_block | if_stream | class_block | when | enum | struct) (SEMICOLON line)*;
// ending: SEMICOLON? NEWLINE | SEMICOLON;

comment: COMMENT | MULTICOMMENT;

// var my_var := "My Var"
// var !var := "My Var"
name: (THIS DOT)? ((ID | TEMP_ID | EXCLAMATION keyword) accessor)* (ID | TEMP_ID | EXCLAMATION keyword) | THIS;
keyword: TRUE | FALSE
       // | PRINT | PRINTLN
       | VAR
       | CALL
       | RETURN
       | type_;

accessor: DOT | SAFE_CALL | NULL_CHECK_ACCESS;

statement: function_call | local_asstmt | import_stmt | class_new;
call_parameter_set: ((paramNames+=name EQUALS)? paramValues+=true_value COMMA)* ((paramNames+=name EQUALS)? paramValues+=true_value)?;
method_call: funcName=name OPEN_PARENTHESIS call_parameter_set CLOSE_PARENTHESIS;
function_call: CALL (method_call | name) (accessor method_call)*;
class_new: NEW className=name OPEN_PARENTHESIS call_parameter_set CLOSE_PARENTHESIS (accessor method_call)*;

local_asstmt: VAR name COLON type_ EQUALS true_value
            | name EQUALS true_value
            | VAR name COLON type_
            ;

expression: arith_expr | compa_expr | value_change | half_compa;
// FIXME: Should use true_value instead of value
arith_expr: value (ADD | SUB | MUL | DIV) true_value;
compa_expr: EXCLAMATION? value ((GREATER | LESSER | GREQ | LEEQ | EQUALITY | INEQUALITY) true_value)?;
half_compa: EXCLAMATION? comp=(GREATER | LESSER | GREQ | LEEQ) true_value;

true_value: value (INCREASE | DECREASE)? NULL_CHECK? | expression;
value: SINGLESTRING | LITSTRING | MULTISTRING
     | INTEGER | FLOAT | DECIMAL | EXCLAMATION? (TRUE | FALSE) | NONE
     | name | list_ | function_call | class_new
     ;
value_change: value (INCREASE | DECREASE);

list_: OPEN_BRACKET (value COMMA)* value? CLOSE_BRACKET;

type_: (OBJ | CHAR | STR | INT | FLO | DOU | BOOL | NONE | ID) (OPEN_BRACKET CLOSE_BRACKET)? QUESTION?;

block: code_block | return_block | break_block | inner_class_block;
code_block: OPEN_BRACE line* CLOSE_BRACE;
return_block: OPEN_BRACE line* return_stmt CLOSE_BRACE;
break_block: OPEN_BRACE line* BREAK? CLOSE_BRACE;
inner_class_block: OPEN_BRACE init_block constructor_block method_block* CLOSE_BRACE;

parameter_set: OPEN_PARENTHESIS (parameter COMMA)* parameter? CLOSE_PARENTHESIS;
parameter: name COLON type_ (EQUALS value)? #parameterNorm
         | name COLON type_ TRIPLE_DOT #parameterVarArg
         ;
function_block: FUNCTION name parameter_set (ARROW returnType=type_) (block | FAT_ARROW line)
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
if_block: IF compa_list (block | FAT_ARROW line);
elf_block: ELF compa_list (block | FAT_ARROW line);
else_block: ELSE (block | FAT_ARROW line);

compa_list: comparisons+=compa_expr (settings+=(OR | AND) comparisons+=compa_expr)*;

package_name: (folders+=ID DOUBLE_COLON)* last=ID;
import_stmt: IMPORT (CORE | STANDARD | LOCAL) DOUBLE_COLON package_name;

class_block: CLASS name block;
method_block: METH procedure_block
            | METH function_block
            ;
constructor_block: CONSTRUCTOR parameter_set block;
init_block: INIT block;

when_block: OPEN_BRACE is* when_else? CLOSE_BRACE;
when: WHEN true_value when_block;
is_block: OPEN_BRACE line* CLOSE_BRACE;
is: IS (half_compa | true_value) (is_block | FAT_ARROW line);
when_else_block: OPEN_BRACE line* CLOSE_BRACE;
when_else: ELSE (when_else_block | FAT_ARROW line);

enum_block: OPEN_BRACE (ID COMMA)* ID? CLOSE_BRACE;
enum: ENUM name enum_block;

struct_block: OPEN_BRACE struct_set* CLOSE_BRACE;
struct: STRUCT name struct_block;
struct_set: name COLON type_;

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

NONE: 'none';

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
INIT: 'init';

CALL: 'call';
RETURN: 'return';

IF: 'if';
ELF: 'elf';
ELSE: 'else';

WHEN: 'when';
IS: 'is';

IMPORT: 'import';
CORE: 'core';
STANDARD: 'std';
LOCAL: 'local';

ENUM: 'enum';
STRUCT: 'struct';

// Types
OBJ: 'obj';
CHAR: 'char';
STR: 'str';
INT: 'int';
FLO: 'float';
DOU: 'double';
BOOL: 'bool';

// Symbols
ARROW: DASH GREATER;
FAT_ARROW: EQUALS GREATER;

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
QUESTION: '?';
EXCLAMATION: '!';

EQUALS: '=';
INFERRED: ':=';
AND: '&&';
OR: '||';

EQUALITY: EQUALS EQUALS;
INEQUALITY: EXCLAMATION EQUALS;

GREATER: '>';
LESSER: '<';

OPEN_BRACKET: '[';
CLOSE_BRACKET: ']';

OPEN_BRACE: '{';
CLOSE_BRACE: '}';

GREQ: GREATER EQUALS;
LEEQ: LESSER EQUALS;
NOTEQ: EXCLAMATION EQUALS;

ADD: '+';
SUB: '-';
MUL: '*';
DIV: '/';
MOD: '%';

INCREASE: '++';
DECREASE: '--';

SAFE_CALL: QUESTION DOT;
NULL_CHECK: EXCLAMATION EXCLAMATION;
NULL_CHECK_ACCESS: EXCLAMATION EXCLAMATION DOT;

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

SPACE: [ \t\r\n] -> channel(HIDDEN);
WS: [ \t\r\n\f]+ -> channel(HIDDEN);
