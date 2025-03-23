# rbs_inline: enabled
# frozen_string_literal: true

require "set"
require_relative "lexer_state/any_predication"
require_relative "lexer_state/identity_transition"
require_relative "lexer_state/pattern_predication"
require_relative "lexer_state/state_bit"
require_relative "lexer_state/transition"

module Lrama
  class Grammar
    class LexerState
      # @rbs!
      #
      #   interface _Predication
      #     def name: () -> String
      #     def ==: (self other) -> bool
      #     def match?: (LexerState::state state) -> bool
      #   end
      #
      #   interface _Transition
      #     def ==: (self other) -> bool
      #     def to_state: (LexerState::state from_state) -> LexerState::state
      #     def merge: (_Transition other) -> _Transition?
      #     def match?: (LexerState::state state) -> bool
      #   end
      #
      #   type state = Set[LexerState::StateBit]

      attr_reader :initial_state #: state
      attr_accessor :state_bits #: Array[StateBit]
      attr_accessor :predications #: Array[PatternPredication]
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
        state = @state_bits.find {|s| s.name == id.s_value } or raise "State #{id.s_value} is not found"
        @initial_state = Set[state]
      end

      # @rbs (Lexer::Token::Ident id) -> void
      def add_state_bit(id)
        @state_bits << StateBit.new(id.s_value)
      end

      # @rbs (Lexer::Token::Ident id, PatternPredication::Pattern pattern) -> void
      def add_predication(id, pattern)
        @predications << PatternPredication.new(id.s_value, pattern, false)
      end

      # @rbs (_Predication predication, Lexer::Token::Ident token, state to_state) -> void
      def add_transition(predication, token, to_state)
        @transitions[token.s_value] ||= []
        @transitions[token.s_value] << Transition.new(predication, to_state)
      end

      # @rbs (Lexer::Token::Ident id) -> StateBit
      def find_state_bit!(id)
        @state_bits.find {|s| s.name == id.s_value } || (raise "StateBit #{id.s_value} is not found")
      end

      # @rbs (Lexer::Token::Ident id) -> PatternPredication::_Pattern
      def find_pattern!(id)
        if (state = @state_bits.find {|s| s.name == id.s_value })
          return PatternPredication::Pattern.new(state)
        end

        if (predication = @predications.find {|predication| predication.name == id.s_value })
          return PatternPredication::PredicationPattern.new(predication)
        end

        raise "Pattern #{id.s_value} is not found"
      end

      # @rbs (Lexer::Token::Ident id) -> PatternPredication
      def find_predication!(id)
        if (state = @state_bits.find {|s| s.name == id.s_value })
          return PatternPredication.new(id.s_value, PatternPredication::Pattern.new(state), false)
        end

        if (predication = @predications.find {|predication| predication.name == id.s_value })
          return predication
        end

        raise "Predication #{id.s_value} is not found"
      end
    end
  end
end
