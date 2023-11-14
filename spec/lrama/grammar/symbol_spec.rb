RSpec.describe Lrama::Grammar::Symbol do
  let(:token_class) { Lrama::Lexer::Token }
  let(:location) { Lrama::Lexer::Location.new(first_line: 0, first_column: 0, last_line: 0, last_column: 0) }

  describe "#enum_name" do
    describe "symbol is accept_symbol" do
      it "returns 'YYSYMBOL_YYACCEPT'" do
        sym = described_class.new(id: token_class::Ident.new(s_value: "$accept", location: location))
        sym.accept_symbol = true

        expect(sym.enum_name).to eq("YYSYMBOL_YYACCEPT")
      end
    end

    describe "symbol is eof_symbol" do
      it "returns 'YYSYMBOL_YYEOF'" do
        sym = described_class.new(id: token_class::Ident.new(s_value: "YYEOF", location: location), alias_name: "\"end of file\"", token_id: 0)
        sym.number = 0
        sym.eof_symbol = true

        expect(sym.enum_name).to eq("YYSYMBOL_YYEOF")
      end
    end

    describe "symbol's token_id is less than 128" do
      it "returns 'YYSYMBOL_number_[alias_name_]'" do
        sym1 = described_class.new(id: token_class::Char.new(s_value: "'\\\\'", location: location), alias_name: "\"backslash\"", token_id: 92, number: 70, term: true)
        sym2 = described_class.new(id: token_class::Char.new(s_value: "'.'", location: location), alias_name: nil, token_id: 46, number: 69, term: true)
        sym3 = described_class.new(id: token_class::Char.new(s_value: "'\\n'", location: location), alias_name: nil, token_id: 10, number: 162, term: true)

        expect(sym1.enum_name).to eq("YYSYMBOL_70_backslash_")
        expect(sym2.enum_name).to eq("YYSYMBOL_69_")
        expect(sym3.enum_name).to eq("YYSYMBOL_162_n_")
      end
    end

    describe "symbol includes $ or @" do
      it "returns 'YYSYMBOL_number_ref" do
        sym1 = described_class.new(id: token_class::Ident.new(s_value: "$@1", location: location), token_id: -1, number: 165, term: false)
        sym2 = described_class.new(id: token_class::Ident.new(s_value: "@2", location: location), token_id: -1, number: 166, term: false)

        expect(sym1.enum_name).to eq("YYSYMBOL_165_1")
        expect(sym2.enum_name).to eq("YYSYMBOL_166_2")
      end
    end

    describe "symbol's token_id is greater than 127" do
      it "returns 'YYSYMBOL_number_ref" do
        sym1 = described_class.new(id: token_class::Ident.new(s_value: "keyword_class", location: location), alias_name: "\"`class'\"", token_id: 258, number: 3, term: true)
        sym2 = described_class.new(id: token_class::Ident.new(s_value: "top_compstmt", location: location), token_id: 166, number: -1, term: false)

        expect(sym1.enum_name).to eq("YYSYMBOL_keyword_class")
        expect(sym2.enum_name).to eq("YYSYMBOL_top_compstmt")
      end
    end
  end
end
