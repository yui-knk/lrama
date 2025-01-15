%{
// Prologue
%}

%union {
    int val;
}

%token NUM

%nonassoc  tCMP
%left '>'
%left '+'

%%

program : arg
        ;

arg : arg '+' arg
    | rel_expr    %prec tCMP
    | NUM
    ;

relop : '>'
      ;

rel_expr : arg relop arg   %prec '>'
         ;

%%
