# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class LexerState
      class PatternPredication
        class NotPattern
          attr_reader :pattern #: _Pattern

          # @rbs (_Pattern pattern) -> void
          def initialize(pattern)
            @pattern = pattern
          end

          # @rbs (NotPattern other) -> bool
          def ==(other)
            self.class == other.class &&
            self.pattern == other.pattern
          end

          # @rbs (StateBit state_bit) -> bot
          def add_state_bit(state_bit)
            raise "Can not add state_bit to OrPattern (#{self})"
          end

          # @rbs (LexerState::State other_state) -> bool
          def match?(other_state)
            !pattern.match?(other_state)
          end

          # @rbs () -> String
          def to_s
            "!#{pattern}"
          end
        end
      end
    end
  end
end
