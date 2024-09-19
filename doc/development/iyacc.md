# Milestone 1: Create new template and setup test environment

The first milestone is to create new template and enable CI for new template parser.

# 001: Copy iyacc file

Create "template/iyacc" folder.
Copy "yaccpar" from https://bitbucket.org/inferno-os/inferno-os/src/master/utils/iyacc/yaccpar as "template/iyacc/iyacc.c".
Copy "copyright NOTICE" text from https://bitbucket.org/inferno-os/inferno-os/src/master/utils/NOTICE into the beginning of the "iyacc.c". Also add these sentences into the beginning of the "iyacc.c" to clarify the source of template:

```
Derived from Inferno's utils/iyacc/yaccpar
https://bitbucket.org/inferno-os/inferno-os/src/18eb7a2d4ffc48d0a90687ace604e4e388440626/utils/iyacc/yaccpar
```

Briefly introduce "iyacc.c" codes here.

## Variables used in `yyparse`

These are variables to manage parser stack:

* `yys` is the parser stack.
* `yyp` is a pointer to the parser stack top.
* `yypt` is a temporary pointer variable to the parser stack top. Current parser stack top is assinged to `yypt` before recude operations so that semantic actions (`$A`) can access to parser stack before the reduce. In iyacc, `$n` is expanded to `yypt[-i]`.

Type of parser stack entry is defined as anonymous struct:

```c
struct {
    YYSTYPE yyv;
    int yys;
}
```

* `YYSTYPE yyv` is a semantic value of symbol.
* `int yys` is a state number.

These are variables to manage state of the parser:

* `int yystate` is the current state. `yystack` pushes `yystate` to the parser stack. `yynewstate` (shift) and `yydefault` (recude) don't push new state to the parser stack directly, they update `yystate` instead.
* `long yychar` is the current token. Minus value means no token is set then need to call `yylex`.
* `YYSTYPE yylval` is semantic value updated by `yylex`. This is global variable in iyacc.
* `YYSTYPE yyval` is semantic value set by each action. `$$` is expanded into `yyval`.
* `int yyn` is a general purpose variable.
* `int yym` is a rule id used for reduce.
* `int yyg` is an offset of compressed GOTO table.
* `int yyj` is an index on `yyact`.
* `short *yyxi` is an iterator over `yyexca`

## States of `yyparse` function

* `ret0`: Set return value to 0 (success) then go to `ret`.
* `ret1`: Set return value to 1 (error) then go to `ret`.
* `ret`: Execute clean up processes then return.
* `yystack`: Push new state to the parser stack. New state (`yystate`) and semantic value (`yyval`) should be set by others before goto this label.
* `yynewstate`: State is updated then determine next action (shift, reduce, accept and error).
* `yydefault`: Check default action then reduce.

```c
int
yyparse(void)
{
    // Initialize variables

	// Initial state is 0.
    // For example, state 0 is "0 $accept: • program "end-of-input""
    yystate = 0;
    // No token is provided
    yychar = -1;
    // yyp is increased by yystack soon
    yyp = &yys[-1];
    goto yystack


// Increase parser stack then set stack top.
// Need to set `yystate` and `yyval` before goto this label.
yystack:
    // Increase parser stack
    yyp++;
    // Check parser stack overflow before set stack top
    ...
    // Set stack top.
    // yyval for the initial state has meaningless semantic value
    yyp->yys = yystate;
    yyp->yyv = yyval;


// Determine default reduce, shift, reduce
// Read next token if needed.
yynewstate:
    yyn = yypact[yystate];
    // Check if it's default 


// Execute reduce
yydefault:
    goto yystack;
}
```

# 002: Formatting

* Replace tab in "iyacc.c" with 4 spaces
* Add a space between keywords (`if`, `for`, `switch` and `while`) and `(`
* Fix indent of `switch` and `case`

```c
switch (var) {
case 0:
    code;
}

// =>

switch (var) {
  case 0:
    code;
}
```

# 003: Add codes defined by "iyacc/yacc.c"

Because some codes are rendered by "iyacc/yacc.c", we need to add these codes to "iyacc.c" template.

Note: Codes like `Bprint(ftable, "...");` in "iyacc.c" are candidates of this modification.

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

# XXX: yypt -> yyvsp

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


