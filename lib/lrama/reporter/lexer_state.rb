# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Reporter
    class LexerState
      # @rbs (?lexer_state: bool, **bool _) -> void
      def initialize(lexer_state: false, **_)
        @lexer_state = lexer_state
      end

      # @rbs (IO io, Lrama::States states) -> void
      def report(io, states)
        return if !@lexer_state || !states.lexer_state

        io << "LexerState\n\n"

        states.terms.each do |term|
          io << "    #{term.id.s_value}\n"
          sort_transitions(term.lexer_state_transitions).each do |transition|
            io << "      #{transition_to_s(transition)}\n"
          end
          io << "\n"
        end

        states.nterms.each do |nterm|
          io << "    #{nterm.id.s_value}\n"
          sort_transitions(nterm.lexer_state_transitions).each do |transition|
            io << "      #{transition_to_s(transition)}\n"
          end
          io << "\n"
        end

        states.rules.each do |rule|
          io << "    #{rule.id}: #{rule.display_name}\n\n"

          io << "      to_states:\n\n"
          rule.merged_lexer_state_transitions.map do |transition|
            transition_to_state(transition)
          end.uniq.sort.each do |to_state|
            io << "        #{to_state}\n"
          end

          io << "\n"
          io << "      transitions:\n\n"
          sort_transitions(rule.merged_lexer_state_transitions).each do |transition|
            io << "        #{transition_to_s(transition)}\n"
          end
          io << "\n"
        end

        io << "\n"
      end

      private

      ClassToOrder = {
        Lrama::Grammar::LexerState::IdentityTransition => 0,
        Lrama::Grammar::LexerState::Transition => 1,
      }

      # @rbs (Array[LexerState::_Transition] transitions) -> Array[LexerState::_Transition]
      def sort_transitions(transitions)
        transitions.sort do |t1, t2|
          sort_transition(t1, t2)
        end
      end

      # @rbs (LexerState::_Transition t1, LexerState::_Transition t2) -> Integer
      def sort_transition(t1, t2)
        if t1.class == t2.class
          t1 <=> t2
        else
          ClassToOrder[t1] <=> ClassToOrder[t2]
        end
      end

      # @rbs (Lrama::Grammar::LexerState::_Transition transition) -> String
      def transition_to_state(transition)
        case transition
        when Lrama::Grammar::LexerState::Transition
          case transition.predication
          when Lrama::Grammar::LexerState::PatternPredication
            transition._to_state.map(&:to_s).join('|')
          when Lrama::Grammar::LexerState::AnyPredication
            transition._to_state.map(&:to_s).join('|')
          else
            raise "Unknown #{transition}"
          end
        when Lrama::Grammar::LexerState::IdentityTransition
          "*"
        else
          raise "Unknown #{transition}"
        end
      end

      # @rbs (Lrama::Grammar::LexerState::_Transition transition) -> String
      def transition_to_s(transition)
        case transition
        when Lrama::Grammar::LexerState::Transition
          case transition.predication
          when Lrama::Grammar::LexerState::PatternPredication
            prefix = transition.predication.negative ? "! " : ""
            "#{prefix}#{transition.predication.pattern} => #{transition._to_state.map(&:to_s).join('|')}"
          when Lrama::Grammar::LexerState::AnyPredication
            "* => #{transition._to_state.map(&:to_s).join('|')}"
          else
            ""
          end
        when Lrama::Grammar::LexerState::IdentityTransition
          "* => *"
        else
          ""
        end
      end
    end
  end
end
