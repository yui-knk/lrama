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
          term.lexer_state_transitions.each do |transition|
            io << "      #{transition_to_s(transition)}\n"
          end
          io << "\n"
        end

        states.nterms.each do |nterm|
          io << "    #{nterm.id.s_value}\n"
          nterm.lexer_state_transitions.each do |transition|
            io << "      #{transition_to_s(transition)}\n"
          end
          io << "\n"
        end

        states.rules.each do |rule|
          io << "    #{rule.id}: #{rule.display_name}\n\n"
          rule.merged_lexer_state_transitions.each do |transition|
            io << "      #{transition_to_s(transition)}\n"
          end
          io << "\n"
        end

        io << "\n"
      end

      private

      # @rbs (Lrama::Grammar::LexerState::_Transition transition) -> String
      def transition_to_s(transition)
        case transition
        when Lrama::Grammar::LexerState::Transition
          case transition.predication
          when Lrama::Grammar::LexerState::PatternPredication
            "#{transition.predication.pattern} => #{transition._to_state.map(&:to_s).join('|')}"
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
