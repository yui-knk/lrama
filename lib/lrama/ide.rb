require "forwardable"

module Lrama
  class IDE
    extend Forwardable

    def_delegators "@states", :symbols, :terms, :nterms, :rules, :states,
      :find_symbol_by_s_value!

    def self.load_grammar_file(path)
      y = File.read(path)
      grammar = Lrama::Parser.new(y).parse
      warning = Lrama::Warning.new
      states = Lrama::States.new(grammar, warning)
      states.compute

      return IDE.new(states, path)
    end

    attr_reader :current_state

    def initialize(states, path = "")
      @states = states
      @path = path
      @current_state = states.states.first
      # TODO: Need one more stack managing the histroy of operaions
      #       so that states is never dismissed when reduce happens
      @states_stack = [@current_state]
    end

    def inspect
      "#{self.class.name}(#{@path})"
    end

    # Will be removed
    def set_current_state(state_id)
      state = states[state_id]

      raise "#{state_id} is not valid" unless state

      @current_state = state
    end

    def reset_state
      set_current_state(0)
      @states_stack = [@current_state]
    end

    def transition(s_value)
      sym = find_symbol_by_s_value!(s_value)
      @current_state = @current_state.transition(sym)
      @states_stack << @current_state
      @current_state
    end

    def nterm_transition_symbols
      @current_state.nterm_transitions.map do |shift, _|
        shift.next_sym.id.s_value
      end
    end

    def term_transition_symbols
      @current_state.term_transitions.map do |shift, _|
        shift.next_sym.id.s_value
      end
    end

    def look_ahead
      @current_state.reduces.map(&:look_ahead).compact.map do |la|
        la.map do |sym|
          sym.id.s_value
        end
      end
    end

    # TODO: Make transition if current state has only one term_transition_symbols,
    #       no nterm_transition_symbols, no default_reduction.
    def next
      if @current_state.default_reduction_rule
        s_value = @current_state.default_reduction_rule.lhs.id.s_value
        transition(s_value)

        puts "Moved to #{@current_state} by #{s_value}"
      else
        puts <<~MSG
          No default reduction rule then no automatic transition

          Nterms:
          #{nterm_transition_symbols.join("\n")}

          Terms:
          #{term_transition_symbols.join("\n")}
        MSG
      end

      @current_state
    end

    def help
      puts <<~HELP
      =====================
      ide.reset_state: Reset state to the first state.
      ide.transition(sym): Given sym, make transition.
      ide.current_state: Return current_state.
      ide.nterm_transition_symbols: Display nonterminal symbols which make transition
      ide.term_transition_symbols: Display terminal symbols which make transition
      ide.look_ahead: Display look_ahead tokens of current state.
      ide.next: Make transition by default reduction rule if current_state has default reduction rule.
      =====================

      HELP
    end
  end
end
