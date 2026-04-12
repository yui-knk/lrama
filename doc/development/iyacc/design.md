# Design of iyacc template

## The strucute of "iyacc.c" template file

```c
// (1) Few macros are defined

// (2) prologue

// (3) Include or embed parser header file

// (4) Include other header files

// (5) Many macros and types are defined

// (6) Functions are defined

// (7)`yyparse` function is defined

// (8) epilogue
```

## Event loop

## Scope of local variables

## Symbol and token conversions

`enum yysymbol_kind_t` and its typedef `yysymbol_kind_t`.
This enum includes both terminals and nonterminals on this order.


`enum yytokentype` and its typdef `yytoken_kind_t`.
yylex is expected to return `enum yytokentype`.

