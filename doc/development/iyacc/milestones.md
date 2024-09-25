# Milestone 1: Create new template and setup test environment

The first milestone is to create new template and enable CI for new template parser.

## The strucute of "iyacc.c" template file

```c
// (1) Few macros are defined

// (2) prologue

// (3) Include or embed parser header file

// (4) Standard header inclusion

// (5) Many macros and types are defined

// (6) Functions are defined

// (7)`yyparse` function is defined

// (8) epilogue
```

## Event loop

## Scope of local variables

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
* `YYSTYPE yyval` is semantic value of LHS set by each action. `$$` is expanded into `yyval`.
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

# 002: Setup test environment

Setup test environment for iyacc based parser.
To reuse existing test cases, update "spec/lrama/integration_spec.rb".

* Extend `#test_parser` method to accept `template:` keyword argument, its default value is nil.
* Append `-S` option to `lrama_command_args` if `template` is specified.
* Add an assertion to "calculator" test case.

The goal of milestone 1 is to pass "calculator" test case.

# 003: Formatting

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

* Replace `<%` in `sprint` arguments with `<%%`. Because "iyacc.c" template is evaluated as ERB template, `<%` is needed to be escaped with `<%%`.

# 004: Add missed variables and macros to the template

Because some codes are rendered by "iyacc/yacc.c", we need to add these codes to "iyacc.c" template.

Note: Codes like `Bprint(ftable, "...");` in "iyacc.c" are candidates of this modification.

## `YYMAXDEPTH`

`YYMAXDEPTH` manages max size of parser stack.
Define `YYMAXDEPTH` with `200` if `YYMAXDEPTH` is not defined.
Right now, iyacc doesn't expand parser stack then `YYMAXDEPTH` is same with default parser stack size.
This will be separated into `YYINITDEPTH` and `YYMAXDEPTH` later.

## `YYSTYPE`

`YYSTYPE` is a type for semantic value data structure.
`STYPE` might stand for Semantic TYEP.

Define `YYSTYPE` and `YYSTYPE_IS_DECLARED` if `YYSTYPE` is not defined and `YYSTYPE_IS_DECLARED` is not defined.
`YYSTYPE` is an union whose content is `output.grammar.union.braces_less_code`.
Also declare `YYSTYPE` as a new type by `typedef`.

For easy debug of generated parser, change file name and line number just before `output.grammar.union.braces_less_code` is rendered and restore original file name and line number once rendering is completed. `#line` directive is enough for both cases. `[@ofile@]` and `[@oline@]` are replaced to original file name and line number by `Lrama::Output#replace_special_variables`.

Code example is like this:

```ruby
puts <<~CODE
#line #{output.grammar.union.lineno} "#{output.grammar_file_path}"
#{output.grammar.union.braces_less_code}
#line [@oline@] [@ofile@]
CODE
```

## `YYLTYPE`

`YYLTYPE` is a type for location data structure.
`LTYPE` might stand for Location TYEP.

Define `YYLTYPE` and `YYLTYPE_IS_DECLARED` if `YYLTYPE` is not defined and `YYLTYPE_IS_DECLARED` is not defined.
`YYLTYPE` is a struct whose content is `first_line`, `first_column`, `last_line` and `last_column`, all of them are `int`.
Also declare `YYLTYPE` as a new type by `typedef`.

No grammar file declarations affect the dafault structure of `YYLTYPE` then no need to templatize `YYLTYPE`.

## `yylval`

`yylval` is semantic value updated by `yylex`, whose type is `YYSTYPE`.
This is not defined in orignal iyacc template then define `yylval` as local variable in `yyparse` function.

`lval` might stand for Lexer semantic VALue.

## `yyval`

`yyval` is semantic value of LHS set by each action, whose type is `YYSTYPE`.
This is not defined in orignal iyacc template then define `yyval` as local variable in `yyparse` function.

## `yylloc`

`yylloc` is location information updated by `yylex`, whose type is `YYLTYPE`.
This is not defined in orignal iyacc template then define `yylloc` as local variable in `yyparse` function.

`lloc` might stand for Lexer LOCation.

## `yyloc`

`yyloc` is location information of LHS set by each action, whose type is `YYLTYPE`.
This is not defined in orignal iyacc template then define `yyloc` as local variable in `yyparse` function.

# 005: Fix `yylex` function

## Remove `yylex1` function

We expect users to provide `yylex` fuction then:

* Remove `yylex1` function definition from the template
* Rename `yylex1` function call to `yylex` function call

## Support prologue

Lexer header, e.g. "calculator-lexer.h", is included into grammar file by prologue section.
Therefore need to support prologue to run the test case .

The content of prologue is contained in `output.aux.prologue`. If prologue is not defined, no need to render anything about prologue, so check `output.aux.prologue` before try to render it.

For easy debug of generated parser, change file name and line number just before `output.aux.prologue` is rendered and restore original file name and line number once rendering is completed. `#line` directive is enough for both cases. `[@ofile@]` and `[@oline@]` are replaced to original file name and line number by `Lrama::Output#replace_special_variables`.

Code example is like this:

```ruby
if output.aux.prologue
puts <<~CODE
#line #{output.aux.prologue_first_lineno} "#{output.grammar_file_path}"
#{output.aux.prologue}
#line [@oline@] [@ofile@]
CODE
end
```

## Fix arguments of `yylex` function call

Arguments passed to `yylex` changes depending on `%locations`, `%lex-param` and `%param` directive are specified in the grammar file.
Then need to change `yylex` arguments to be `output.yylex_formals`.

# 006: Remove error recovery codes

We will implement panic mode error recovery laster then remove error recovery codes right now.
There are two error recovery codes, one is `if (yyn == -2) { ... }` in `yydefault` and another is `if (yyn == 0) { ... }` in `yydefault`. Remove both of them.

# 007: Fix compressed state table

How to compress state table in iyacc is a bit different from how Lrama compresses.
Replase compressed state table access algorithm.
"compressed_state_table/main.md" explains the algorithm, please see it too.

These variable usages are removed with this change.

* `yyact`
* `yychk`
* `yydef`
* `yypgo`

## Define macros, variables and types:

### Macros

* `YYFINAL` macro
  * State id which accepts the input.
  * `output.yyfinal` provides the corresponding value.
* `YYLAST` macro
  * Last valid index of `yycheck` and `yytable`.
  * `output.yylast` provides the corresponding value.
* `YYNTOKENS` macro
  * 
  * `output.yyntokens` provides the corresponding value.
* `YYPACT_NINF` macro.
  * Negative INFinity number in `yypact`.
  * `output.yypact_ninf` provides the corresponding value.
* `YYTABLE_NINF` macro
  * Negative INFinity number in `yytable`.
  * `output.yytable_ninf` provides the corresponding value.

### Static const variables

* `yypact` array.
  * This array stores offset on `yytable`. If value is `YYPACT_NINF`, it means execution of default reduce action.
  * Index is state id.
* `yydefact` array.
  * This array stores rule id of default actions. If value is `0`, it means syntax error.
  * Index is state id.
* `yypgoto` array.
  * This array stores offset on `yytable`. If value is `YYPACT_NINF`, it means execution of default reduce action.
  * Index is nonterminal id.
* `yydefgoto` array.
  * This array stores next state id.
  * Index is nonterminal id.
* `yytable` array.
  * This array is a mixture of action table and GOTO table. As action table, `YYTABLE_NINF` means syntax error, positive number means shift and next state is the number, negative number and zero mean reducing with the rule whose number is opposite.
  * Index is `yypact[state] + token_id` for action table parts and `yypgoto[nonterminal] + state` for GOTO table parts.
* `yycheck` array.
  * This array stores indexes of original action table and GOTO table. We can validate access to `yytable` by consulting this array.
  * Index is same with `yytable`.
* `yyr1` array.
  * This array stores nonterminal symbol id of rule's Left-Hand-Side.
  * Index is rule id.
* `yyr2` array.
  * This array stores the length of the rule, that is, number of symbols on the rule's Right-Hand-Side.
  * Index is rule id.

For static const array, `Lrama::Output` provides some helper methods:

* `output.context.xxx` provides the corresponding value.
* `Output#int_type_for(ary)` returns appropriate type based on the number of `ary`
* `Output#int_array_to_string(ary)` returns formatted string of `ary`.

### Types

`Output#int_type_for` returns these types.
Right now, define these types with `int` and `unsigned int` simply.

* `yytype_int8` as `int`
* `yytype_uint8` as `unsigned int`
* `yytype_int16` as `int`
* `yytype_uint16` as `unsigned int`

## Update compressed state table codes

### Declear local variables in `yyparse`

* `int yyrule`

### Define macros

```c
#define yyunreachable() assert(0 && "unreachable")
```

### Change `yynewstate`

See also `:decide_parser_action` in "compressed_state_table/parser.rb".

* `int yyoffset`
* `int yyindex`
* `int yyaction`


* Lookup `yypact` by `yystate` to get `yyoffset`.
* Check `yyoffset`.
  * If it's same with `YYPACT_NINF`, go to `yydefault`.
* Ensure next token (`yychar`) is set. If not, call `yychar` to get next token
* Check next token.
  * If it's same with `output.error_symbol.id.s_value`, go to `ret1`.
* It's ready to decide next action, calculate index (`yyindex = yyoffset + yychar`).
* Check `yyindex`.
  * Valid range of `yyindex` is greater or equal to 0 and less or equal to `YYLAST`. If it's out of range, go to `yydefault`.
  * If `yycheck[yyindex]` is not same with `yychar`, go to `yydefault`.
* Lookup `yytable` by `yyindex` and assign the value to `yyaction`.
  * If the value is `YYTABLE_NINF` then go to `ret1`.
  * If the value is greater than 0, it means shift.
    * Clear `yychar` to `-1` so that next token is fetched in next loop.
    * Assign `yylval` to `yyval` so that semantic value returned from `yylex` is pushed into stack by `yystack`.
    * Assign `yyaction` to `yystate`.
    * Go to `yystack`.
  * Otherwise it means reduce. Assgin `-yyaction` to `yyrule` then go to `yyreduce`. Note: `yyreduce` is introduced later.
* Call `yyunreachable()` on the end of `yynewstate`

### Change `yydefault`



### Change `yyreduce`

* `int yyoffset`
* `int yyindex`
* `int yy_lhs_nterm`
* `int yy_rhs_len`

* Execute semantic value action
  * `output.user_actions`

```c
default:
    break;
```

* Pop parser stack by `yy_rhs_len`
  * `yyp`

* Call `yyunreachable()` on the end of `yynewstate`


# 008: Embed actions

`$A`

`output.user_actions`

yyvsp

# Step 2: Modernize iyacc

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


