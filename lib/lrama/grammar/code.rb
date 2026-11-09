# rbs_inline: enabled
# frozen_string_literal: true

require_relative "reference_scanner"
require_relative "code/destructor_code"
require_relative "code/initial_action_code"
require_relative "code/no_reference_code"
require_relative "code/printer_code"
require_relative "code/rule_action"

module Lrama
  class Grammar
    class Code
      attr_reader :type #: ::Symbol
      attr_reader :text #: String
      attr_reader :location #: Lexer::Location

      # @rbs (type: ::Symbol, text: String, ?location: Lexer::Location) -> void
      def initialize(type:, text:, location: nil)
        @type = type
        @text = text.freeze
        @location = location
      end

      # @rbs (Lexer::Token::UserCode token, type: ::Symbol) -> Code
      def self.from_token(token, type:)
        new(type: type, text: token.s_value, location: token.location)
      end

      alias :loc :location

      # @rbs (Code other) -> bool
      def ==(other)
        self.class == other.class && self.type == other.type && self.text == other.text
      end

      # @rbs () -> Integer
      def line
        location.first_line
      end

      # @rbs () -> Integer
      def column
        location.first_column
      end

      # @rbs () -> Array[Reference]
      def references
        @references ||= ReferenceScanner.new(text).scan.each(&:freeze).freeze
      end

      # @rbs (Reference | ResolvedReference ref, String message) -> bot
      def invalid_ref(ref, message)
        location = self.location.partial_location(ref.first_column, ref.last_column)
        raise location.generate_error_message(message)
      end

      # $$, $n, @$, @n are translated to C code.
      #
      # @rbs () -> String
      def translated_code
        t_code = text.dup

        translation_references.reverse_each do |ref|
          first_column = ref.first_column
          last_column = ref.last_column

          str = reference_to_c(ref)

          t_code[first_column...last_column] = str
        end

        return t_code
      end

      private

      # @rbs () -> Array[Reference | ResolvedReference]
      def translation_references
        references
      end

      # @rbs (Reference | ResolvedReference ref) -> bot
      def reference_to_c(ref)
        raise NotImplementedError.new("#reference_to_c is not implemented")
      end
    end
  end
end
