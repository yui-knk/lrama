module Lrama
  class Counterexamples
    class Paths
      include Enumerable

      attr_reader :paths

      def initialize(paths)
        @paths = paths
      end

      def each(&block)
        block_given? or return enum_for(__method__) { @paths.size }
        @paths.each(&block)
        self
      end

      def formated_paths
        compressed = []
        current = :production

        @paths.reverse.each do |path|
          case current
          when :production
            case path
            when StartPath
              compressed << path
              break
            when TransitionPath
              compressed << path
              current = :transition
            when ProductionPath
              compressed << path
            end
          when :transition
            case path
            when StartPath
              compressed << path
              break
            when TransitionPath
              # ignore
            when ProductionPath
              # ignore
              current = :production
            end
          else
            raise "BUG: Unknown #{current}"
          end
        end

        compressed.reverse!

        len = 0
        offsets = [0] + compressed.map do |path|
          len += path.to.item.display_name.index("•") + 2
        end

        compressed.zip(offsets).map do |path, offset|
          " " * offset + path.to.item.display_name
        end
      end
    end
  end
end
