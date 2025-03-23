%{
// Prologue
%}

%token tNUMBER
%token tSTRING_BEG
%token tSTRING_END
%token tSTRING_CONTENT
%token '+'
%token '-'
%token '('
%token ')'
%token ','
%token keyword_def
%token keyword_end

%left '+'

%lexer-state {
  state EXPR_BEG;
  state EXPR_END;
  state EXPR_ENDARG;
  state EXPR_ENDFN;
  state EXPR_ARG;
  state EXPR_CMDARG;
  state EXPR_MID;
  state EXPR_FNAME;
  state EXPR_DOT;
  state EXPR_CLASS;
  state EXPR_LABEL;
  state EXPR_LABELED;
  state EXPR_FITEM;

  initial_state EXPR_BEG;

  predication IS_BEG_ANY = EXPR_BEG | EXPR_MID | EXPR_CLASS;
  predication_all IS_ARG_LABELED = EXPR_ARG | EXPR_LABELED;
  predication IS_BEG = IS_BEG_ANY || IS_ARG_LABELED;
  predication IS_AFTER_OPERATOR = EXPR_FNAME | EXPR_DOT;

  transitions {
    EXPR_BEG {
      tNUMBER => EXPR_END;
    };

    IS_AFTER_OPERATOR {
      '+' => EXPR_ARG;
      '-' => EXPR_ARG;
    };

    !IS_AFTER_OPERATOR {
      '+' => EXPR_BEG;
      '-' => EXPR_BEG;
    };

    * {
      tSTRING_END => EXPR_END;
      keyword_def => EXPR_FNAME;
      keyword_end => EXPR_END;
      '(' => EXPR_BEG | EXPR_LABEL;
      ')' => EXPR_ENDFN;
      ',' => EXPR_BEG | EXPR_LABEL;
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

def_name: op
        ;

op: '+'
  | '-'
  ;

f_arglist: '(' ')'
         ;

primary: tNUMBER
       | string
       | keyword_def def_name f_arglist expr keyword_end
       ;

%%
