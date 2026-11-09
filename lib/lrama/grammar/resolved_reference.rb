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
      attr_reader :name #: String?
      attr_reader :number #: Integer?
      attr_reader :index #: Integer?

      # @rbs (Reference reference, ?name: String?, ?number: Integer?, ?index: Integer?) -> void
      def initialize(reference, name: reference.name, number: reference.number, index: reference.index)
        @reference = reference
        @name = name
        @number = number
        @index = index
        freeze
      end

      # @rbs (?name: String?, ?number: Integer?, ?index: Integer?) -> ResolvedReference
      def with(name: self.name, number: self.number, index: self.index)
        ResolvedReference.new(reference, name: name, number: number, index: index)
      end

      # @rbs () -> (String | Integer)?
      def value
        name || number
      end
    end
  end
end
