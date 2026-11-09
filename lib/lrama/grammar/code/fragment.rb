# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class Code
      # Each fragment retains its original code and character range across expansion.
      # @rbs!
      #   type fragment = TextFragment | ReferenceFragment | ResolvedReference

      class TextFragment
        attr_reader :code #: Code
        attr_reader :first_column #: Integer
        attr_reader :last_column #: Integer
        attr_reader :text #: String

        # @rbs (Code code, Integer first_column, Integer last_column) -> void
        def initialize(code, first_column, last_column)
          @code = code
          @first_column = first_column
          @last_column = last_column
          @text = (code.text[first_column...last_column] || "").freeze
          freeze
        end
      end

      class ReferenceFragment
        attr_reader :code #: Code
        attr_reader :reference #: Reference

        # @rbs (Code code, Reference reference) -> void
        def initialize(code, reference)
          @code = code
          @reference = reference
          freeze
        end

        # @rbs () -> String
        def text
          code.text[reference.first_column...reference.last_column] || ""
        end
      end
    end
  end
end
