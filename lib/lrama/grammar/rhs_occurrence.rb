# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    # Identifies one appearance of an RHS element, even when symbols repeat.
    class RhsOccurrence
      attr_reader :node #: Node::RuleRhs::rhs

      # @rbs (Node::RuleRhs::rhs node) -> void
      def initialize(node)
        @node = node
        freeze
      end
    end
  end
end
