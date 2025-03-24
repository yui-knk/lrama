# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class LexerState
      class State
        # @rbs!
        #   include Enumerable[StateBit]

        # @rbs skip
        include Enumerable

        attr_reader :state_bits #: Array[StateBit]
        attr_reader :bitmap #: Bitmap::bitmap

        # @rbs (Array[StateBit] state_bits) -> void
        def initialize(state_bits)
          @state_bits = state_bits
          @bitmap = Bitmap.from_array(state_bits.map(&:id))
        end

        # @rbs (State other) -> bool
        def ==(other)
          self.class == other.class &&
          self.bitmap == other.bitmap
        end
        alias :eql? :==

        # @rbs () -> Integer
        def hash
          self.bitmap
        end

        # @rbs (StateBit state_bit) -> void
        def <<(state_bit)
          @state_bits << state_bit
          @bitmap = Bitmap.add_integer(@bitmap, state_bit.id)
        end

        # @rbs (State other) -> bool
        def is?(other)
          (bitmap & other.bitmap) != 0
        end

        # @rbs (State other) -> bool
        def is_all?(other)
          (bitmap & other.bitmap) == bitmap
        end

        # @rbs () { (StateBit) -> void } -> self
        #    | () -> Enumerator[StateBit, self]
        def each(&block)
          if block
            @state_bits.each(&block)
            self
          else
            enum_for { @state_bits.size }
          end
        end

        # @rbs () -> String
        def to_s
          @state_bits.map(&:name).join('|')
        end
      end
    end
  end
end
