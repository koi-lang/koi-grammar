grammar Koi;

/*
    Parser Rules
 */

program: code EOF;
code: (line? ending)*;
ending: NEWLINE | SEMICOLON;

line: comment | statement | expression;

comment: COMMENT | MULTICOMMENT;

// var my_var := "My Var"
// var !var := "My Var"
name: ID | NOT keyword;
keyword: TRUE | FALSE
       | PRINT | PRINTLN
       | VAR | VAL
       | type_;

statement: print_stmt | input_stmt | local_asstmt;
// print("Hello, ")
// println("World!")
print_stmt: (PRINT | PRINTLN) OPENBRAKET (true_value COMMA)* true_value? CLOSEBRACKET;
input_stmt: (INPUT | INPUTLN) OPENBRAKET ('text' EQUALS)? text=true_value (COMMA ('limit' EQUALS)? limit=true_value)? CLOSEBRACKET;

local_asstmt: vars_ name INFERRED true_value // var my_var := "Hello"
            | name EQUALS true_value // my_var = "Hello"
            | vars_ name COLON type_ // var my_var: str
            | vars_ name COLON type_ EQUALS true_value; // var my_var: str = "Hello"

expression: arith_expr | compa_expr;
arith_expr: value (ADD | SUB | MUL | DIV) true_value;
compa_expr: NOT? value (GREATER | LESSER | EQUALS | GREQ | LEEQ) true_value;

true_value: value | expression | input_stmt;
value: SINGLESTRING | LITSTRING | MULTISTRING
     | NUMBER | FLOAT | TRUE | FALSE
     | name
     ;

type_: OBJ | CHAR | STR | INT | FLOAT | BOOL | NONE | ID;
vars_: VAR | VAL;

/*
    Lexer Rules
 */

COMMENT: HASHTAG ~[\r\n]* -> skip;
MULTICOMMENT: HASHTAG DASH .*? DASH HASHTAG -> skip;

NEWLINE: [\r\n];

// Keywords
TRUE: 'true';
FALSE: 'false';

PRINT: 'print';
PRINTLN: 'println';

INPUT: 'input';
INPUTLN: 'inputln';

VAR: 'var';
VAL: 'val';

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
fragment DOT: '.';
fragment DOUBLEQUOTE: '"';
fragment SINGLEQUOTE: '\'';
fragment GRAVE: '`';
OPENBRAKET: '(';
CLOSEBRACKET: ')';
COMMA: ',';
UNDERSCORE: '_';

EQUALS: '=';
INFERRED: ':=';
AND: '%';
OR: '||';
NOT: '!';

GREATER: '>';
LESSER: '<';

GREQ: GREATER EQUALS;
LEEQ: LESSER EQUALS;
NOTEQ: NOT EQUALS;

ADD: '+';
SUB: '-';
MUL: '*';
DIV: '/';

fragment LOWERCASE: [a-z];
fragment UPPERCASE: [A-Z];
fragment LETTER: LOWERCASE | UPPERCASE;
fragment WORD: LETTER+;

SINGLESTRING: DOUBLEQUOTE ~["\r\n]* DOUBLEQUOTE;
LITSTRING: SINGLEQUOTE ~['\r\n]* SINGLEQUOTE;
MULTISTRING: GRAVE (~[`\r\n]+ | '\r'? '\n')* GRAVE;

NUMBER: [0-9]+;
FLOAT: NUMBER DOT NUMBER;
BOOLEAN: TRUE | FALSE;

ID: UNDERSCORE? LETTER (LETTER | NUMBER | UNDERSCORE)*;

SPACE: [ \t] -> skip;
