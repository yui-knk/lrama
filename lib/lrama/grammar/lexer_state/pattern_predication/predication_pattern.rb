# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class LexerState
      class PatternPredication
        class PredicationPattern
          attr_reader :predication #: PatternPredication

          # @rbs (PatternPredication predication) -> void
          def initialize(predication)
            @predication = predication
          end

          # @rbs (PredicationPattern other) -> bool
          def ==(other)
            self.class == other.class &&
            self.predication == other.predication
          end

          # @rbs (StateBit state_bit) -> bot
          def add_state_bit(state_bit)
            raise "Can not add state_bit to PredicationPattern (#{predication.name})"
          end

          # @rbs (LexerState::state other_state) -> bool
          def match?(other_state)
            predication.match?(other_state)
          end

          # @rbs () -> String
          def to_s
            predication.name
          end
        end
      end
    end
  end
end
