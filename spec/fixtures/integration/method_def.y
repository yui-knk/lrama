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
        keyword_def "def"
        keyword_self "self"
        class_name "A"
        method_name "m"

%%

program : class_def
        ;

class_def : keyword_class class_name body keyword_end
          ;

body : method_def
     | singleton_method_def
     ;

method_def : keyword_def method_name keyword_end
           ;

singleton_method_def : keyword_def keyword_self '.' method_name keyword_end
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
