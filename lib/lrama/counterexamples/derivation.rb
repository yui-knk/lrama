module Lrama
  class Counterexamples
    class Derivation
      attr_reader :item, :left, :right
      attr_writer :right

      def initialize(item, left, right = nil)
        @item = item
        @left = left
        @right = right
      end

      def to_s
        "#<Derivation(#{item.display_name})>"
      end
      alias :inspect :to_s

      def render_for_report
        result = []
        _render_for_report(self, 0, result, 0)
        result.map(&:rstrip).join("\n")
      end

      private

      def _render_for_report(derivation, offset, strings, index)
        item = derivation.item
        if strings[index]
          strings[index] << " " * (offset - strings[index].length)
        else
          strings[index] = " " * offset
        end
        str = strings[index]
        str << "#{item.rule_id}: #{item.symbols_before_dot.map(&:display_name).join(" ")} "

        if derivation.left
          len = str.length
          str << "#{item.next_sym.display_name}"
          length = _render_for_report(derivation.left, len, strings, index + 1)
          # I want String#ljust!
          str << " " * (length - str.length)
        else
# binding.irb
          str << " • #{item.symbols_after_dot.map(&:display_name).join(" ")} "
        end

        if derivation.right&.left
          len = str.length
          str << item.next_next_sym.display_name
          _render_for_report(derivation.right.left, len, strings, index + 1)
        elsif item.next_next_sym
          str << "#{item.symbols_after_dot[1..-1].map(&:display_name).join(" ")} "
        end

        return str.length
      end
    end
  end
end
