module Lrama
  class Lexer
    class Token
      class InstantiateRule < Token
        class Arguments
          attr_reader :actual_args, :count

          def initialize(parameters, actual_args)
            @parameters = parameters
            @actual_args = actual_args
            @count = parameters.count
            @parameter_to_arg = parameters.zip(actual_args).map do |param, arg|
              [param.s_value, arg]
            end.to_h
          end

          def to_s
            actual_args.map(&:s_value).join('_')
          end

          def resolve_symbol(symbol)
            @parameter_to_arg[symbol.s_value] || symbol
          end
        end
      end
    end
  end
end
