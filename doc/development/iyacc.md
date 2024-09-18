# Step 1: Create new template and setup test environment

The first step is to create new template and enable CI for new template base parser.

# 000: Copy iyacc file

Create "template/iyacc" folder.
Copy "yaccpar" from https://bitbucket.org/inferno-os/inferno-os/src/master/utils/iyacc/yaccpar as "template/iyacc/iyacc.c".
Copy "copyright NOTICE" text from https://bitbucket.org/inferno-os/inferno-os/src/master/utils/NOTICE into the beginning of the "iyacc.c".

Briefly introduce "iyacc.c" codes.

## Variables used in `yyparse`

Parser stack

State management

* `int yystate`
* `long yychar`
* `int yyn`

These are global variables right now.

* 

## States of `yyparse` function

* `ret0`: Set return value to 0 (success) then go to `ret`.
* `ret1`: Set return value to 1 (error) then go to `ret`.
* `ret`: Execute clean up processes then return.
* `yystack`: 
* `yynewstate`
* `yydefault`

## Algorithm of `yypact` packed table

# 001: Replace tab in "iyacc.c" with 4 spaces

# 002: Add codes defined by "iyacc/yacc.c"

Because some codes are rendered by "iyacc/yacc.c", we need to add these codes to "iyacc.c" template.
Codes like `Bprint(ftable, "...");` are candidates of this modification.

## `YYMAXDEPTH`

`YYMAXDEPTH` manages max size of parser stack.
Define `YYMAXDEPTH` with `200` if `YYMAXDEPTH` is not defined.
Right now, iyacc doesn't expand parser stack then `YYMAXDEPTH` is same with default parser stack size.
This will be separated into `YYINITDEPTH` and `YYMAXDEPTH` later.

## `YYSTYPE`



## `yylval`



## `yyval`




* `YYEOFCODE`
* `YYERRCODE`

# XXX: Embed actions

`$A`

# XXX: Setup test environment


# Step 2: Modernize iyacc

# XXX: Formatting

if, for, switch

# XXX: Remove global variables

Make these global variables to be local variables of `yyparse`.

* `yynerrs`
* `yyerrflag`

Then remove these local variables which store temporal values of `yylval`, `yyval`, `yynerrs` and `yyerrflag`.

* `save1`
* `save2`
* `save3`
* `save4`

# XXX: Split `yyn`

`yyn` is used for storing both return value and temporal value of state.
Introduce `int yyresult` to store return value.

# XXX: Change `yylex1` function

# XXX: `enum yytokentype`

# XXX: Return 2 when memory exhausted



# XXX: prologue & epilogue

# XXX: Location

`YYLTYPE`

# XXX: User defined parameters

# XXX: Debug mode

`"y.debug"`

# XXX: Reallocate parser stack

`YYINITDEPTH`

# XXX: user_initial_action


# XXX: Panic mode

# XXX: Error recovery


# XXX: TEMPLATE



# Step 3: Support Bison features


