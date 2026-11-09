# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class Destructor
      attr_reader :ident_or_tags #: Array[Lexer::Token::Ident|Lexer::Token::Tag]
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
        code.translated_code(Code::DestructorCode.new(type: :destructor, tag: tag))
      end
    end
  end
end
