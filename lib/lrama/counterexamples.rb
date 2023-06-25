require "set"

module Lrama
  # See: https://www.cs.cornell.edu/andru/papers/cupex/cupex.pdf
  #      4. Constructing Nonunifying Counterexamples
  class Counterexamples
    # s: state
    # itm: item within s
    # l: precise lookahead set
    class Triple < Struct.new(:s, :itm, :l)
      alias :state :s
      alias :item :itm
      alias :precise_lookahead_set :l

      def inspect
        "#{state.inspect}. #{item.display_name}. #{l.map(&:id).map(&:s_value)}"
      end
      alias :to_s :inspect
    end

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
          len += path.item.display_name.index("•") + 2
        end

        compressed.zip(offsets).map do |path, offset|
          " " * offset + path.item.display_name
        end
      end
    end

    def initialize(states)
      @states = states
    end

    def compute(conflict_state, conflict_reduce_item, conflict_term)
      # queue: is an array of [Triple, [Path]]
      queue = []
      visited = {}
      start_state = @states.states.first
      raise "BUG: Start state should be just one kernel." if start_state.kernels.count != 1

      start = Triple.new(start_state, start_state.kernels.first, Set.new([@states.eof_symbol]))

      queue << [start, [StartPath.new(start)]]

      while true
        triple, paths = queue.shift

        next if visited[triple]
        visited[triple] = true

        # Found
        if triple.state == conflict_state && triple.item == conflict_reduce_item && triple.l.include?(conflict_term) # && triple.item.end_of_rule?
          return triple, Paths.new(paths)
        end

        # transition
        triple.state.transitions.each do |shift, next_state|
          next unless triple.item.next_sym && triple.item.next_sym == shift.next_sym
          next_state.kernels.each do |kernel|
            next if kernel.rule != triple.item.rule
            t = Triple.new(next_state, kernel, triple.l)
            queue << [t, paths + [TransitionPath.new(t, shift.next_sym)]]
          end
        end

        # production step
        triple.state.closure.each do |item|
          next unless triple.item.next_sym && triple.item.next_sym == item.lhs
          l = follow_l(triple.item, triple.l)
          t = Triple.new(triple.state, item, l)
          queue << [t, paths + [ProductionPath.new(t)]]
        end

        break if queue.empty?
      end

      return nil
    end

    private

    def follow_l(item, current_l)
      # 1. follow_L (A -> X1 ... Xn-1 • Xn) = L
      # 2. follow_L (A -> X1 ... Xk • Xk+1 Xk+2 ... Xn) = {Xk+2} if Xk+2 is a terminal
      # 3. follow_L (A -> X1 ... Xk • Xk+1 Xk+2 ... Xn) = FIRST(Xk+2) if Xk+2 is a nonnullable nonterminal
      # 4. follow_L (A -> X1 ... Xk • Xk+1 Xk+2 ... Xn) = FIRST(Xk+2) + follow_L (A -> X1 ... Xk+1 • Xk+2 ... Xn) if Xk+2 is a nullable nonterminal
      case
      when item.number_of_rest_symbols == 1
        current_l
      when item.next_next_sym.term?
        Set.new([item.next_next_sym])
      when !item.next_next_sym.nullable
        item.next_next_sym.first_set
      else
        item.next_next_sym.first_set + follow_l(item.new_by_next_position, current_l)
      end
    end
  end
end