# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class LexerState
      class IdentityTransition

        # @rbs (Transition other) -> bool
        def ==(other)
          self.class == other.class
        end

        alias :eql? :==

        # @rbs () -> Integer
        def hash
          self.class.object_id
        end

        # @rbs (LexerState::State from_state) -> LexerState::State
        def to_state(from_state)
          from_state
        end

        # Merge other transition to this transition then returns new transition.
        # Return `nil` if it can't merge other transition to this.
        #
        # @rbs (_Transition other) -> _Transition
        def merge(other)
          other
        end

        # @rbs (LexerState::State state) -> bool
        def match?(state)
          true
        end

        # @rbs () -> String
        def to_s
          "<IdentityTransition: * => *>"
        end
      end
    end
  end
end
