RSpec.describe Lrama::Counterexamples do
  let(:out) { "" }
  let(:warning) { Lrama::Warning.new(out) }

  describe "#compute" do
    # Example comes from https://www.cs.cornell.edu/andru/papers/cupex/cupex.pdf
    # "4. Constructing Nonunifying Counterexamples"
    describe "Example of 'Finding Counterexamples from Parsing Conflicts'" do
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
%token <i> digit

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

num  : digit
     | num digit
     ;


%%

        STR
      end

      it "" do
        grammar = Lrama::Parser.new(y).parse
        states = Lrama::States.new(grammar, warning)
        states.compute
        counterexamples = Lrama::Counterexamples.new(states)

        # State 6
        #
        #     5 expr: num •  ["end of file", keyword_if, keyword_then, keyword_else, arr, digit, '?', ']', '+']
        #     8 num: num • digit
        #
        #     digit  shift, and go to state 12
        #     digit         reduce using rule 5 (expr)
        state_6 = states.states[6]
        examples = counterexamples.compute(state_6)
        expect(examples.count).to eq 1
        example = examples[0]

        expect(example.type).to eq :shift_reduce
        # Shift Conflict
        expect(example.path1.map(&:to).map(&:item).map(&:to_s)).to eq([
          "$accept: • stmt \"end of file\"  (rule 0)",
          "stmt: • expr '?' stmt stmt  (rule 3)",
          "stmt: expr • '?' stmt stmt  (rule 3)",
          "stmt: expr '?' • stmt stmt  (rule 3)",
          "stmt: • arr '[' expr ']' \":=\" expr  (rule 4)",
          "stmt: arr • '[' expr ']' \":=\" expr  (rule 4)",
          "stmt: arr '[' • expr ']' \":=\" expr  (rule 4)",
          "stmt: arr '[' expr • ']' \":=\" expr  (rule 4)",
          "stmt: arr '[' expr ']' • \":=\" expr  (rule 4)",
          "stmt: arr '[' expr ']' \":=\" • expr  (rule 4)",
          "expr: • num  (rule 5)",
          "num: • num digit  (rule 8)",
          "num: num • digit  (rule 8)"
        ])
        expect(example.derivations1.render_for_report).to eq(<<~STR.chomp)
          0:  stmt                                                          "end of file"
              3: expr '?' stmt                                         stmt
                          4: arr '[' expr ']' ":=" expr
                                                   5:  num
                                                       8: num  • digit
        STR
        # Reduce Conflict
        expect(example.path2.map(&:to).map(&:item).map(&:to_s)).to eq([
          "$accept: • stmt \"end of file\"  (rule 0)",
          "stmt: • expr '?' stmt stmt  (rule 3)",
          "stmt: expr • '?' stmt stmt  (rule 3)",
          "stmt: expr '?' • stmt stmt  (rule 3)",
          "stmt: • arr '[' expr ']' \":=\" expr  (rule 4)",
          "stmt: arr • '[' expr ']' \":=\" expr  (rule 4)",
          "stmt: arr '[' • expr ']' \":=\" expr  (rule 4)",
          "stmt: arr '[' expr • ']' \":=\" expr  (rule 4)",
          "stmt: arr '[' expr ']' • \":=\" expr  (rule 4)",
          "stmt: arr '[' expr ']' \":=\" • expr  (rule 4)",
          "expr: • num  (rule 5)",
          "expr: num •  (rule 5)"
        ])
        expect(example.derivations2.render_for_report).to eq(<<~STR.chomp)
          0:  stmt                                                "end of file"
              3: expr '?' stmt                                stmt
                          4: arr '[' expr ']' ":=" expr       3:  expr             '?' stmt stmt
                                                   5: num  •      5:  num
                                                                      7:   • digit
        STR


        # State 16
        #
        #     6 expr: expr • '+' expr
        #     6     | expr '+' expr •  ["end of file", keyword_if, keyword_then, keyword_else, arr, digit, '?', ']', '+']
        #
        #     '+'  shift, and go to state 11
        #     '+'            reduce using rule 6 (expr)
        state_16 = states.states[16]
        examples = counterexamples.compute(state_16)
        expect(examples.count).to eq 1
        example = examples[0]

        expect(example.type).to eq :shift_reduce
        # Shift Conflict
        expect(example.path1.map(&:to).map(&:item).map(&:to_s)).to eq([
          "$accept: • stmt \"end of file\"  (rule 0)",
          "stmt: • expr '?' stmt stmt  (rule 3)",
          "expr: • expr '+' expr  (rule 6)",
          "expr: • expr '+' expr  (rule 6)",
          "expr: expr • '+' expr  (rule 6)",
          "expr: expr '+' • expr  (rule 6)",
          "expr: • expr '+' expr  (rule 6)",
          "expr: expr • '+' expr  (rule 6)"
        ])
        expect(example.derivations1.render_for_report).to eq(<<~STR.chomp)
          0:  stmt                                                                "end of file"
              3:  expr                                              '?' stmt stmt
                  6:  expr                                 '+' expr
                      6: expr '+' expr
                                  6: expr  • '+' expr expr
        STR
        # Reduce Conflict
        expect(example.path2.map(&:to).map(&:item).map(&:to_s)).to eq([
          "$accept: • stmt \"end of file\"  (rule 0)",
          "stmt: • expr '?' stmt stmt  (rule 3)",
          "expr: • expr '+' expr  (rule 6)",
          "expr: • expr '+' expr  (rule 6)",
          "expr: expr • '+' expr  (rule 6)",
          "expr: expr '+' • expr  (rule 6)",
          "expr: expr '+' expr •  (rule 6)"
        ])
        expect(example.derivations2.render_for_report).to eq(<<~STR.chomp)
        0:  stmt                                                "end of file"
            3:  expr                              '?' stmt stmt
                6:  expr                 '+' expr
                    6: expr '+' expr  •
        STR


        # State 17
        #
        #    1 stmt: keyword_if expr keyword_then stmt • keyword_else stmt
        #    2     | keyword_if expr keyword_then stmt •  ["end of file", keyword_if, keyword_else, arr, digit]
        #
        #    keyword_else  shift, and go to state 20
        #    keyword_else   reduce using rule 2 (stmt)
        state_17 = states.states[17]
        examples = counterexamples.compute(state_17)
        expect(examples.count).to eq 1
        example = examples[0]

        expect(example.type).to eq :shift_reduce
        # Shift Conflict
        expect(example.path1.map(&:to).map(&:item).map(&:to_s)).to eq([
          "$accept: • stmt \"end of file\"  (rule 0)",
          "stmt: • keyword_if expr keyword_then stmt keyword_else stmt  (rule 1)",
          "stmt: keyword_if • expr keyword_then stmt keyword_else stmt  (rule 1)",
          "stmt: keyword_if expr • keyword_then stmt keyword_else stmt  (rule 1)",
          "stmt: keyword_if expr keyword_then • stmt keyword_else stmt  (rule 1)",
          "stmt: • keyword_if expr keyword_then stmt keyword_else stmt  (rule 1)",
          "stmt: keyword_if • expr keyword_then stmt keyword_else stmt  (rule 1)",
          "stmt: keyword_if expr • keyword_then stmt keyword_else stmt  (rule 1)",
          "stmt: keyword_if expr keyword_then • stmt keyword_else stmt  (rule 1)",
          "stmt: keyword_if expr keyword_then stmt • keyword_else stmt  (rule 1)"
        ])
        expect(example.derivations1.render_for_report).to eq(<<~STR.chomp)
          0:  stmt                                                                                                             "end of file"
              1: keyword_if expr keyword_then stmt                                                           keyword_else stmt
                                              1: keyword_if expr keyword_then stmt  • keyword_else stmt stmt
        STR
        # Reduce Conflict
        expect(example.path2.map(&:to).map(&:item).map(&:to_s)).to eq([
          "$accept: • stmt \"end of file\"  (rule 0)",
          "stmt: • keyword_if expr keyword_then stmt keyword_else stmt  (rule 1)",
          "stmt: keyword_if • expr keyword_then stmt keyword_else stmt  (rule 1)",
          "stmt: keyword_if expr • keyword_then stmt keyword_else stmt  (rule 1)",
          "stmt: keyword_if expr keyword_then • stmt keyword_else stmt  (rule 1)",
          "stmt: • keyword_if expr keyword_then stmt  (rule 2)",
          "stmt: keyword_if • expr keyword_then stmt  (rule 2)",
          "stmt: keyword_if expr • keyword_then stmt  (rule 2)",
          "stmt: keyword_if expr keyword_then • stmt  (rule 2)",
          "stmt: keyword_if expr keyword_then stmt •  (rule 2)"
        ])
        expect(example.derivations2.render_for_report).to eq(<<~STR.chomp)
          0:  stmt                                                                                       "end of file"
              1: keyword_if expr keyword_then stmt                                     keyword_else stmt
                                              2: keyword_if expr keyword_then stmt  •
        STR
      end
    end
  end
end
