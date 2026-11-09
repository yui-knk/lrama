# rbs_inline: enabled
# frozen_string_literal: true

require_relative "reference_scanner"

module Lrama
  class Grammar
    # Embedded source code and the references resolved during grammar expansion.
    class UserCode
      attr_reader :text #: String
      attr_reader :location #: Lexer::Location

      # @rbs (text: String, ?location: Lexer::Location, ?references: Array[Reference]) -> void
      def initialize(text:, location: nil, references: nil)
        @text = text.freeze
        @location = location
        @references = references
      end

      # @rbs (Lexer::Token::UserCode token) -> UserCode
      def self.from_token(token)
        new(text: token.s_value, location: token.location)
      end

      alias :loc :location

      # @rbs (UserCode other) -> bool
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
    end
  end
end
