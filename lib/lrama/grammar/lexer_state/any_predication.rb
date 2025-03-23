# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class LexerState
      class AnyPredication
        # @rbs () -> String
        def name
          "*"
        end

        # @rbs (AnyPredication other) -> bool
        def ==(other)
          self.class == other.class
        end

        # @rbs (LexerState::state state) -> bool
        def match?(state)
          # AnyPredication matchs with any state
          true
        end
      end
    end
  end
end
