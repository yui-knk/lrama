module Lrama
  class Counterexamples
    class Path
      def initialize(from_state_item, to_state_item)
        @from_state_item = from_state_item
        @to_state_item = to_state_item
      end

      def from
        @from_state_item
      end

      def to
        @to_state_item
      end
    end

    class StartPath < Path
      def initialize(to_state_item)
        super nil, to_state_item
      end

      def transition?
        false
      end

      def production?
        false
      end
    end

    class TransitionPath < Path
      def initialize(from_state_item, to_state_item, next_sym)
        super from_state_item, to_state_item
        @next_sym = next_sym
      end

      def transition?
        true
      end

      def production?
        false
      end
    end

    class ProductionPath < Path
      def transition?
        false
      end

      def production?
        true
      end
    end    
  end
end
