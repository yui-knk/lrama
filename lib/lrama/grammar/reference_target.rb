# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    module ReferenceTarget
      # @rbs!
      #   type target = Lhs | Grammar::RhsOccurrence | Stack

      class Lhs
        # @rbs () -> void
        def initialize
          freeze
        end
      end

      # A rule-relative position outside the RHS, such as $0 or an unchecked @n.
      class Stack
        attr_reader :number #: Integer

        # @rbs (Integer number) -> void
        def initialize(number)
          @number = number
          freeze
        end
      end
    end
  end
end
