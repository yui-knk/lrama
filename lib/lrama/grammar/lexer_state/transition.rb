# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class LexerState
      class Transition
        # @rbs!
        #    @_to_state: LexerState::State

        attr_reader :predication #: _Predication
        attr_reader :_to_state #: LexerState::State

        # @rbs (_Predication predication, LexerState::State to_state) -> void
        def initialize(predication, to_state)
          @predication = predication
          @_to_state = to_state
        end

        # @rbs (Transition other) -> bool
        def ==(other)
          self.class == other.class &&
          self.predication == other.predication &&
          self._to_state == other._to_state
        end

        # @rbs (LexerState::State from_state) -> LexerState::State
        def to_state(from_state)
          @_to_state
        end

        # Merge other transition to this transition then returns new transition.
        # Return `nil` if it can't merge other transition to this.
        #
        # @rbs (_Transition other) -> Transition?
        def merge(other)
          case other
          when IdentityTransition
            return self
          when Transition
            if other.match?(@_to_state)
              Transition.new(predication, other._to_state)
            else
              nil
            end
          else
            raise "[BUG] Unexpected transition #{other}"
          end
        end

        # @rbs (LexerState::State state) -> bool
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
