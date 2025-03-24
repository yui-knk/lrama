# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class LexerState
      class PatternPredication
        class AllPattern
          # @rbs!
          #    @state: LexerState::State

          attr_reader :state #: LexerState::State

          # @rbs (StateBit state_bit) -> void
          def initialize(state_bit)
            @state = State.new([state_bit])
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

          # @rbs (LexerState::State other_state) -> bool
          def match?(other_state)
            state.is_all?(other_state)
          end

          # @rbs () -> String
          def to_s
            "all of (#{@state.map(&:to_s).join('|')})"
          end
        end
      end
    end
  end
end
