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
      # @rbs!
      #   interface _ReferenceTranslator
      #     def reference_to_c: (Reference ref) -> String
      #   end

      attr_reader :text #: String
      attr_reader :location #: Lexer::Location

      # @rbs (text: String, ?location: Lexer::Location, ?references: Array[Reference]) -> void
      def initialize(text:, location: nil, references: nil)
        @text = text.freeze
        @location = location
        @references = references
      end

      # @rbs (Lexer::Token::UserCode token) -> Code
      def self.from_token(token)
        new(text: token.s_value, location: token.location)
      end

      alias :loc :location

      # @rbs (Code other) -> bool
      def ==(other)
        self.class == other.class && self.text == other.text
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
        @references ||= ReferenceScanner.new(text).scan
      end

      # @rbs (Reference ref, String message) -> bot
      def invalid_ref(ref, message)
        location = self.location.partial_location(ref.first_column, ref.last_column)
        raise location.generate_error_message(message)
      end

      # Translate references using the context supplied by the caller.
      #
      # @rbs (_ReferenceTranslator translator) -> String
      def translated_code(translator)
        t_code = text.dup

        references.reverse_each do |ref|
          first_column = ref.first_column
          last_column = ref.last_column

          str = translator.reference_to_c(ref)

          t_code[first_column...last_column] = str
        end

        return t_code
      end
    end
  end
end
