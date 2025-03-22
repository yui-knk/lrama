# rbs_inline: enabled
# frozen_string_literal: true

require_relative "predication/pattern"

module Lrama
  class Grammar
    class LexerState
      class Predication
        attr_reader :name #: String
        attr_reader :pattern #: Pattern
        attr_reader :negative #: bool

        # @rbs (String name, Pattern pattern, bool negative) -> void
        def initialize(name, pattern, negative)
          @name = name
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
          Predication.new(@name, @pattern, !@negative)
        end

        # @rbs () -> String
        def to_s
          "<#{@name}: #{@pattern}>"
        end
      end
    end
  end
end
