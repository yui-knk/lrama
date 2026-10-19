# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class Binding
      # @rbs @param_to_arg: Hash[String, Node::RuleRhs::value]

      # @rbs (Array[Lexer::Token::Base] params, Array[Node::RuleRhs::value] actual_args) -> void
      def initialize(params, actual_args)
        @param_to_arg = build_param_to_arg(params, actual_args)
      end

      # @rbs (Node::RuleRhs::value sym) -> Node::RuleRhs::value
      def resolve_symbol(sym)
        case sym
        when Node::RuleRhs::InstantiateRule
          resolve_instantiate_rule(sym)
        when Node::RuleRhs::Symbol
          find_arg_for_param(sym)
        else
          raise "Unknown parameterized rule symbol: #{sym}"
        end
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

      # @rbs (Array[Node::RuleRhs::value]) -> Array[Node::RuleRhs::value]
      def resolve_args(args)
        args.map { |arg| resolve_symbol(arg) }
      end

      # @rbs (Node::RuleRhs::Symbol sym) -> Node::RuleRhs::value
      def find_arg_for_param(sym)
        if (arg = @param_to_arg[sym.s_value])
          case arg
          when Node::RuleRhs::InstantiateRule
            Node::RuleRhs::InstantiateRule.new(
              s_value: arg.s_value,
              alias_name: sym.alias_name,
              location: arg.location,
              args: arg.args,
              lhs_tag: arg.lhs_tag
            )
          when Node::RuleRhs::Symbol
            Node::RuleRhs::Symbol.new(
              token: arg.token.dup,
              alias_name: sym.alias_name,
              location: arg.location
            )
          else
            raise "Unknown parameterized rule argument: #{arg}"
          end
        else
          sym
        end
      end

      # @rbs (Array[Lexer::Token::Base] params, Array[Node::RuleRhs::value] actual_args) -> Hash[String, Node::RuleRhs::value]
      def build_param_to_arg(params, actual_args)
        params.each_with_index.to_h do |param, index|
          [param.s_value, actual_args.fetch(index)]
        end
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
            [resolved.s_value] + resolved.args.map { |arg| arg.s_value }
          else
            [resolved.s_value]
          end
        end
      end
    end
  end
end
