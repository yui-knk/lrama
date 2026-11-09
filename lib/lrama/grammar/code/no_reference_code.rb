# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class Code
      class NoReferenceCode < Code
        attr_reader :type #: ::Symbol

        # @rbs (type: ::Symbol, code: Grammar::Code) -> void
        def initialize(type:, code:)
          super(text: code.text, location: code.location, references: code.references)
          @type = type
        end

        private

        # * ($$) error
        # * (@$) error
        # * ($:$) error
        # * ($1) error
        # * (@1) error
        # * ($:1) error
        #
        # @rbs (Reference ref) -> bot
        def reference_to_c(ref)
          case
          when ref.type == :dollar # $$, $n
            raise "$#{ref.value} can not be used in #{type}."
          when ref.type == :at # @$, @n
            raise "@#{ref.value} can not be used in #{type}."
          when ref.type == :index # $:$, $:n
            raise "$:#{ref.value} can not be used in #{type}."
          else
            raise "Unexpected. #{self}, #{ref}"
          end
        end
      end
    end
  end
end
