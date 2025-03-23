# rbs_inline: enabled
# frozen_string_literal: true

require "set"

module Lrama
  class Grammar
    class LexerState
      class PatternPredication
        class Pattern
          attr_reader :state #: LexerState::state

          # @rbs (StateBit state_bit) -> void
          def initialize(state_bit)
            @state = Set[state_bit]
          end

          # @rbs (Pattern other) -> bool
          def ==(other)
            self.class == other.class &&
            self.state == other.state
          end

          # @rbs (StateBit state_bit) -> void
          def add_state_bit(state_bit)
            @state << state_bit
          end

          # @rbs (LexerState::state other_state) -> bool
          def match?(other_state)
            !(state & other_state).empty?
          end

          # @rbs () -> String
          def to_s
            @state.map(&:to_s).join('|')
          end
        end
      end
    end
  end
end
