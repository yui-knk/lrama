module Lrama
  class Grammar
    class ParameterizingRule
      class Rhs
        attr_accessor :symbols, :user_code, :precedence_sym

        def initialize
          @symbols = []
          @user_code = nil
          @precedence_sym = nil
        end

        def resolve_user_code(bindings)
          return unless user_code

          # numberize_references
          user_code.references.each do |ref|
            ref_name = ref.name

            if ref_name
              if ref_name == '$'
                ref.name = '$'
              else
                candidates = @symbols.each_with_index.select {|token, _i| token.referred_by?(ref_name) }

                if candidates.size >= 2
                  token.invalid_ref(ref, "Referring symbol `#{ref_name}` is duplicated.")
                end

                unless (referring_symbol = candidates.first)
                  token.invalid_ref(ref, "Referring symbol `#{ref_name}` is not found.")
                end

                # if referring_symbol[1] == 0 # Refers to LHS
                #   ref.name = '$'
                # else
                  ref.number = referring_symbol[1]
                # end
              end
            end

            if ref.number
              # TODO: When Inlining is implemented, for example, if `$1` is expanded to multiple RHS tokens,
              #       `$2` needs to access `$2 + n` to actually access it. So, after the Inlining implementation,
              #       it needs resolves from number to index.
              ref.index = ref.number
            end

            # TODO: Need to check index of @ too?
            next if ref.type == :at

            # if ref.index
            #   # TODO: Prohibit $0 even so Bison allows it?
            #   # See: https://www.gnu.org/software/bison/manual/html_node/Actions.html
            #   token.invalid_ref(ref, "Can not refer following component. #{ref.index} >= #{i}.") if ref.index >= i
            #   rhs[ref.index - 1].referred = true
            # end
          end

          return user_code
        end
      end
    end
  end
end
