# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    module Node
      class DestructorDecl < Base
        attr_reader :ident_or_tags #: Array[Lexer::Token::Ident | Lexer::Token::Tag]
        attr_reader :code #: Grammar::Code

        # @rbs (ident_or_tags: Array[Lexer::Token::Ident | Lexer::Token::Tag], code: Grammar::Code, location: Lexer::Location) -> void
        def initialize(ident_or_tags:, code:, location:)
          @ident_or_tags = ident_or_tags
          @code = code
          super(location: location)
        end
      end
    end
  end
end
