%{

#define YYDEBUG 1

#include <stdio.h>
#include "class_def.h"
#include "class_def-lexer.h"

static int yyerror(YYLTYPE *loc, const char *str);

%}

%expect 0

%union {
  int val;
}

%token <id>
        keyword_class "class"
        keyword_end "end"
        keyword_const "CONST"
        eq "="
        class_name "A"
        const_value "1"

%%

program : class_def
        ;

class_def : keyword_class class_name body keyword_end
          ;

body : class_def
     | const_decl
     ;

const_decl : keyword_const eq const_value
           ;

%%

static int yyerror(YYLTYPE *loc, const char *str) {
    fprintf(stderr, "parse error: %s\n", str);
    return 0;
}

int main(int argc, char *argv[]) {
    yydebug = 1;

    if (argc == 2) {
        yy_scan_string(argv[1]);
    }

    if (yyparse()) {
        fprintf(stderr, "syntax error\n");
        return 1;
    }
    return 0;
}
