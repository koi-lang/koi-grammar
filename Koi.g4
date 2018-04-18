grammar Koi;

/*
    Parser Rules
 */

program: code EOF;
code: (line SEMICOLON?)*;

line: comment | statement | expression;

comment: COMMENT | MULTICOMMENT;

// !var = "My Var"
name: ID | NOT keyword;
keyword: TRUE | FALSE
       | PRINT | PRINTLN
       | VAR;

statement: print_stmt | asstmt;
print_stmt: TYPE=(PRINT | PRINTLN) OPENBRAKET (true_value COMMA)* true_value? CLOSEBRACKET;
asstmt: VAR name COLON true_value;

expression: arith_expr | compa_expr;
arith_expr: value OPRAND=(ADD | SUB | MUL | DIV) true_value;
compa_expr: NOT? value OPRAND=(GREATER | LESSER | EQUALS | GREQ | LEEQ | AND | OR) true_value;

true_value: value | expression;
value: SINGLESTRING | LITSTRING | MULTISTRING
     | NUMBER | FLOAT | BOOLEAN
     | name
     ;

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

EQUALS: '=';
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

ID: LETTER (LETTER | NUMBER)*;

SPACE: [ \t\r\n] -> skip;
WS: [ \t\r\n\f]+ -> skip;
