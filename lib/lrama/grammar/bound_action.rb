# rbs_inline: enabled
# frozen_string_literal: true

require "forwardable"

module Lrama
  class Grammar
    # The completed result of resolving a syntax action in one rule scope.
    class BoundAction
      # @rbs!
      #   def code: () -> Code
      #   def text: () -> String
      #   def references: () -> Array[Reference]
      #   def alias_name: () -> String?
      #   def tag: () -> Lexer::Token::Tag?
      #   def location: () -> Lexer::Location

      extend Forwardable
      def_delegators :source, :code, :text, :references, :alias_name, :tag, :location

      attr_reader :source #: Node::RuleRhs::Action
      attr_reader :resolved_references #: Array[ResolvedReference]
      attr_reader :rhs_occurrences #: Array[RhsOccurrence]

      # @rbs (source: Node::RuleRhs::Action, resolved_references: Array[ResolvedReference], rhs_occurrences: Array[RhsOccurrence]) -> void
      def initialize(source:, resolved_references:, rhs_occurrences:)
        @source = source
        @resolved_references = resolved_references.freeze
        @rhs_occurrences = rhs_occurrences.freeze
        freeze
      end
    end
  end
end
