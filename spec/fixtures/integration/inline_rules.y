%{
#include <stdio.h>

#include "inline_rules.h"
#include "inline_rules-lexer.h"

static int yyerror(YYLTYPE *loc, const char *str);

%}

%union {
    int val;
}
%token <val> NUM
%type <val> expr

%%

stmt: NUM i_rule_2 NUM
        {
          printf("stmt\n");
          $$ = $1 + $2 + $3;
        }
    ;

%inline i_rule_1: NUM
                    {
                      $$ = $1;
                    }
                ;

%inline i_rule_2: NUM i_rule_1
                    {
                      $$ = $1 + $2;
                    }
                ;

%%

static int yyerror(YYLTYPE *loc, const char *str) {
    fprintf(stderr, "parse error: %s\\n", str);
    return 0;
}

int main(int argc, char *argv[]) {
    if (argc == 2) {
        yy_scan_string(argv[1]);
    }

    if (yyparse()) {
        fprintf(stderr, "syntax error\n");
        return 1;
    }
    return 0;
}
