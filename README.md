
# TODO

* lexer
  * [x] Basic functionalities
* parser
  * [x] Basic functionalities
  * [x] Precedence in grammar
* LALR
  * [x] compute_nullable
  * [x] compute_lr0_states
  * [x] Direct Read Sets
  * [x] Reads Relation
  * [x] Read Sets
  * [x] Includes Relation
  * [x] Lookback Relation
  * [x] Follow Sets
  * [x] Look-Ahead Sets
  * [x] Precedence support
  * [x] Conflict check
  * [x] Algorithm Digraph
* Rendering
  * [x] Table compaction
  * [x] -d option
  * [ ] yacc.c
    * [ ] %lex-param
    * [x] %parse-param
    * [x] %printer
    * [x] Replace $, @ in user codes
    * [x] `[@oline@]`
    * [ ] b4_symbol (for eof, error and so on)
    * Assumption
      * b4_locations_if is true
      * b4_pure_if is true
      * b4_pull_if is false
      * b4_lac_if is false
* Reporting
  * [ ] Bison style
* Error Tolerance
  * [x] Corchuelo et al. algorithm with N = 1 (this means the next token when error is raised)
  * [ ] Add new decl for error token semantic value initialization
  * [ ] Use YYMALLOC & YYFREE
