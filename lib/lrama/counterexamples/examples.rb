module Lrama
  class Counterexamples
    class Examples
      attr_reader :path1, :path2, :conflict

      # path1 is shift conflict when S/R conflict
      def initialize(path1, path2, conflict, conflict_symbol)
        @path1 = path1
        @path2 = path2
        @conflict = conflict
        @conflict_symbol = conflict_symbol
      end

      def type
        @conflict.type
      end
    end
  end
end
