%{
// Prologue
%}

%token tNUMBER
%token '+'
%token '-'

%left '+'

%lexer-state {
  state EXPR_BEG;
  state EXPR_END;
  state EXPR_CLASS;

  initial_state EXPR_BEG;

  predication IS_BEG = EXPR_BEG | EXPR_CLASS;

  transitions {
    EXPR_BEG {
      tNUMBER => EXPR_END;
    };

    EXPR_END {
      '+' => EXPR_BEG;
      '-' => EXPR_BEG;
    };
  };
}

%%

program: expr ;

expr: expr '+' expr
    | tNUMBER '-' tNUMBER
    | tNUMBER
    ;

%%
