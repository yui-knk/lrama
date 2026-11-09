# rbs_inline: enabled
# frozen_string_literal: true

require "forwardable"

module Lrama
  class Grammar
    # The completed result of resolving a syntax action in one rule scope.
    class BoundAction
      # @rbs!
      #   def code: () -> Code
      #   def alias_name: () -> String?
      #   def tag: () -> Lexer::Token::Tag?
      #   def location: () -> Lexer::Location

      extend Forwardable
      def_delegators :source, :code, :alias_name, :tag, :location

      attr_reader :source #: Node::RuleRhs::Action
      attr_reader :text #: String
      attr_reader :references #: Array[Reference]
      attr_reader :fragments #: Array[Code::TextFragment | ResolvedReference]
      attr_reader :resolved_references #: Array[ResolvedReference]
      attr_reader :rhs_occurrences #: Array[RhsOccurrence]

      # @rbs (source: Node::RuleRhs::Action, fragments: Array[Code::TextFragment | ResolvedReference], rhs_occurrences: Array[RhsOccurrence]) -> void
      def initialize(source:, fragments:, rhs_occurrences:)
        @source = source
        @fragments = fragments.freeze
        @resolved_references = fragments.grep(ResolvedReference).freeze
        @references = @resolved_references.map(&:reference).freeze
        @text = fragments.map { |fragment| fragment.is_a?(ResolvedReference) ? fragment.rendered_text(rhs_occurrences) : fragment.text }.join.freeze
        @rhs_occurrences = rhs_occurrences.freeze
        freeze
      end
    end
  end
end
