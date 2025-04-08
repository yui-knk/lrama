# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class LexerState
      class PatternPredication
        class AndPattern
          attr_reader :left #: _Pattern
          attr_reader :right #: _Pattern

          # @rbs (_Pattern left, _Pattern right) -> void
          def initialize(left, right)
            @left = left
            @right = right
          end

          # @rbs (AndPattern other) -> bool
          def ==(other)
            self.class == other.class &&
            self.left == other.left &&
            self.right == other.right
          end

          # @rbs (StateBit state_bit) -> bot
          def add_state_bit(state_bit)
            raise "Can not add state_bit to OrPattern (#{self})"
          end

          # @rbs (LexerState::State other_state) -> bool
          def match?(other_state)
            left.match?(other_state) && right.match?(other_state)
          end

          # @rbs () -> String
          def to_s
            "(#{left} && #{right})"
          end
        end
      end
    end
  end
end
