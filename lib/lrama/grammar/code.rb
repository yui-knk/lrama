# rbs_inline: enabled
# frozen_string_literal: true

require_relative "reference_scanner"
require_relative "code/fragment"
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

      # @rbs () -> Array[TextFragment | ReferenceFragment]
      def fragments
        @fragments ||= begin
          parts = [] #: Array[TextFragment | ReferenceFragment]
          cursor = 0
          references.each do |ref|
            parts << TextFragment.new(self, cursor, ref.first_column) if cursor < ref.first_column
            parts << ReferenceFragment.new(self, ref)
            cursor = ref.last_column
          end
          parts << TextFragment.new(self, cursor, text.length) if cursor < text.length
          parts.freeze
        end
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
        translation_fragments.map do |fragment|
          case fragment
          when TextFragment
            fragment.text
          when ReferenceFragment
            reference_to_c(fragment.reference)
          when ResolvedReference
            reference_to_c(fragment)
          end
        end.join
      end

      private

      # @rbs () -> Array[Code::fragment]
      def translation_fragments
        fragments
      end

      # @rbs (Reference | ResolvedReference ref) -> bot
      def reference_to_c(ref)
        raise NotImplementedError.new("#reference_to_c is not implemented")
      end
    end
  end
end
