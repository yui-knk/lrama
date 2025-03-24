# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class LexerState
      class StateBit
        attr_reader :id #: Integer
        attr_reader :name #: String

        # @rbs (Integer id, String name) -> void
        def initialize(id, name)
          @id = id
          @name = name
        end

        # @rbs (StateBit other) -> bool
        def ==(other)
          self.class == other.class &&
          self.id == other.id
        end

        # @rbs () -> String
        def to_s
          @name
        end
      end
    end
  end
end
