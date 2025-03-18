# rbs_inline: enabled
# frozen_string_literal: true

require_relative "predication/pattern"

module Lrama
  class Grammar
    class LexerState
      class Predication
        attr_reader :id #: Lexer::Token::Ident
        attr_reader :pattern #: Pattern
        attr_reader :negative #: bool

        # @rbs (Lexer::Token::Ident id, Pattern pattern, bool negative) -> void
        def initialize(id, pattern, negative)
          @id = id
          @pattern = pattern
          @negative = negative
        end

        # @rbs (Predication other) -> bool
        def ==(other)
          self.class == other.class &&
          self.pattern == other.pattern &&
          self.negative == other.negative
        end

        # @rbs (LexerState::state state) -> bool
        def match?(state)
          @pattern.match?(state)
        end

        # @rbs () -> Predication
        def negativeredication
          Predication.new(@id, @pattern, !@negative)
        end

        # @rbs () -> String
        def to_s
          "<#{id.s_value}: #{@pattern}>"
        end
      end
    end
  end
end
