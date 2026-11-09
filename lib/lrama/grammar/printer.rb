# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class Printer < Struct.new(:ident_or_tags, :user_code, :lineno, keyword_init: true)
      # @rbs!
      #   attr_accessor ident_or_tags: Array[Lexer::Token::Ident|Lexer::Token::Tag]
      #   attr_accessor user_code: Grammar::UserCode
      #   attr_accessor lineno: Integer
      #
      #   def initialize: (?ident_or_tags: Array[Lexer::Token::Ident|Lexer::Token::Tag], ?user_code: Grammar::UserCode, ?lineno: Integer) -> void

      # @rbs (Lexer::Token::Tag tag) -> String
      def translated_code(tag)
        Code::PrinterCode.new(type: :printer, user_code: user_code, tag: tag).translated_code
      end
    end
  end
end
