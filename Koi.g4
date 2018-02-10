grammar Koi;

/*
    Parser Rules
 */

program: code EOF;
code: (line (SEMICOLON line)*)*;

line: comment | statement;

comment: COMMENT | MULTICOMMENT;

statement: print_stmt;
print_stmt: PRINT OPENBRAKET (value COMMA)* value? CLOSEBRACKET #Print
          | PRINTLN OPENBRAKET (value COMMA)* value? CLOSEBRACKET #PrintLine
          ;

value: SINGLESTRING | LITSTRING | MULTISTRING
     | NUMBER | FLOAT | BOOLEAN
     ;

/*
    Lexer Rules
 */

COMMENT: HASHTAG ~[\r\n]* -> skip;
MULTICOMMENT: HASHTAG DASH .*? DASH HASHTAG -> skip;

// Punctuation
fragment HASHTAG: '#';
fragment DASH: '-';
SEMICOLON: ';';
fragment DOT: '.';
fragment DOUBLEQUOTE: '"';
fragment SINGLEQUOTE: '\'';
fragment GRAVE: '`';
OPENBRAKET: '(';
CLOSEBRACKET: ')';
COMMA: ',';

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

SPACE: [ \t\r\n] -> skip;
WS: [ \t\r\n\f]+ -> skip;

// Keywords
TRUE: 'true';
FALSE: 'false';

PRINT: 'print';
PRINTLN: 'println';

