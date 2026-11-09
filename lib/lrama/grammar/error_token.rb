# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class ErrorToken
      attr_reader :ident_or_tags #: Array[Lexer::Token::Ident | Lexer::Token::Tag]
      attr_reader :code #: Grammar::Code
      attr_reader :lineno #: Integer

      # @rbs (ident_or_tags: Array[Lexer::Token::Ident|Lexer::Token::Tag], code: Grammar::Code, lineno: Integer) -> void
      def initialize(ident_or_tags:, code:, lineno:)
        @ident_or_tags = ident_or_tags
        @code = code
        @lineno = lineno
      end

      # @rbs (Lexer::Token::Tag tag) -> String
      def translated_code(tag)
        Code::PrinterCode.new(type: :error_token, code: code, tag: tag).translated_code
      end
    end
  end
end
