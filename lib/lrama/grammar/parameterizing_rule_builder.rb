module Lrama
  class Grammar
    class ParameterizingRuleBuilder
      attr_reader :name, :parameters, :rhs

      def initialize(name, parameters, rhs)
        @name = name
        @parameters = parameters
        @rhs = rhs
        @required_parameters_count = parameters.count
      end

      def build_rules(token, actual_args, rule_counter, lhs_tag, line, rule_builders)
        arguments = Lrama::Lexer::Token::InstantiateRule::Arguments.new(parameters, actual_args)
        validate_argument_number!(token)
        lhs = lhs(arguments)
        @rhs.map do |rhs|
          rhs.build_rules(token, arguments, rule_counter, lhs, lhs_tag, line, rule_builders)
        end.flatten
      end

      private

      def validate_argument_number!(token)
        unless @required_parameters_count == token.args.count
          raise "Invalid number of arguments. expect: #{@required_parameters_count} actual: #{token.args.count}"
        end
      end

      def lhs(arguments)
        Lrama::Lexer::Token::Ident.new(s_value: "#{name}_#{arguments.to_s}")
      end
    end
  end
end
