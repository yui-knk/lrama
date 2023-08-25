RSpec.describe "IELR parser" do
  let(:out) { "" }
  let(:warning) { Lrama::Warning.new(out) }

  describe "" do
    # Example comes from https://www.sciencedirect.com/science/article/pii/S0167642309001191
    # Fig. 5.
    describe "" do
      let(:y) do
        <<~STR
%{
// Prologue
%}

%define lr.type ielr

%union {
    int i;
}

%token a
%token b
%token c

%%

S    : a A B a
     | b A B b
     ;

A    : a C D E
     ;

B    : C
     | /* none */
     ;

C    : D
     ;

D    : a
     ;

E    : a
     | /* none */
     ;

%%

        STR
      end

      it "build counterexamples of S/R conflicts" do
        grammar = Lrama::Parser.new(y).parse
        states = Lrama::States.new(grammar, warning)
        states.compute
      end
    end
  end
end
