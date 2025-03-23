%{
// Prologue
%}

%token tNUMBER
%token tSTRING_BEG
%token tSTRING_END
%token tSTRING_CONTENT
%token '+'
%token '-'

%left '+'

%lexer-state {
  state EXPR_BEG;
  state EXPR_END;
  state EXPR_ARG;
  state EXPR_MID;
  state EXPR_FNAME;
  state EXPR_DOT;
  state EXPR_CLASS;
  state EXPR_LABELED;

  initial_state EXPR_BEG;

  predication IS_BEG_ANY = EXPR_BEG | EXPR_MID | EXPR_CLASS;
  predication_all IS_ARG_LABELED = EXPR_ARG | EXPR_LABELED;
  //predication IS_BEG = IS_BEG_ANY || IS_ARG_LABELED;
  predication IS_AFTER_OPERATOR = EXPR_FNAME | EXPR_DOT;

  transitions {
    EXPR_BEG {
      tNUMBER => EXPR_END;
    };

    EXPR_END {
      '+' => EXPR_BEG;
      '-' => EXPR_BEG;
    };

    * {
      tSTRING_END => EXPR_END;
    };
  };
}

%%

program: expr ;

expr: expr '+' expr
    | primary '-' primary
    | primary
    ;

string: tSTRING_BEG tSTRING_CONTENT tSTRING_END

primary: tNUMBER
       | string
       ;

%%
