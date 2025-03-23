# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class LexerState
      class Transition
        attr_reader :predication #: _Predication
        attr_reader :to_state #: LexerState::state

        # @rbs (_Predication predication, LexerState::state to_state) -> void
        def initialize(predication, to_state)
          @predication = predication
          @to_state = to_state
        end

        # @rbs (Transition other) -> bool
        def ==(other)
          self.class == other.class &&
          self.predication == other.predication &&
          self.to_state == other.to_state
        end

        # Merge other transition to this transition then returns new transition.
        # Return `nil` if it can't merge other transition to this.
        #
        # @rbs (Transition other) -> Transition?
        def merge(other)
          if other.match?(to_state)
            Transition.new(predication, other.to_state)
          else
            nil
          end
        end

        # @rbs (LexerState::state state) -> bool
        def match?(state)
          @predication.match?(state)
        end

        # @rbs () -> String
        def to_s
          "<Transition: #{@predication} => #{@to_state.map(&:to_s).join('|')}>"
        end
      end
    end
  end
end
