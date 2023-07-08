RSpec.describe Lrama::Counterexamples do
  let(:out) { "" }
  let(:warning) { Lrama::Warning.new(out) }

  describe "#compute" do
    # Example comes from https://www.cs.cornell.edu/andru/papers/cupex/cupex.pdf
    # "4. Constructing Nonunifying Counterexamples"
    describe "" do
      let(:y) do
        <<~STR
%{
// Prologue
%}

%union {
    int i;
}

%token <i> keyword_if
%token <i> keyword_then
%token <i> keyword_else
%token <i> arr
%token tEQ ":="
%token <i> digiti

%type <i> stmt
%type <i> expr
%type <i> num

%%

stmt : keyword_if expr keyword_then stmt keyword_else stmt
     | keyword_if expr keyword_then stmt
     | expr '?' stmt stmt
     | arr '[' expr ']' tEQ expr
     ;

expr : num
     | expr '+' expr
     ;

num  : digiti
     | num digiti
     ;

%%
        STR
      end

      it "" do
        grammar = Lrama::Parser.new(y).parse
        states = Lrama::States.new(grammar, warning)
        states.compute
        counterexamples = Lrama::Counterexamples.new(states)

        # State 17
        #
        #    1 stmt: keyword_if expr keyword_then stmt • keyword_else stmt
        #    2     | keyword_if expr keyword_then stmt •  ["end of file", keyword_if, keyword_else, arr, digiti]
        #
        #    keyword_else  shift, and go to state 20
        #    ...
        #    keyword_else   reduce using rule 2 (stmt)
        state_17 = states.states[17]
        keyword_else = states.find_symbol_by_s_value!("keyword_else")
        conflict_reduce_items = state_17.items.select {|item| !item.next_sym}
        expect(conflict_reduce_items.count).to eq 1

        triple, paths = counterexamples.compute(state_17, conflict_reduce_items.first, keyword_else)

        expect(paths.map(&:item).map(&:display_name)).to eq([
          "• stmt \"end of file\"  (rule 0)",
          "• keyword_if expr keyword_then stmt keyword_else stmt  (rule 1)",
          "keyword_if • expr keyword_then stmt keyword_else stmt  (rule 1)",
          "keyword_if expr • keyword_then stmt keyword_else stmt  (rule 1)",
          "keyword_if expr keyword_then • stmt keyword_else stmt  (rule 1)",
          "• keyword_if expr keyword_then stmt  (rule 2)",
          "keyword_if • expr keyword_then stmt  (rule 2)",
          "keyword_if expr • keyword_then stmt  (rule 2)",
          "keyword_if expr keyword_then • stmt  (rule 2)",
          "keyword_if expr keyword_then stmt •  (rule 2)"
        ])
        expect(paths.formated_paths).to eq([
          "• stmt \"end of file\"  (rule 0)",
          "  keyword_if expr keyword_then • stmt keyword_else stmt  (rule 1)",
          "                                 keyword_if expr keyword_then stmt •  (rule 2)"
        ])
      end
    end
  end
end
