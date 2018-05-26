grammar Koi;

/*
    Parser Rules
 */

program: code EOF;
code: (line SEMICOLON?)*;

line: comment | statement | expression;

comment: COMMENT | MULTICOMMENT;

// !var := "My Var"
name: ID | NOT keyword;
keyword: TRUE | FALSE
       | PRINT | PRINTLN
       | VAR | VAL
       | type_;

statement: print_stmt | local_asstmt;
// print("Hello, "); println("World!")
print_stmt: TYPE=(PRINT | PRINTLN) OPENBRAKET (true_value COMMA)* true_value? CLOSEBRACKET;

local_asstmt: vars_ name INFERRED true_value // var my_var := "Hello"
            | name EQUALS true_value // my_var = "Hello"
            | vars_ name COLON type_ // var my_var: str
            | vars_ name COLON type_ EQUALS true_value; // var my_var: str = "Hello"

expression: arith_expr | compa_expr;
arith_expr: value OPRAND=(ADD | SUB | MUL | DIV) true_value;
compa_expr: NOT? value OPRAND=(GREATER | LESSER | EQUALS | GREQ | LEEQ) true_value;

true_value: value | expression;
value: SINGLESTRING | LITSTRING | MULTISTRING
     | NUMBER | FLOAT | BOOLEAN
     | name
     ;

type_: OBJ | CHAR | STR | INT | FLOAT | BOOL | NONE | ID;
vars_: VAR | VAL;

/*
    Lexer Rules
 */

COMMENT: HASHTAG ~[\r\n]* -> skip;
MULTICOMMENT: HASHTAG DASH .*? DASH HASHTAG -> skip;

// Keywords
TRUE: 'true';
FALSE: 'false';

PRINT: 'print';
PRINTLN: 'println';

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

SPACE: [ \t\r\n] -> skip;
WS: [ \t\r\n\f]+ -> skip;
