RSpec.describe Lrama::Lexer do
  let(:token_class) { Lrama::Lexer::Token }

  describe '#next_token' do
    context 'basic.y' do
      let(:location) { Lrama::Lexer::Location.new(first_line: 0, first_column: 0, last_line: 0, last_column: 0) }

      it do
        text = File.read(fixture_path("common/basic.y"))
        lexer = Lrama::Lexer.new(text)

        expect(lexer.next_token).to eq(['%require', '%require'])
        expect(lexer.next_token).to eq([:STRING, '"3.0"'])
        expect(lexer.next_token).to eq(['%{', '%{'])

        lexer.status = :c_declaration; lexer.end_symbol = '%}'
        expect(lexer.next_token).to eq([:C_DECLARATION, token_class::UserCode.new(s_value: "\n// Prologue\n", location: location)])
        lexer.status = :initial

        expect(lexer.next_token).to eq(['%}', '%}'])
        expect(lexer.next_token).to eq(['%expect', '%expect'])
        expect(lexer.next_token).to eq([:INTEGER, 0])
        expect(lexer.next_token).to eq(['%define', '%define'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'api.pure', location: location)])
        expect(lexer.next_token).to eq(['%define', '%define'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'parse.error', location: location)])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'verbose', location: location)])
        expect(lexer.next_token).to eq(['%printer', '%printer'])
        expect(lexer.next_token).to eq(['{', '{'])

        lexer.status = :c_declaration; lexer.end_symbol = '}'
        expect(lexer.next_token).to eq([:C_DECLARATION, token_class::UserCode.new(s_value: "\n    print_int();\n", location: location)])
        lexer.status = :initial

        expect(lexer.next_token).to eq(['}', '}'])
        expect(lexer.next_token).to eq([:TAG, token_class::Tag.new(s_value: '<int>', location: location)])
        expect(lexer.next_token).to eq(['%printer', '%printer'])
        expect(lexer.next_token).to eq(['{', '{'])

        lexer.status = :c_declaration; lexer.end_symbol = '}'
        expect(lexer.next_token).to eq([:C_DECLARATION, token_class::UserCode.new(s_value: "\n    print_token();\n", location: location)])
        lexer.status = :initial

        expect(lexer.next_token).to eq(['}', '}'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tNUMBER', location: location)])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tSTRING', location: location)])
        expect(lexer.next_token).to eq(['%lex-param', '%lex-param'])
        expect(lexer.next_token).to eq(['{', '{'])

        lexer.status = :c_declaration; lexer.end_symbol = '}'
        expect(lexer.next_token).to eq([:C_DECLARATION, token_class::UserCode.new(s_value: 'struct lex_params *p', location: location)])
        lexer.status = :initial

        expect(lexer.next_token).to eq(['}', '}'])
        expect(lexer.next_token).to eq(['%parse-param', '%parse-param'])
        expect(lexer.next_token).to eq(['{', '{'])

        lexer.status = :c_declaration; lexer.end_symbol = '}'
        expect(lexer.next_token).to eq([:C_DECLARATION, token_class::UserCode.new(s_value: 'struct parse_params *p', location: location)])
        lexer.status = :initial

        expect(lexer.next_token).to eq(['}', '}'])
        expect(lexer.next_token).to eq(['%initial-action', '%initial-action'])
        expect(lexer.next_token).to eq(['{', '{'])

        lexer.status = :c_declaration; lexer.end_symbol = '}'
        expect(lexer.next_token).to eq([:C_DECLARATION, token_class::UserCode.new(s_value: "\n    initial_action_func(@$);\n", location: location)])
        lexer.status = :initial

        expect(lexer.next_token).to eq(['}', '}'])
        expect(lexer.next_token).to eq([';', ';'])
        expect(lexer.next_token).to eq(['%union', '%union'])
        expect(lexer.next_token).to eq(['{', '{'])

        lexer.status = :c_declaration; lexer.end_symbol = '}'
        expect(lexer.next_token).to eq([:C_DECLARATION, token_class::UserCode.new(s_value: "\n    int i;\n    long l;\n    char *str;\n", location: location)])
        lexer.status = :initial

        expect(lexer.next_token).to eq(['}', '}'])
        expect(lexer.next_token).to eq(['%token', '%token'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'EOI', location: location)])
        expect(lexer.next_token).to eq([:INTEGER, 0])
        expect(lexer.next_token).to eq([:STRING, '"EOI"'])
        expect(lexer.next_token).to eq(['%token', '%token'])
        expect(lexer.next_token).to eq([:TAG, token_class::Tag.new(s_value: '<i>', location: location)])
        expect(lexer.next_token).to eq([:CHARACTER, token_class::Char.new(s_value: "'\\\\'", location: location)])
        expect(lexer.next_token).to eq([:STRING, '"backslash"'])
        expect(lexer.next_token).to eq(['%token', '%token'])
        expect(lexer.next_token).to eq([:TAG, token_class::Tag.new(s_value: '<i>', location: location)])
        expect(lexer.next_token).to eq([:CHARACTER, token_class::Char.new(s_value: "'\\13'", location: location)])
        expect(lexer.next_token).to eq([:STRING, '"escaped vertical tab"'])
        expect(lexer.next_token).to eq(['%token', '%token'])
        expect(lexer.next_token).to eq([:TAG, token_class::Tag.new(s_value: '<i>', location: location)])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'keyword_class', location: location)])
        expect(lexer.next_token).to eq(['%token', '%token'])
        expect(lexer.next_token).to eq([:TAG, token_class::Tag.new(s_value: '<i>', location: location)])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'keyword_class2', location: location)])
        expect(lexer.next_token).to eq(['%token', '%token'])
        expect(lexer.next_token).to eq([:TAG, token_class::Tag.new(s_value: '<l>', location: location)])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tNUMBER', location: location)])
        expect(lexer.next_token).to eq(['%token', '%token'])
        expect(lexer.next_token).to eq([:TAG, token_class::Tag.new(s_value: '<str>', location: location)])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tSTRING', location: location)])
        expect(lexer.next_token).to eq(['%token', '%token'])
        expect(lexer.next_token).to eq([:TAG, token_class::Tag.new(s_value: '<i>', location: location)])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'keyword_end', location: location)])
        expect(lexer.next_token).to eq([:STRING, '"end"'])
        expect(lexer.next_token).to eq(['%token', '%token'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tPLUS', location: location)])
        expect(lexer.next_token).to eq([:STRING, '"+"'])
        expect(lexer.next_token).to eq(['%token', '%token'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tMINUS', location: location)])
        expect(lexer.next_token).to eq([:STRING, '"-"'])
        expect(lexer.next_token).to eq(['%token', '%token'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tEQ', location: location)])
        expect(lexer.next_token).to eq([:STRING, '"="'])
        expect(lexer.next_token).to eq(['%token', '%token'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tEQEQ', location: location)])
        expect(lexer.next_token).to eq([:STRING, '"=="'])
        expect(lexer.next_token).to eq(['%type', '%type'])
        expect(lexer.next_token).to eq([:TAG, token_class::Tag.new(s_value: '<i>', location: location)])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'class', location: location)])
        expect(lexer.next_token).to eq(['%nonassoc', '%nonassoc'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tEQEQ', location: location)])
        expect(lexer.next_token).to eq(['%left', '%left'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tPLUS', location: location)])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tMINUS', location: location)])
        expect(lexer.next_token).to eq([:CHARACTER, token_class::Char.new(s_value: "'>'", location: location)])
        expect(lexer.next_token).to eq(['%right', '%right'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tEQ', location: location)])
        expect(lexer.next_token).to eq(['%%', '%%'])
        expect(lexer.next_token).to eq([:IDENT_COLON, token_class::Ident.new(s_value: 'program', location: location)])
        expect(lexer.next_token).to eq([':', ':'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'class', location: location)])
        expect(lexer.next_token).to eq(['|', '|'])
        expect(lexer.next_token).to eq([:CHARACTER, token_class::Char.new(s_value: "'+'", location: location)])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'strings_1', location: location)])
        expect(lexer.next_token).to eq(['|', '|'])
        expect(lexer.next_token).to eq([:CHARACTER, token_class::Char.new(s_value: "'-'", location: location)])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'strings_2', location: location)])
        expect(lexer.next_token).to eq([';', ';'])
        expect(lexer.next_token).to eq([:IDENT_COLON, token_class::Ident.new(s_value: 'class', location: location)])
        expect(lexer.next_token).to eq([':', ':'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'keyword_class', location: location)])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tSTRING', location: location)])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'keyword_end', location: location)])
        expect(lexer.next_token).to eq(['%prec', '%prec'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tPLUS', location: location)])
        expect(lexer.next_token).to eq(['{', '{'])

        lexer.status = :c_declaration; lexer.end_symbol = '}'
        expect(lexer.next_token).to eq([:C_DECLARATION, token_class::UserCode.new(s_value: " code 1 ", location: location)])
        lexer.status = :initial

        expect(lexer.next_token).to eq(['}', '}'])
        expect(lexer.next_token).to eq(['|', '|'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'keyword_class', location: location)])
        expect(lexer.next_token).to eq(['{', '{'])

        lexer.status = :c_declaration; lexer.end_symbol = '}'
        expect(lexer.next_token).to eq([:C_DECLARATION, token_class::UserCode.new(s_value: " code 2 ", location: location)])
        lexer.status = :initial

        expect(lexer.next_token).to eq(['}', '}'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tSTRING', location: location)])
        expect(lexer.next_token).to eq([:CHARACTER, token_class::Char.new(s_value: "'!'", location: location)])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'keyword_end', location: location)])
        expect(lexer.next_token).to eq(['{', '{'])

        lexer.status = :c_declaration; lexer.end_symbol = '}'
        expect(lexer.next_token).to eq([:C_DECLARATION, token_class::UserCode.new(s_value: " code 3 ", location: location)])
        lexer.status = :initial

        expect(lexer.next_token).to eq(['}', '}'])
        expect(lexer.next_token).to eq(['%prec', '%prec'])
        expect(lexer.next_token).to eq([:STRING, '"="'])
        expect(lexer.next_token).to eq(['|', '|'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'keyword_class', location: location)])
        expect(lexer.next_token).to eq(['{', '{'])

        lexer.status = :c_declaration; lexer.end_symbol = '}'
        expect(lexer.next_token).to eq([:C_DECLARATION, token_class::UserCode.new(s_value: " code 4 ", location: location)])
        lexer.status = :initial

        expect(lexer.next_token).to eq(['}', '}'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tSTRING', location: location)])
        expect(lexer.next_token).to eq([:CHARACTER, token_class::Char.new(s_value: "'?'", location: location)])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'keyword_end', location: location)])
        expect(lexer.next_token).to eq(['{', '{'])

        lexer.status = :c_declaration; lexer.end_symbol = '}'
        expect(lexer.next_token).to eq([:C_DECLARATION, token_class::UserCode.new(s_value: " code 5 ", location: location)])
        lexer.status = :initial

        expect(lexer.next_token).to eq(['}', '}'])
        expect(lexer.next_token).to eq(['%prec', '%prec'])
        expect(lexer.next_token).to eq([:CHARACTER, token_class::Char.new(s_value: "'>'", location: location)])
        expect(lexer.next_token).to eq([';', ';'])
        expect(lexer.next_token).to eq([:IDENT_COLON, token_class::Ident.new(s_value: 'strings_1', location: location)])
        expect(lexer.next_token).to eq([':', ':'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'string_1', location: location)])
        expect(lexer.next_token).to eq([';', ';'])
        expect(lexer.next_token).to eq([:IDENT_COLON, token_class::Ident.new(s_value: 'strings_2', location: location)])
        expect(lexer.next_token).to eq([':', ':'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'string_1', location: location)])
        expect(lexer.next_token).to eq(['|', '|'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'string_2', location: location)])
        expect(lexer.next_token).to eq([';', ';'])
        expect(lexer.next_token).to eq([:IDENT_COLON, token_class::Ident.new(s_value: 'string_1', location: location)])
        expect(lexer.next_token).to eq([':', ':'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'string', location: location)])
        expect(lexer.next_token).to eq([';', ';'])
        expect(lexer.next_token).to eq([:IDENT_COLON, token_class::Ident.new(s_value: 'string_2', location: location)])
        expect(lexer.next_token).to eq([':', ':'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'string', location: location)])
        expect(lexer.next_token).to eq([:CHARACTER, token_class::Char.new(s_value: "'+'", location: location)])
        expect(lexer.next_token).to eq([';', ';'])
        expect(lexer.next_token).to eq([:IDENT_COLON, token_class::Ident.new(s_value: 'string', location: location)])
        expect(lexer.next_token).to eq([':', ':'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tSTRING', location: location)])
        expect(lexer.next_token).to eq([';', ';'])
        expect(lexer.next_token).to eq(['%%', '%%'])
        expect(lexer.next_token).to eq(nil)
      end
    end

    context 'nullable.y' do
      let(:location) { Lrama::Lexer::Location.new(first_line: 0, first_column: 0, last_line: 0, last_column: 0) }

      it do
        text = File.read(fixture_path("common/nullable.y"))
        lexer = Lrama::Lexer.new(text)

        expect(lexer.next_token).to eq(['%require', '%require'])
        expect(lexer.next_token).to eq([:STRING, '"3.0"'])
        expect(lexer.next_token).to eq(['%{', '%{'])

        lexer.status = :c_declaration; lexer.end_symbol = '%}'
        expect(lexer.next_token).to eq([:C_DECLARATION, token_class::UserCode.new(s_value: "\n// Prologue\n", location: location)])
        lexer.status = :initial

        expect(lexer.next_token).to eq(['%}', '%}'])
        expect(lexer.next_token).to eq(['%token', '%token'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tNUMBER', location: location)])
        expect(lexer.next_token).to eq(['%%', '%%'])
        expect(lexer.next_token).to eq([:IDENT_COLON, token_class::Ident.new(s_value: 'program', location: location)])
        expect(lexer.next_token).to eq([':', ':'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'stmt', location: location)])
        expect(lexer.next_token).to eq([';', ';'])
        expect(lexer.next_token).to eq([:IDENT_COLON, token_class::Ident.new(s_value: 'stmt', location: location)])
        expect(lexer.next_token).to eq([':', ':'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'expr', location: location)])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'opt_semicolon', location: location)])
        expect(lexer.next_token).to eq(['|', '|'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'opt_expr', location: location)])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'opt_colon', location: location)])
        expect(lexer.next_token).to eq(['|', '|'])
        expect(lexer.next_token).to eq([';', ';'])
        expect(lexer.next_token).to eq([:IDENT_COLON, token_class::Ident.new(s_value: 'expr', location: location)])
        expect(lexer.next_token).to eq([':', ':'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'tNUMBER', location: location)])
        expect(lexer.next_token).to eq([';', ';'])
        expect(lexer.next_token).to eq([:IDENT_COLON, token_class::Ident.new(s_value: 'opt_expr', location: location)])
        expect(lexer.next_token).to eq([':', ':'])
        expect(lexer.next_token).to eq(['|', '|'])
        expect(lexer.next_token).to eq([:IDENTIFIER, token_class::Ident.new(s_value: 'expr', location: location)])
        expect(lexer.next_token).to eq([';', ';'])
        expect(lexer.next_token).to eq([:IDENT_COLON, token_class::Ident.new(s_value: 'opt_semicolon', location: location)])
        expect(lexer.next_token).to eq([':', ':'])
        expect(lexer.next_token).to eq(['|', '|'])
        expect(lexer.next_token).to eq([:CHARACTER, token_class::Char.new(s_value: "';'", location: location)])
        expect(lexer.next_token).to eq([';', ';'])
        expect(lexer.next_token).to eq([:IDENT_COLON, token_class::Ident.new(s_value: 'opt_colon', location: location)])
        expect(lexer.next_token).to eq([':', ':'])
        expect(lexer.next_token).to eq(['%empty', '%empty'])
        expect(lexer.next_token).to eq(['|', '|'])
        expect(lexer.next_token).to eq([:CHARACTER, token_class::Char.new(s_value: "'.'", location: location)])
        expect(lexer.next_token).to eq([';', ';'])
        expect(lexer.next_token).to eq(['%%', '%%'])
        expect(lexer.next_token).to eq(nil)
      end
    end
  end

  context 'unexpected_token.y' do
    it do
      text = File.read(fixture_path("common/unexpected_token.y"))
      lexer = Lrama::Lexer.new(text)
      expect { lexer.next_token }.to raise_error(ParseError, "Unexpected token: @invalid.")
    end
  end

  context 'unexpected_c_code.y' do
    it do
      lexer = Lrama::Lexer.new("@invalid")
      lexer.status = :c_declaration; lexer.end_symbol = "%}"
      expect { lexer.next_token }.to raise_error(ParseError, "Unexpected code: @invalid.")
    end
  end
end
