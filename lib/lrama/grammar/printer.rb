# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class Printer < Struct.new(:ident_or_tags, :code, :lineno, keyword_init: true)
      # @rbs!
      #   attr_accessor ident_or_tags: Array[Lexer::Token::Ident|Lexer::Token::Tag]
      #   attr_accessor code: Grammar::Code
      #   attr_accessor lineno: Integer
      #
      #   def initialize: (?ident_or_tags: Array[Lexer::Token::Ident|Lexer::Token::Tag], ?code: Grammar::Code, ?lineno: Integer) -> void

      # @rbs (Lexer::Token::Tag tag) -> String
      def translated_code(tag)
        Code::PrinterCode.new(type: :printer, code: code, tag: tag).translated_code
      end
    end
  end
end
