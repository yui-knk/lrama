# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class LexerState
      class StateBit
        attr_reader :name #: String

        # @rbs (String name) -> void
        def initialize(name)
          @name = name
        end

        # @rbs (StateBit other) -> bool
        def ==(other)
          self.class == other.class &&
          self.name == other.name
        end

        # @rbs () -> String
        def to_s
          "#{@name}"
        end
      end
    end
  end
end
