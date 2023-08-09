module Lrama
  class Counterexamples
    class Path
      attr_reader :triple

      def initialize(triple)
        @triple = triple
      end

      def item
        @triple.item
      end
    end

    class StartPath < Path
    end

    class TransitionPath < Path
      def initialize(triple, next_sym)
        super triple
        @next_sym = next_sym
      end
    end

    class ProductionPath < Path
    end    
  end
end
