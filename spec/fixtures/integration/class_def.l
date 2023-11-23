%option noinput nounput noyywrap never-interactive bison-bridge bison-locations

%{

#include <stdio.h>
#include <stdlib.h>
#include "class_def.h"

%}

NUMBER [0-9]+

%%

[+\-\*\/\(\)] {
    return yytext[0];
}

[\n|\r\n] {}

[[:space:]] {}

<<EOF>> {
    return(YYEOF);
}

"class" {
    return keyword_class;
}

"end" {
    return keyword_end;
}

"CONST" {
    return keyword_const;
}

"=" {
    return eq;
}

"A" {
    return class_name;
}

"1" {
    return const_value;
}

. {
    fprintf(stderr, "Illegal character '%s'\n", yytext);
    return(YYEOF);
}

%%
