# frozen_string_literal: true

RSpec.describe Lrama::Grammar::UserCode do
  describe ".from_token" do
    let(:text) { " $value; " }
    let(:grammar_file) { Lrama::Lexer::GrammarFile.new("test.y", text) }
    let(:location) { Lrama::Lexer::Location.new(grammar_file: grammar_file, first_line: 1, first_column: 0, last_line: 1, last_column: text.length) }
    let(:token) { Lrama::Lexer::Token::UserCode.new(s_value: text, location: location) }

    it "preserves the source text and location for code generation and diagnostics" do
      code = described_class.from_token(token)

      expect(code.text).to eq(text)
      expect(code.location).to equal(location)
      expect(code.line).to eq(1)
      expect(code.column).to eq(0)
      expect(code.references.first.name).to eq("value")
    end

    it "keeps reference resolution state separate for each conversion" do
      first = described_class.from_token(token)
      first.references.first.name = "$"
      first.references.first.index = 1

      second = described_class.from_token(token)

      expect(second.references.first.name).to eq("value")
      expect(second.references.first.index).to be_nil
      expect(token.s_value).to eq(text)
    end
  end

  describe "#initialize" do
    it "preserves references resolved during grammar expansion" do
      original = described_class.new(text: " $value; ")
      references = original.references.map(&:dup)
      references.first.name = "argument"
      references.first.number = 2
      references.first.index = 2

      expanded = described_class.new(text: original.text, references: references)

      expect(expanded.references.first.name).to eq("argument")
      expect(expanded.references.first.index).to eq(2)
      expect(original.references.first.name).to eq("value")
      expect(original.references.first.index).to be_nil
    end
  end

  describe "#references" do
    let(:grammar_file) { Lrama::Lexer::GrammarFile.new("test.y", "") }
    let(:location) { Lrama::Lexer::Location.new(grammar_file: grammar_file, first_line: 1, first_column: 0, last_line: 1, last_column: 2) }

    it "returns references in user code" do
      # $$
      references = Lrama::Grammar::UserCode.new(text: " $$ ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, name: "$", ex_tag: nil, first_column: 1, last_column: 3)
      references = Lrama::Grammar::UserCode.new(text: " $<long>$ ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, name: "$", ex_tag: Lrama::Lexer::Token::Tag.new(s_value: "<long>"), first_column: 1, last_column: 9)

      # $1
      references = Lrama::Grammar::UserCode.new(text: " $1 ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, number: 1, index: 1, ex_tag: nil, first_column: 1, last_column: 3)
      references = Lrama::Grammar::UserCode.new(text: " $<long>1 ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, number: 1, index: 1, ex_tag: Lrama::Lexer::Token::Tag.new(s_value: "<long>"), first_column: 1, last_column: 9)
      references = Lrama::Grammar::UserCode.new(text: " $<value.integer>1 ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, number: 1, index: 1, ex_tag: Lrama::Lexer::Token::Tag.new(s_value: "<value.integer>"), first_column: 1, last_column: 18)

      # $foo
      references = Lrama::Grammar::UserCode.new(text: " $foo ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, name: "foo", ex_tag: nil, first_column: 1, last_column: 5)
      references = Lrama::Grammar::UserCode.new(text: " $<long>foo ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, name: "foo", ex_tag: Lrama::Lexer::Token::Tag.new(s_value: "<long>"), first_column: 1, last_column: 11)

      # $[expr.right]
      references = Lrama::Grammar::UserCode.new(text: " $[expr.right] ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, name: "expr.right", ex_tag: nil, first_column: 1, last_column: 14)
      references = Lrama::Grammar::UserCode.new(text: " $<long>[expr.right] ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :dollar, name: "expr.right", ex_tag: Lrama::Lexer::Token::Tag.new(s_value: "<long>"), first_column: 1, last_column: 20)

      # @$
      references = Lrama::Grammar::UserCode.new(text: " @$ ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :at, name: "$", ex_tag: nil, first_column: 1, last_column: 3)

      # @1
      references = Lrama::Grammar::UserCode.new(text: " @1 ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :at, number: 1, index: 1, ex_tag: nil, first_column: 1, last_column: 3)

      # @foo
      references = Lrama::Grammar::UserCode.new(text: " @foo ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :at, name: "foo", ex_tag: nil, first_column: 1, last_column: 5)

      # @[expr.right]
      references = Lrama::Grammar::UserCode.new(text: " @[expr.right] ", location: location).references
      expect(references.count).to eq 1
      expect(references[0]).to eq Lrama::Grammar::Reference.new(type: :at, name: "expr.right", ex_tag: nil, first_column: 1, last_column: 14)
    end

    ["\n", "\r\n"].each do |newline|
      it "ignores references in a continued line comment with #{newline.inspect}" do
        code = "$1; // comment\\#{newline}$9; @9; $:9;#{newline}$2;"
        references = described_class.new(text: code, location: location).references

        expect(references.map { |ref| [ref.type, ref.number] }).to eq([[:dollar, 1], [:dollar, 2]])
        expect(references.last.first_column).to eq(code.index('$2'))
      end
    end

    it "uses character offsets after multibyte comments and literals" do
      lexemes = %w[$$ $<long>$ $1 $<long>1 $foo $[expr.right] @$ @1 @foo @[expr.right] $:$ $:1 $:foo $:[expr.right]]
      code = "/* 日本 */\nputs(\"é🙂\"); #{lexemes.join('; ')};"

      references = described_class.new(text: code, location: location).references

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

      references = Lrama::Grammar::UserCode.new(text: code, location: location).references

      expect(references.map { |ref| [ref.type, ref.index] }).to eq([[:dollar, 1], [:dollar, 4], [:at, 4]])
    end
  end
end
