# rbs_inline: enabled
# frozen_string_literal: true

require "forwardable"

module Lrama
  class Grammar
    # A reference's binding in one action, separate from its source spelling.
    class ResolvedReference
      # @rbs!
      #   def type: () -> ::Symbol
      #   def ex_tag: () -> Lexer::Token::Base?
      #   def first_column: () -> Integer
      #   def last_column: () -> Integer

      extend Forwardable

      def_delegators :reference, :type, :ex_tag, :first_column, :last_column

      attr_reader :reference #: Reference
      attr_reader :target #: ReferenceTarget::target

      # @rbs (Reference reference, target: ReferenceTarget::target) -> void
      def initialize(reference, target:)
        @reference = reference
        @target = target
        freeze
      end

      # @rbs (Array[RhsOccurrence] occurrences) -> Integer?
      def position(occurrences)
        case target
        when ReferenceTarget::Lhs
          nil
        when ReferenceTarget::Stack
          target.number
        when RhsOccurrence
          index = occurrences.index { |occurrence| occurrence.equal?(target) }
          index ? index + 1 : raise("Reference target is not in this RHS")
        end
      end

      # @rbs () -> (String | Integer)
      def value
        target.is_a?(ReferenceTarget::Lhs) ? "$" : reference.value
      end
    end
  end
end
