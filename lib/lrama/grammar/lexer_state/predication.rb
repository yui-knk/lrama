# rbs_inline: enabled
# frozen_string_literal: true

require_relative "predication/pattern"

module Lrama
  class Grammar
    class LexerState
      # There are three kinds of predication in grammar file
      #
      # 1) Predication by StateBit, EXPR_END in the example.
      #    This is handled by `Predication`.
      #
      #    EXPR_END {
      #      tNUMBER => EXPR_END;
      #    };
      #
      # 2) Predication by `predication`, IS_BEG in the example.
      #    This is also handled by `Predication`.
      #
      #    predication IS_BEG_ANY = EXPR_BEG | EXPR_MID | EXPR_CLASS;
      #    ...
      #
      #    IS_BEG_ANY {
      #      tNUMBER => EXPR_END;
      #    };
      #
      # 3) Predication by `*`.
      #    This is handled by `AnyPredication`.
      #
      #    * {
      #      tSTRING_END => EXPR_END;
      #    };
      #
      class Predication
        attr_reader :name #: String
        attr_reader :pattern #: Pattern
        attr_reader :negative #: bool

        # @rbs (String name, Pattern pattern, bool negative) -> void
        def initialize(name, pattern, negative)
          @name = name
          @pattern = pattern
          @negative = negative
        end

        # @rbs (Predication other) -> bool
        def ==(other)
          self.class == other.class &&
          self.pattern == other.pattern &&
          self.negative == other.negative
        end

        # @rbs (LexerState::state state) -> bool
        def match?(state)
          b = @pattern.match?(state)

          if negative
            !b
          else
            b
          end
        end

        # @rbs () -> Predication
        def negative_predication
          Predication.new(@name, @pattern, !@negative)
        end

        # @rbs () -> String
        def to_s
          "<#{@name}: #{@pattern}>"
        end
      end
    end
  end
end
