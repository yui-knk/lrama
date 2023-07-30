m_reduce = Module.new do
  def code_has_set_lex_state?
    code_string && code_string.include?("@SET_LEX_STATE")
  end

  def lex_state
    if code_has_set_lex_state?
      /@SET_LEX_STATE\(([\w|]+)\)/ =~ code_string
      Lrama::LexState.const_get($1)
    else
      nil
    end
  end

  private

  def code_string
    code && code.token_code.s_value
  end
end
Lrama::State::Reduce.include(m_reduce)

m_state = Module.new do
  def lex_state_transition_by_reduce
    lex_states.flat_map do |lex_state|
      reduces.map do |reduce|
        if reduce.code_has_set_lex_state?
          if defaulted_state?
            lex_state.merge(Lrama::LexState::Transition.new(type: :defaulted_state, lex_state: reduce.lex_state))
          else
            lex_state.merge(Lrama::LexState::Transition.new(type: :not_defaulted_state, lex_state: reduce.lex_state))
          end
        else
          # Keep current status
          lex_state.merge(Lrama::LexState::Transition.new(type: :defaulted_state, lex_state: lex_state.lex_state))
        end
      end
    end
  end
end
Lrama::State.include(m_state)


module Lrama
  class LexState
    EXPR_NONE = 0
    EXPR_BEG = 1
    EXPR_END = 2
    EXPR_ENDARG = 4
    EXPR_ENDFN = 8
    EXPR_ARG = 16
    EXPR_CMDARG = 32
    EXPR_MID = 64
    EXPR_FNAME = 128
    EXPR_DOT = 256
    EXPR_CLASS = 512
    EXPR_LABEL = 1024
    EXPR_LABELED = 2048
    EXPR_FITEM = 4096
    EXPR_VALUE = EXPR_BEG
    EXPR_BEG_ANY  =  (EXPR_BEG | EXPR_MID | EXPR_CLASS)
    EXPR_ARG_ANY  =  (EXPR_ARG | EXPR_CMDARG)
    EXPR_END_ANY  =  (EXPR_END | EXPR_ENDARG | EXPR_ENDFN)

    class Transition < Struct.new(:type, :lex_state, keyword_init: true)
      def merge(next_transition)
        case [next_transition.type, self.type]
        when [:defaulted_state, :shift]
          next_transition
        when [:defaulted_state, :defaulted_state]
          next_transition
        when [:defaulted_state, :not_defaulted_state]
          next_transition

        when [:shift, :shift]
          next_transition
        when [:shift, :defaulted_state]
          next_transition
        when [:shift, :not_defaulted_state]
          #
          Transition.new(type: :defaulted_state, lex_state: self.lex_state)

        when [:not_defaulted_state, :shift]
          #
          next_transition
        when [:not_defaulted_state, :defaulted_state]
          next_transition
        when [:not_defaulted_state, :not_defaulted_state]
          next_transition
        end
      end
    end

    def self.int_to_lex_states(int)
    end

    def initialize(states)
      @states = states

      # validate #transition
      states.terms.each do |term|
        term_transition(state: EXPR_NONE, cmd_state: false, token: term.id.s_value)
      end

      @nterm_to_reduce_states = {}

      states.states.each do |state|
        state.reduces.each do |reduce|
          s_value = reduce.item.rule.lhs.id.s_value
          @nterm_to_reduce_states[s_value] ||= []
          @nterm_to_reduce_states[s_value] << state
        end
      end
    end

    def compute
      @states.states.first.lex_states << Transition.new(type: :defaulted_state, lex_state: EXPR_NONE)
      changed = false

#       ss = states.states.select do |state|
#         codes = state.reduces.select do |reduce|
#           reduce.item.rule.code && reduce.item.rule.code.token_code.s_value.include?("SET_LEX_STATE")
#         end

#         !codes.empty?
#       end
#       ss.select do |state|
#         !state.defaulted_state?
#       end.map(&:id)
      while true do
        @states.states.each do |state|
          state.nterm_transitions.each do |shift, next_state|
            next_lex_state = nterm_transition(shift.next_sym.id.s_value).to_set

            unless (next_lex_state - next_state.lex_states).empty?
# binding.irb
              next_state.lex_states.merge(next_lex_state)
              changed = true
            end
          end

          state.term_transitions.each do |shift, next_state|
            next_lex_state = state.lex_states.map do |lex_state|
              next_lex_state = term_transition(state: lex_state.lex_state, cmd_state: false, token: shift.next_sym.id.s_value)
              lex_state.merge(Transition.new(type: :shift, lex_state: next_lex_state))
            end.to_set

            unless (next_lex_state - next_state.lex_states).empty?
# binding.irb
              next_state.lex_states.merge(next_lex_state)
              changed = true
            end
          end
        end

        break unless changed
      end
binding.irb
    end

    def nterm_transition(token)
      @nterm_to_reduce_states[token].flat_map do |state|
        state.lex_state_transition_by_reduce
      end
    end

    def term_transition(state:, cmd_state:, token:)
      case token
      when "';'",
           "tOP_ASGN",
           "tOROP",
           "tANDOP",
           "tCOLON3",
           "tLAMBEG",
           "'{'",
           "tLBRACE_ARG",
           "'\n'",
           "':'",
           "tUMINUS_NUM",
           "tDOT3",
           "tBDOT2",
           "tDOT2"
        return EXPR_BEG

      when "'?'"
        return EXPR_VALUE

      when "','",
           "tLBRACE",
           "tLPAREN",
           "tLPAREN_ARG",
           "'('"
        return EXPR_BEG|EXPR_LABEL

      when "tASET",
           "tAREF"
        return EXPR_ARG

      when "tLABEL"
        return EXPR_ARG|EXPR_LABELED

      when "tCMP",
           "tLEQ",
           "tLSHFT",
           "'<'",
           "tGEQ",
           "tRSHFT",
           "'>'",
           "tDSTAR",
           "tPOW",
           "tSTAR",
           "'*'",
           "tEQQ",
           "tEQ",
           "tMATCH",
           "tASSOC",
           "'='",
           "tAMPER",
           "'&'",
           "'/'",
           "'^'",
           "'%'",
           "'!'",
           "tNEQ",
           "tNMATCH",
           "'~'",
           "tUPLUS",
           "'+'",
           "tUMINUS",
           "'-'"
        return is_after_operator(state) ? EXPR_ARG : EXPR_BEG

      when "'['",
           "tLBRACK"
        return is_after_operator(state) ? (EXPR_ARG|EXPR_LABEL) : (EXPR_BEG|EXPR_LABEL)

      when "'|'"
        return is_after_operator(state) ? EXPR_ARG : EXPR_BEG|EXPR_LABEL

      when "')'",
           "tLAMBDA"
        return EXPR_ENDFN

      when "tBDOT3"
        # TODO
        return EXPR_BEG
        # if in_argdef
        #   return EXPR_ENDARG
        # else
        #   return EXPR_BEG
        # end

      when "tANDDOT",
           "tCOLON2",
           "'.'"
        return EXPR_DOT

      when "tSYMBEG"
        return EXPR_FNAME

      when "']'",
           "'}'",
           "tSTRING_END", # Should tSTRING_DEND also change state?
           "tREGEXP_END",
           "tCHAR",
           "tFLOAT",
           "tRATIONAL",
           "tINTEGER",
           "tIMAGINARY",
           "'$'", # This is "invalid token"
           "tGVAR",
           "tBACK_REF",
           "tNTH_REF"
        return EXPR_END

      when "tLABEL_END"
        return EXPR_ARG|EXPR_LABELED

      when "tIVAR",
           "tCVAR"
        return is_lex_state_for(state, EXPR_FNAME) ? EXPR_ENDFN : EXPR_END

      when "tFID",
           "tIDENTIFIER",
           "tCONSTANT"
        if is_lex_state_for(state, EXPR_BEG_ANY | EXPR_ARG_ANY | EXPR_DOT)
          if cmd_state
            return EXPR_CMDARG
          else
            return EXPR_ARG
          end
        elsif is_lex_state_for(state, EXPR_FNAME)
          return EXPR_ENDFN
        else
          return EXPR_END
        end

      when "tIDENTIFIER2"
        return EXPR_END|EXPR_LABEL

      when "'`'"
        if is_lex_state_for(state, EXPR_FNAME)
          return EXPR_ENDFN
        end

        if is_lex_state_for(state, EXPR_DOT)
          if cmd_state
            return EXPR_CMDARG
          else
            return EXPR_ARG
          end
        end

        return state

      # keywords
      when "keyword__ENCODING__",
           "keyword__LINE__",
           "keyword__FILE__",
           "keyword_BEGIN",
           "keyword_END",
           "keyword_end",
           "keyword_false",
           "keyword_nil",
           "keyword_redo",
           "keyword_retry",
           "keyword_self",
           "keyword_true"
        if is_lex_state_for(state, EXPR_FNAME)
          return EXPR_ENDFN
        else
          return EXPR_END
        end

      when "keyword_alias",
           "keyword_undef"
        if is_lex_state_for(state, EXPR_FNAME)
          return EXPR_ENDFN
        else
          return EXPR_FNAME|EXPR_FITEM
        end

      when "keyword_and",
           "keyword_case",
           "keyword_elsif",
           "keyword_for",
           "keyword_if",
           "keyword_in",
           "keyword_module",
           "keyword_or",
           "keyword_unless",
           "keyword_until",
           "keyword_when",
           "keyword_while"
        if is_lex_state_for(state, EXPR_FNAME)
          return EXPR_ENDFN
        else
          return EXPR_VALUE
        end

      when "keyword_begin",
           "keyword_do",
           "keyword_do_LAMBDA",
           "keyword_do_cond",
           "keyword_do_block",
           "keyword_else",
           "keyword_ensure",
           "keyword_then"
        if is_lex_state_for(state, EXPR_FNAME)
          return EXPR_ENDFN
        else
          return EXPR_BEG
        end

      when "keyword_break",
           "keyword_next",
           "keyword_rescue",
           "keyword_return"
        if is_lex_state_for(state, EXPR_FNAME)
          return EXPR_ENDFN
        else
          return EXPR_MID
        end

      when "keyword_class"
        if is_lex_state_for(state, EXPR_FNAME)
          return EXPR_ENDFN
        else
          return EXPR_CLASS
        end

      when "keyword_def"
        if is_lex_state_for(state, EXPR_FNAME)
          return EXPR_ENDFN
        else
          return EXPR_FNAME
        end

      when "keyword_defined",
           "keyword_not",
           "keyword_super",
           "keyword_yield"
        if is_lex_state_for(state, EXPR_FNAME)
          return EXPR_ENDFN
        else
          return EXPR_ARG
        end

      # kw->id[0] != kw->id[1]
      when "modifier_if",
           "modifier_rescue",
           "modifier_unless",
           "modifier_until",
           "modifier_while"
        if is_lex_state_for(state, EXPR_FNAME)
          return EXPR_ENDFN
        else
          return EXPR_BEG | EXPR_LABEL
        end

      # Do not change state
      when "END_OF_INPUT",
           "YYerror",
           "YYUNDEF",
           "tSTRING_CONTENT",
           "tDUMNY_END",
           "'\\\\'",
           "'\\t'",
           "'\\f'",
           "'\\r'",
           "'\\13'",
           "tRPAREN", # not used?
           "tSTRING_BEG",
           "tXSTRING_BEG",
           "tREGEXP_BEG",
           "tWORDS_BEG",
           "tQWORDS_BEG",
           "tSYMBOLS_BEG",
           "tQSYMBOLS_BEG",
           "tSTRING_DEND",
           "tSTRING_DBEG",
           "tSTRING_DVAR",
           "tIGNORED_NL",
           "tCOMMENT",
           "tEMBDOC_BEGD",
           "tEMBDOC",
           "tEMBDOC_BEG",
           "tEMBDOC_END",
           "tHEREDOC_BEG",
           "tHEREDOC_END",
           "k__END__",
           "tLOWEST",
           "tLAST_TOKEN",
           "' '",
           "'\\n'",
           "tSP"
        return state

      else
        raise "transition for #{token} is not defined."
      end
    end

    private

    def is_lex_state_for(x, ls)
      (x & ls) != 0
    end

    # def is_lex_state_all_for(x, ls)
    #   ((x & ls)) == ls
    # end

    # def is_arg(state)
    #   is_lex_state_for(state, EXPR_ARG_ANY)
    # end

    # def is_end(state)
    #   is_lex_state_for(state, EXPR_END_ANY)
    # end

    # def is_beg(state)
    #   is_lex_state_for(state, EXPR_BEG_ANY) || is_lex_state_all_for(state, EXPR_ARG|EXPR_LABELED))
    # end

    def is_after_operator(state)
      is_lex_state_for(state, EXPR_FNAME | EXPR_DOT)
    end
  end
end
