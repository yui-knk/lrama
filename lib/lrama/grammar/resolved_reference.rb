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
      attr_reader :code #: Code
      attr_reader :target #: ReferenceTarget::target

      # @rbs (Reference reference, code: Code, target: ReferenceTarget::target) -> void
      def initialize(reference, code:, target:)
        @reference = reference
        @code = code
        @target = target
        freeze
      end

      # @rbs (ReferenceTarget::target target) -> ResolvedReference
      def retarget(target)
        ResolvedReference.new(reference, code: code, target: target)
      end

      # @rbs () -> String
      def text
        code.text[first_column...last_column] || ""
      end

      # @rbs (Array[RhsOccurrence] occurrences) -> String
      def rendered_text(occurrences)
        number = reference.number
        return text unless number

        position = self.position(occurrences)
        return text if position.nil? || position == number

        case type
        when :dollar then "$#{ex_tag&.s_value}#{position}"
        when :at then "@#{position}"
        when :index then "$:#{position}"
        else raise "Unknown reference kind: #{type}"
        end
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
