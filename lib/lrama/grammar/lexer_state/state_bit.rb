# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class LexerState
      class StateBit
        attr_reader :id #: Lexer::Token::Ident

        # @rbs (Lexer::Token::Ident id) -> void
        def initialize(id)
          @id = id
        end

        # @rbs (StateBit other) -> bool
        def ==(other)
          self.class == other.class &&
          self.id == other.id
        end

        # @rbs () -> String
        def to_s
          "#{id.s_value}"
        end
      end
    end
  end
end
