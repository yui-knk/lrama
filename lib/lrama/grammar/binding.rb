# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class Binding
      # @rbs @actual_args: Array[Lexer::Token::Base | Node::RuleRhs::InstantiateRule]
      # @rbs @param_to_arg: Hash[String, Lexer::Token::Base | Node::RuleRhs::InstantiateRule]

      # @rbs (Array[Lexer::Token::Base] params, Array[Lexer::Token::Base | Node::RuleRhs::InstantiateRule] actual_args) -> void
      def initialize(params, actual_args)
        @actual_args = actual_args
        @param_to_arg = build_param_to_arg(params, @actual_args)
      end

      # @rbs (Lexer::Token::Base | Node::RuleRhs::InstantiateRule sym) -> (Lexer::Token::Base | Node::RuleRhs::InstantiateRule)
      def resolve_symbol(sym)
        return resolve_instantiate_rule(sym) if sym.is_a?(Node::RuleRhs::InstantiateRule)
        find_arg_for_param(sym)
      end

      # @rbs (Node::RuleRhs::InstantiateRule token) -> String
      def concatenated_args_str(token)
        "#{token.s_value}_#{format_args(token)}"
      end

      private

      # @rbs (Node::RuleRhs::InstantiateRule sym) -> Node::RuleRhs::InstantiateRule
      def resolve_instantiate_rule(sym)
        Node::RuleRhs::InstantiateRule.new(
          s_value: sym.s_value,
          alias_name: sym.alias_name,
          location: sym.location,
          args: resolve_args(sym.args),
          lhs_tag: sym.lhs_tag
        )
      end

      # @rbs (Array[Lexer::Token::Base | Node::RuleRhs::InstantiateRule]) -> Array[Lexer::Token::Base | Node::RuleRhs::InstantiateRule]
      def resolve_args(args)
        args.map { |arg| resolve_symbol(arg) }
      end

      # @rbs (Lexer::Token::Base sym) -> (Lexer::Token::Base | Node::RuleRhs::InstantiateRule)
      def find_arg_for_param(sym)
        if (arg = @param_to_arg[sym.s_value]&.dup)
          if arg.is_a?(Node::RuleRhs::InstantiateRule)
            Node::RuleRhs::InstantiateRule.new(
              s_value: arg.s_value,
              alias_name: sym.alias_name,
              location: arg.location,
              args: arg.args,
              lhs_tag: arg.lhs_tag
            )
          else
            arg.alias_name = sym.alias_name
            arg
          end
        else
          sym
        end
      end

      # @rbs (Array[Lexer::Token::Base] params, Array[Lexer::Token::Base | Node::RuleRhs::InstantiateRule] actual_args) -> Hash[String, (Lexer::Token::Base | Node::RuleRhs::InstantiateRule)?]
      def build_param_to_arg(params, actual_args)
        params.zip(actual_args).map do |param, arg|
          [param.s_value, arg]
        end.to_h
      end

      # @rbs (Node::RuleRhs::InstantiateRule token) -> String
      def format_args(token)
        token_to_args_s_values(token).join('_')
      end

      # @rbs (Node::RuleRhs::InstantiateRule token) -> Array[String]
      def token_to_args_s_values(token)
        token.args.flat_map do |arg|
          resolved = resolve_symbol(arg)
          if resolved.is_a?(Node::RuleRhs::InstantiateRule)
            [resolved.s_value] + resolved.args.map(&:s_value)
          else
            [resolved.s_value]
          end
        end
      end
    end
  end
end
