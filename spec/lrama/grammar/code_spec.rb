# frozen_string_literal: true

RSpec.describe Lrama::Grammar::Code do
  describe ".from_token" do
    let(:text) { " $value; " }
    let(:grammar_file) { Lrama::Lexer::GrammarFile.new("test.y", text) }
    let(:location) { Lrama::Lexer::Location.new(grammar_file: grammar_file, first_line: 1, first_column: 0, last_line: 1, last_column: text.length) }
    let(:token) { Lrama::Lexer::Token::UserCode.new(s_value: text, location: location) }

    it "preserves the source text and location for code generation and diagnostics" do
      code = described_class.from_token(token, type: :rule_action)

      expect(code.text).to eq(text)
      expect(code.location).to equal(location)
      expect(code.line).to eq(1)
      expect(code.column).to eq(0)
      expect(code.references.first.name).to eq("value")
    end

    it "keeps reference resolution state separate for each conversion" do
      first = described_class.from_token(token, type: :rule_action)
      first.references.first.name = "$"
      first.references.first.index = 1

      second = described_class.from_token(token, type: :rule_action)

      expect(second.references.first.name).to eq("value")
      expect(second.references.first.index).to be_nil
      expect(token.s_value).to eq(text)
    end
  end

  describe "#initialize" do
    it "requires an explicit type" do
      expect { described_class.new(text: "code") }.to raise_error(ArgumentError, /missing keyword: :type/)
    end

    it "preserves references resolved during grammar expansion" do
      original = described_class.new(type: :rule_action, text: " $value; ")
      references = original.references.map(&:dup)
      references.first.name = "argument"
      references.first.number = 2
      references.first.index = 2

      expanded = described_class.new(type: :rule_action, text: original.text, references: references)

      expect(expanded.references.first.name).to eq("argument")
      expect(expanded.references.first.index).to eq(2)
      expect(original.references.first.name).to eq("value")
      expect(original.references.first.index).to be_nil
    end
  end

  describe "#translated_code" do
    it "translates references through a subclass without changing the source" do
      code = described_class::InitialActionCode.new(type: :initial_action, text: "print($$);")

      expect(code.translated_code).to eq("print(yylval);")
      expect(code.translated_code).to eq("print(yylval);")
      expect(code.text).to eq("print($$);")
      expect(code.references.first.name).to eq("$")
    end
  end

  describe "#references" do
    let(:grammar_file) { Lrama::Lexer::GrammarFile.new("test.y", "") }
    let(:location) { Lrama::Lexer::Location.new(grammar_file: grammar_file, first_line: 1, first_column: 0, last_line: 1, last_column: 2) }

    it "returns references in user code" do
      # $$
      references = Lrama::Grammar::Code.new(type: :rule_action, text: " $$ ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, name: "$", ex_tag: nil, first_column: 1, last_column: 3)
      references = Lrama::Grammar::Code.new(type: :rule_action, text: " $<long>$ ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, name: "$", ex_tag: Lrama::Lexer::Token::Tag.new(s_value: "<long>"), first_column: 1, last_column: 9)

      # $1
      references = Lrama::Grammar::Code.new(type: :rule_action, text: " $1 ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, number: 1, index: 1, ex_tag: nil, first_column: 1, last_column: 3)
      references = Lrama::Grammar::Code.new(type: :rule_action, text: " $<long>1 ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, number: 1, index: 1, ex_tag: Lrama::Lexer::Token::Tag.new(s_value: "<long>"), first_column: 1, last_column: 9)
      references = Lrama::Grammar::Code.new(type: :rule_action, text: " $<value.integer>1 ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, number: 1, index: 1, ex_tag: Lrama::Lexer::Token::Tag.new(s_value: "<value.integer>"), first_column: 1, last_column: 18)

      # $foo
      references = Lrama::Grammar::Code.new(type: :rule_action, text: " $foo ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, name: "foo", ex_tag: nil, first_column: 1, last_column: 5)
      references = Lrama::Grammar::Code.new(type: :rule_action, text: " $<long>foo ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, name: "foo", ex_tag: Lrama::Lexer::Token::Tag.new(s_value: "<long>"), first_column: 1, last_column: 11)

      # $[expr.right]
      references = Lrama::Grammar::Code.new(type: :rule_action, text: " $[expr.right] ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, name: "expr.right", ex_tag: nil, first_column: 1, last_column: 14)
      references = Lrama::Grammar::Code.new(type: :rule_action, text: " $<long>[expr.right] ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, name: "expr.right", ex_tag: Lrama::Lexer::Token::Tag.new(s_value: "<long>"), first_column: 1, last_column: 20)

      # @$
      references = Lrama::Grammar::Code.new(type: :rule_action, text: " @$ ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :at, name: "$", ex_tag: nil, first_column: 1, last_column: 3)

      # @1
      references = Lrama::Grammar::Code.new(type: :rule_action, text: " @1 ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :at, number: 1, index: 1, ex_tag: nil, first_column: 1, last_column: 3)

      # @foo
      references = Lrama::Grammar::Code.new(type: :rule_action, text: " @foo ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :at, name: "foo", ex_tag: nil, first_column: 1, last_column: 5)

      # @[expr.right]
      references = Lrama::Grammar::Code.new(type: :rule_action, text: " @[expr.right] ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :at, name: "expr.right", ex_tag: nil, first_column: 1, last_column: 14)
    end

    ["\n", "\r\n"].each do |newline|
      it "ignores references in a continued line comment with #{newline.inspect}" do
        code = "$1; // comment\\#{newline}$9; @9; $:9;#{newline}$2;"
        references = described_class.new(type: :rule_action, text: code, location: location).references

        expect(references.map { |ref| [ref.type, ref.number] }).to eq([[:dollar, 1], [:dollar, 2]])
        expect(references.last.first_column).to eq(code.index('$2'))
      end
    end

    it "uses character offsets after multibyte comments and literals" do
      lexemes = %w[$$ $<long>$ $1 $<long>1 $foo $[expr.right] @$ @1 @foo @[expr.right] $:$ $:1 $:foo $:[expr.right]]
      code = "/* 日本 */\nputs(\"é🙂\"); #{lexemes.join('; ')};"

      references = described_class.new(type: :rule_action, text: code, location: location).references

      expect(references.map { |ref| code[ref.first_column...ref.last_column] }).to eq(lexemes)
    end

    it "ignores references in C literals and comments" do
      code = <<~'C'
        $1;
        printf("total $2 and @2 \"done\"");
        int character = '$3';
        // note $3 and @3
        $4; @4;
        /* note $5 and @5 */
      C

      references = Lrama::Grammar::Code.new(type: :rule_action, text: code, location: location).references

      expect(references.map { |ref| [ref.type, ref.index] }).to eq([[:dollar, 1], [:dollar, 4], [:at, 4]])
    end
  end

  let(:token_class) { Lrama::Lexer::Token }
  let(:code_dollar_dollar) { Lrama::Grammar::Code.new(type: :rule_action, text: 'print($$);') }
  let(:code_at_dollar) { Lrama::Grammar::Code.new(type: :rule_action, text: 'print(@$);') }
  let(:code_index_dollar) { Lrama::Grammar::Code.new(type: :rule_action, text: 'print($:$);') }
  let(:code_dollar_n) { Lrama::Grammar::Code.new(type: :rule_action, text: 'print($n);') }
  let(:code_at_n) { Lrama::Grammar::Code.new(type: :rule_action, text: 'print(@n);') }
  let(:code_index_n) { Lrama::Grammar::Code.new(type: :rule_action, text: 'print($:1);') }

  describe Lrama::Grammar::Code::InitialActionCode do
    describe "#translated_code" do
      it "translates '$$' to 'yylval'" do
        code = described_class.new(type: :initial_action, text: code_dollar_dollar.text)
        expect(code.translated_code).to eq("print(yylval);")
      end

      it "translates '@$' to 'yylloc'" do
        code = described_class.new(type: :initial_action, text: code_at_dollar.text)
        expect(code.translated_code).to eq("print(yylloc);")
      end

      it "raises error for '$:$'" do
        code = described_class.new(type: :initial_action, text: code_index_dollar.text)
        expect { code.translated_code }.to raise_error("$:$ can not be used in initial_action.")
      end

      it "raises error for '$n'" do
        code = described_class.new(type: :initial_action, text: code_dollar_n.text)
        expect { code.translated_code }.to raise_error("$n can not be used in initial_action.")
      end

      it "raises error for '@n'" do
        code = described_class.new(type: :initial_action, text: code_at_n.text)
        expect { code.translated_code }.to raise_error("@n can not be used in initial_action.")
      end

      it "raises error for '$:n'" do
        code = described_class.new(type: :initial_action, text: code_index_n.text)
        expect { code.translated_code }.to raise_error("$:1 can not be used in initial_action.")
      end
    end
  end

  describe Lrama::Grammar::Code::NoReferenceCode do
    describe "#translated_code" do
      it "raises error for '$$'" do
        code = described_class.new(type: :union, code: code_dollar_dollar)
        expect { code.translated_code }.to raise_error("$$ can not be used in union.")
      end

      it "raises error for '@$'" do
        code = described_class.new(type: :union, code: code_at_dollar)
        expect { code.translated_code }.to raise_error("@$ can not be used in union.")
      end

      it "raises error for '$:$'" do
        code = described_class.new(type: :union, code: code_index_dollar)
        expect { code.translated_code }.to raise_error("$:$ can not be used in union.")
      end

      it "raises error for '$n'" do
        code = described_class.new(type: :union, code: code_dollar_n)
        expect { code.translated_code }.to raise_error("$n can not be used in union.")
      end

      it "raises error for '@n'" do
        code = described_class.new(type: :union, code: code_at_n)
        expect { code.translated_code }.to raise_error("@n can not be used in union.")
      end

      it "raises error for '$:n'" do
        code = described_class.new(type: :union, code: code_index_n)
        expect { code.translated_code }.to raise_error("$:1 can not be used in union.")
      end
    end
  end

  describe Lrama::Grammar::Code::DestructorCode do
    describe "#translated_code" do
      let(:tag) { token_class::Tag.new(s_value: '<val>') }

      it "translates '$$' to '((*yyvaluep).val)'" do
        code = described_class.new(type: :destructor, code: code_dollar_dollar, tag: tag)
        expect(code.translated_code).to eq("print(((*yyvaluep).val));")
      end

      it "translates '@$' to '(*yylocationp)'" do
        code = described_class.new(type: :destructor, code: code_at_dollar, tag: tag)
        expect(code.translated_code).to eq("print((*yylocationp));")
      end

      it "raises error for '$:$'" do
        code = described_class.new(type: :destructor, code: code_index_dollar, tag: tag)
        expect { code.translated_code }.to raise_error("$:$ can not be used in destructor.")
      end

      it "raises error for '$n'" do
        code = described_class.new(type: :destructor, code: code_dollar_n, tag: tag)
        expect { code.translated_code }.to raise_error("$n can not be used in destructor.")
      end

      it "raises error for '@n'" do
        code = described_class.new(type: :destructor, code: code_at_n, tag: tag)
        expect { code.translated_code }.to raise_error("@n can not be used in destructor.")
      end

      it "raises error for '$:n'" do
        code = described_class.new(type: :destructor, code: code_index_n, tag: tag)
        expect { code.translated_code }.to raise_error("$:1 can not be used in destructor.")
      end
    end
  end

  describe Lrama::Grammar::Code::PrinterCode do
    describe "#translated_code" do
      let(:tag) { token_class::Tag.new(s_value: '<val>') }

      it "translates '$$' to '((*yyvaluep).val)'" do
        code = described_class.new(type: :printer, code: code_dollar_dollar, tag: tag)
        expect(code.translated_code).to eq("print(((*yyvaluep).val));")
      end

      it "translates '@$' to '(*yylocationp)'" do
        code = described_class.new(type: :printer, code: code_at_dollar, tag: tag)
        expect(code.translated_code).to eq("print((*yylocationp));")
      end

      it "raises error for '$:$'" do
        code = described_class.new(type: :printer, code: code_index_dollar, tag: tag)
        expect { code.translated_code }.to raise_error("$:$ can not be used in printer.")
      end

      it "raises error for '$n'" do
        code = described_class.new(type: :printer, code: code_dollar_n, tag: tag)
        expect { code.translated_code }.to raise_error("$n can not be used in printer.")
      end

      it "raises error for '@n'" do
        code = described_class.new(type: :printer, code: code_at_n, tag: tag)
        expect { code.translated_code }.to raise_error("@n can not be used in printer.")
      end

      it "raises error for '$:n'" do
        code = described_class.new(type: :printer, code: code_index_n, tag: tag)
        expect { code.translated_code }.to raise_error("$:1 can not be used in printer.")
      end
    end
  end

  describe Lrama::Grammar::Code::RuleAction do
    let(:y) do
      <<~GRAMMAR
        %union {
            int i;
            int str;
            int l;
            int expr;
            int integer;
            int rule1;
            int rule2;
            int rule3;
            int rule4;
            int rule5;
            int rule6;
            int rule7;
            struct { int integer; } value;
        }

        %token <i> keyword_class
        %token <str> tSTRING
        %token <l> keyword_end
        %token <expr> expr

        %type <rule1> rule1
        %type <rule2> rule2
        %type <rule3> rule3
        %type <rule4> rule4
        %nterm <rule5> rule5
        %nterm <rule6> rule6
        %nterm <rule7> rule7

        %%

        program: rule1
               | rule2
               | rule3
               | rule4
               | rule5
               | rule6
               | rule7
               | rule8
               | rule9
               | rule10
               | rule11
               | rule12
               | rule13
               ;

        rule1: expr '+' expr { $$ = 0; }
             ;

        rule2: expr '+' expr { @$ = 0; }
             ;

        rule3: expr '+' expr[expr-right] { $1 + $[expr-right]; }
             ;

        rule4: expr '+' expr[expr-right] { @1 + @[expr-right]; @0; }
             ;

        rule5: expr '+' expr { $1 + $<value.integer>3; }
             ;

        rule6: expr '+' { $<integer>$ = $1; @$ = @1; } expr { $1 + $<integer>4; }
             ;

        rule7: expr { $$ = $1 } '+' expr { $2; }
             ;

        rule8: expr { $$ = $1 } '+' expr { $2; }
             ;

        rule9: expr '+' expr { $:1; $:2; $:3; }
             ;

        rule10: expr '+' expr { $:$; }
              ;

        rule11: expr { $:1; } '+' expr { $:1; $:2; $:3; $:4; }
              ;

        rule12: expr '+' expr[expr-right] { $:1; $:2; $:[expr-right]; }
              ;

        rule13: expr '+' { $$ = $1; @$ = @1; }<integer> expr { $1 + $3; }
              ;
        %%
      GRAMMAR
    end
    let(:grammar) do
      grammar = Lrama::Parser.new(y, "parse.y").parse
      grammar.prepare
      grammar.validate!
      grammar
    end

    describe "#translated_code" do
      ["", " foo(); bar();"].each do |suffix|
        it "preserves multibyte text when translating references with suffix #{suffix.inspect}" do
          y = <<~GRAMMAR
            %union { int i; }
            %token <i> NUM
            %type <i> expr
            %%
            expr: NUM { /* 日本語 */ $$ = $1;#{suffix} };
          GRAMMAR
          grammar = Lrama::Parser.new(y, "parse.y").parse
          grammar.prepare
          grammar.validate!

          expect(grammar.rules.last.translated_code(grammar)).to eq(" /* 日本語 */ (yyval.i) = (yyvsp[0].i);#{suffix} ")
        end
      end

      it "translates '$$' to '(yyval)' with member" do
        code = grammar.rules.find {|r| r.lhs.id.name == "rule1" }
        expect(code.translated_code(grammar)).to eq(" (yyval.rule1) = 0; ")
      end

      it "translates '@$' to '(yyloc)'" do
        code = grammar.rules.find {|r| r.lhs.id.name == "rule2" }
        expect(code.translated_code(grammar)).to eq(" (yyloc) = 0; ")
      end

      it "translates '$n' to '(yyvsp)' with index and member" do
        code = grammar.rules.find {|r| r.lhs.id.name == "rule3" }
        expect(code.translated_code(grammar)).to eq(" (yyvsp[-2].expr) + (yyvsp[0].expr); ")
      end

      it "translates '@n' to '(yylsp)' with index" do
        code = grammar.rules.find {|r| r.lhs.id.name == "rule4" }
        expect(code.translated_code(grammar)).to eq(" (yylsp[-2]) + (yylsp[0]); (yylsp[-3]); ")
      end

      it "respects explicit tag in a rule" do
        code = grammar.rules.find {|r| r.lhs.id.name == "rule5" }
        expect(code.translated_code(grammar)).to eq(" (yyvsp[-2].expr) + (yyvsp[0].value.integer); ")
      end

      context "midrule action exists" do
        it "uses index on the original rule (-1)" do
          # midrule action in rule6
          code = grammar.rules.find {|r| r.lhs.id.name == "$@1" }
          expect(code.translated_code(grammar)).to eq(" (yyval.integer) = (yyvsp[-1].expr); (yyloc) = (yylsp[-1]); ")

          code = grammar.rules.find {|r| r.lhs.id.name == "rule6" }
          expect(code.translated_code(grammar)).to eq(" (yyvsp[-3].expr) + (yyvsp[0].integer); ")
        end

        it "uses an explicit tag for type casting" do
          # midrule action in rule13
          code = grammar.rules.find {|r| r.lhs.id.name == "@5" }
          expect(code.translated_code(grammar)).to eq(" (yyval.integer) = (yyvsp[-1].expr); (yyloc) = (yylsp[-1]); ")

          code = grammar.rules.find {|r| r.lhs.id.name == "rule13" }
          expect(code.translated_code(grammar)).to eq(" (yyvsp[-3].expr) + (yyvsp[-1].integer); ")
        end
      end

      context "can not resolve tag of references" do
        it "raises error" do
          # midrule action in rule7
          # rule7 has tag
          code = grammar.rules.find {|r| r.lhs.id.name == "@2" }
          expect { code.translated_code(grammar) }.to raise_error("Tag is not specified for '$$' in '@2 -> ε'")

          code = grammar.rules.find {|r| r.lhs.id.name == "rule7" }
          expect { code.translated_code(grammar) }.to raise_error("Tag is not specified for '$2' in 'rule7 -> expr @2 '+' expr'")

          # midrule action in rule8
          # rule8 has no tag
          code = grammar.rules.find {|r| r.lhs.id.name == "@3" }
          expect { code.translated_code(grammar) }.to raise_error("Tag is not specified for '$$' in '@3 -> ε'")

          code = grammar.rules.find {|r| r.lhs.id.name == "rule8" }
          expect { code.translated_code(grammar) }.to raise_error("Tag is not specified for '$2' in 'rule8 -> expr @3 '+' expr'")
        end
      end

      context "$0 is used" do
        [["STR", -1], ["%empty", 0]].each do |rhs, offset|
          context "with #{rhs} on the right-hand side" do
            let(:declarations) { "%union { int i; char *s; }\n%token <s> STR\n%type <i> expr" }
            let(:action) { "$$ = $0;" }
            let(:y) do
              <<~GRAMMAR
                #{declarations}
                %%
                expr: #{rhs} { #{action} };
              GRAMMAR
            end

            it "requires an explicit tag when a union is defined" do
              rule = grammar.rules.last
              expect { rule.translated_code(grammar) }.to raise_error("Tag is not specified for '$0' in '#{rule.display_name}'")
            end

            context "with an explicit tag" do
              let(:action) { "$$ = $<i>0;" }

              it "uses the explicit tag" do
                expect(grammar.rules.last.translated_code(grammar)).to eq(" (yyval.i) = (yyvsp[#{offset}].i); ")
              end
            end

            context "without a union" do
              let(:declarations) { "%token STR" }

              it "uses the default semantic value type" do
                expect(grammar.rules.last.translated_code(grammar)).to eq(" (yyval) = (yyvsp[#{offset}]); ")
              end
            end
          end
        end

        context "in a midrule action" do
          let(:y) do
            <<~GRAMMAR
              %union { int i; char *s; }
              %token <s> STR
              %%
              expr: { $0; } STR;
            GRAMMAR
          end

          it "does not infer the tag from a following symbol" do
            rule = grammar.rules.find { |rule| rule.action }
            expect { rule.translated_code(grammar) }.to raise_error("Tag is not specified for '$0' in '#{rule.display_name}'")
          end
        end
      end

      context "$: is used" do
        it "translates '$:$' to '-yylen' and '$:n' to index from the last of array" do
          code = grammar.rules.find {|r| r.lhs.id.name == "rule9" }
          expect(code.translated_code(grammar)).to eq(" (-2 - 1); (-1 - 1); (0 - 1); ")

          code = grammar.rules.find {|r| r.lhs.id.name == "rule10" }
          expect { code.translated_code(grammar) }.to raise_error("$:$ is not supported")

          # midrule action in rule11
          code = grammar.rules.find {|r| r.lhs.id.name == "@4" }
          expect(code.translated_code(grammar)).to eq(" (0 - 1); ")

          code = grammar.rules.find {|r| r.lhs.id.name == "rule11" }
          expect(code.translated_code(grammar)).to eq(" (-3 - 1); (-2 - 1); (-1 - 1); (0 - 1); ")

          code = grammar.rules.find {|r| r.lhs.id.name == "rule12" }
          expect(code.translated_code(grammar)).to eq(" (-2 - 1); (-1 - 1); (0 - 1); ")
        end
      end
    end
  end
end
