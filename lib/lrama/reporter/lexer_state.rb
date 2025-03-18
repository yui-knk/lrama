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
            io << "      #{transition.predication.pattern} => #{transition.to_state.map(&:to_s).join('|')}\n"
          end
          io << "\n"
        end

        states.nterms.each do |nterm|
          io << "    #{nterm.id.s_value}\n"
          nterm.lexer_state_transitions.each do |transition|
            io << "      #{transition.predication.pattern} => #{transition.to_state.map(&:to_s).join('|')}\n"
          end
          io << "\n"
        end

        states.rules.each do |rule|
          io << "    #{rule.display_name}\n"
          rule.merged_lexer_state_transitions.each do |transition|
            io << "      #{transition.predication.pattern} => #{transition.to_state.map(&:to_s).join('|')}\n"
          end
          io << "\n"
        end

        io << "\n"
      end
    end
  end
end
