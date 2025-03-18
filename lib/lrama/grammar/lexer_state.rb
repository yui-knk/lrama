# rbs_inline: enabled
# frozen_string_literal: true

require "set"
require_relative "lexer_state/predication"
require_relative "lexer_state/state_bit"
require_relative "lexer_state/transition"

module Lrama
  class Grammar
    class LexerState
      # @rbs!
      #   type state = Set[LexerState::StateBit]

      attr_reader :initial_state #: state
      attr_accessor :state_bits #: Array[StateBit]
      attr_accessor :predications #: Array[Predication]
      attr_accessor :transitions #: Hash[String, Array[Transition]]

      # @rbs () -> void
      def initialize
        @state_bits = []
        @initial_state = nil
        @predications = []
        @transitions = {}
      end

      # @rbs (Lexer::Token::Ident id) -> void
      def set_initial_state(id)
        state = @state_bits.find {|s| s.id == id } or raise "State #{id.s_value} is not found"
        @initial_state = Set[state]
      end

      # @rbs (Lexer::Token::Ident id) -> void
      def add_state_bit(id)
        @state_bits << StateBit.new(id)
      end

      # @rbs (Lexer::Token::Ident id, Predication::Pattern pattern) -> void
      def add_predication(id, pattern)
        @predications << Predication.new(id, pattern, false)
      end

      # @rbs (Predication predication, Lexer::Token::Ident token, state to_state) -> void
      def add_transition(predication, token, to_state)
        @transitions[token.s_value] ||= []
        @transitions[token.s_value] << Transition.new(predication, to_state)
      end

      # @rbs (Lexer::Token::Ident id) -> StateBit
      def find_state_bit!(id)
        @state_bits.find {|s| s.id == id } || (raise "StateBit #{id.s_value} is not found")
      end

      # @rbs (Lexer::Token::Ident id) -> Predication
      def find_predication!(id)
        if (state = @state_bits.find {|s| s.id == id })
          return Predication.new(id, Predication::Pattern.new(state), false)
        end

        if (predication = @predications.find {|s| s.id == id })
          return predication
        end

        raise "Predication #{id.s_value} is not found"
      end
    end
  end
end
