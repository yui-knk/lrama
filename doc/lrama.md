# The Lrama Parser Generator

## How to use

### Generate parser

### Use generated parser

#### `yyparse`

#### `yylex`

## Grammar File Syntax

### Production rules

### Precedence and associativity

### Directives

#### %token
#### %type

#### %union

#### %expect

#### %nonassoc
#### %left
#### %right

#### %define

#### %printer
#### %destructor

#### %lex-param 
#### %parse-param

#### %initial-action

#### %rule

#### %after-shift
#### %before-reduce
#### %after-reduce
#### %after-shift-error-token
#### %after-pop-stack

### Variables in action

#### $$, $n and $name

#### @$, @n and @name

#### $:1 and $:name

`$:$` is not allowed.

### Types, Variables, Macros and Functions

#### Types

##### `YYSTYPE`

Semantic value TYPE.

##### `YYLTYPE`

Location value TYPE.

##### `enum yytokentype`


#### Variables

##### `yychar`

##### `yydebug`


#### Macros

##### `YYEMPTY`

##### `YYPURE`

##### `YYSTYPE_IS_DECLARED`

##### `YYLTYPE_IS_DECLARED`


#### Functions

##### `yyparse`

##### `yylex`

## Advanced features

### Parameterizing rules

TBD.

### Bring Your Own Stack

## Terminology

### Symbol

### Nonterminal Symbol

### Terminal Symbol

### Tag

### Action

