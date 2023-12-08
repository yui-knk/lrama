module Lrama
  class Grammar
    class ParameterizingRuleBuilder
      attr_reader :name, :args, :rhs, :term

      def initialize(name, args, rhs)
        @name = name
        @args = args
        @rhs = rhs
        @term = nil
        @required_args_count = args.count
      end

      def build_rules(token, build_token, rule_counter, lhs_tag, user_code, precedence_sym, line)
        validate_argument_number!(token)
        rules = []
        @rhs.each do |rhs|
          @term = rhs_term(token, rhs)
          rules << Rule.new(id: rule_counter.increment, _lhs: build_token, _rhs: [@term].compact, lhs_tag: lhs_tag, token_code: rhs.user_code, precedence_sym: rhs.precedence_sym, lineno: line)
        end
        rules
      end

      def build_token(token)
        validate_argument_number!(token)
        Lrama::Lexer::Token::Ident.new(s_value: "#{name}_#{token.args.first&.s_value}")
      end

      private

      def validate_argument_number!(token)
        unless @required_args_count == token.args.count
          raise "Invalid number of arguments. expect: #{@required_args_count} actual: #{token.args.count}"
        end
      end

      def rhs_term(token, rhs)
        return nil unless rhs.symbol
        term = rhs.symbol
        @args.each_with_index do |arg, index|
          term = token.args[index] if arg.s_value == rhs.symbol.s_value
        end
        term
      end
    end
  end
end
