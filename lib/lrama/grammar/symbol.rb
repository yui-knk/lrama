# Symbol is both of nterm and term
# `number` is both for nterm and term
# `token_id` is tokentype for term, internal sequence number for nterm
#
# TODO: Add validation for ASCII code range for Token::Char

module Lrama
  class Grammar
    class Symbol
      attr_accessor :name, :type, :alias_name, :tag, :number, :token_id, :nullable, :precedence, :printer, :error_token, :first_set, :first_set_bitmap
      attr_reader :term
      attr_writer :eof_symbol, :error_symbol, :undef_symbol, :accept_symbol

      def initialize(name:, type:, alias_name: nil, number: nil, tag: nil, term:, token_id: nil, nullable: nil, precedence: nil, printer: nil)
        @name = name
        @type = type
        @alias_name = alias_name
        @number = number
        @tag = tag
        @term = term
        @token_id = token_id
        @nullable = nullable
        @precedence = precedence
        @printer = printer
      end

      def term?
        term
      end

      def nterm?
        !term
      end

      def eof_symbol?
        !!@eof_symbol
      end

      def error_symbol?
        !!@error_symbol
      end

      def undef_symbol?
        !!@undef_symbol
      end

      def accept_symbol?
        !!@accept_symbol
      end

      def display_name
        alias_name || name
      end

      # name for yysymbol_kind_t
      #
      # See: b4_symbol_kind_base
      # @type var str: String
      def enum_name
        case
        when accept_symbol?
          str = "YYACCEPT"
        when eof_symbol?
          str = "YYEOF"
        when term? && id.is_a?(Lrama::Lexer::Token::Char)
          str = number.to_s + display_name
        when term? && id.is_a?(Lrama::Lexer::Token::Ident)
          str = name
        when nterm? && (name.include?("$") || name.include?("@"))
          str = number.to_s + name
        when nterm?
          str = name
        else
          raise "Unexpected #{self}"
        end

        "YYSYMBOL_" + str.gsub(/\W+/, "_")
      end

      # comment for yysymbol_kind_t
      def comment
        case
        when accept_symbol?
          # YYSYMBOL_YYACCEPT
          name
        when eof_symbol?
          # YYEOF
          alias_name
        when (term? && 0 < token_id && token_id < 128)
          # YYSYMBOL_3_backslash_, YYSYMBOL_14_
          alias_name || name
        when name.include?("$") || name.include?("@")
          # YYSYMBOL_21_1
          name
        else
          # YYSYMBOL_keyword_class, YYSYMBOL_strings_1
          alias_name || name
        end
      end
    end
  end
end
