# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Counterexamples
    # @rbs generic E < Object -- Type of an element
    class Node
      attr_reader :elem #: E
      attr_reader :next_node #: Node[E]?

      # @rbs　[T] (Node[T] node) -> Array[T]
      def self.to_a(node)
        a = [] # steep:ignore UnannotatedEmptyCollection

        while (node)
          a << node.elem
          node = node.next_node
        end

        a
      end

      # @rbs [T < Object] (Node[T] node, T elem) -> bool
      def self.include?(node, elem)
        while (node)
          return true if node.elem == elem
          node = node.next_node
        end

        false
      end

      # @rbs (E elem, Node[E]? next_node) -> void
      def initialize(elem, next_node)
        @elem = elem
        @next_node = next_node
      end
    end
  end
end
