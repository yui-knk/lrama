# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class Parameterized
      class Rhs
        attr_accessor :symbols #: Array[Node::RuleRhs::value]
        attr_accessor :action #: Node::RuleRhs::Action?
        attr_accessor :precedence_sym #: Grammar::Symbol?

        # @rbs () -> void
        def initialize
          @symbols = []
          @action = nil
          @precedence_sym = nil
        end

        # @rbs (Grammar::Binding bindings) -> Node::RuleRhs::Action?
        def resolve_action(bindings)
          return unless action

          resolved_references = action.resolved_references || action.references.map { |ref| ResolvedReference.new(ref) }
          var_to_arg = {} #: Hash[String, String]
          symbols.each do |sym|
            resolved_sym = bindings.resolve_symbol(sym)
            if resolved_sym != sym
              var_to_arg[sym.name] = resolved_sym.name
            end
          end

          var_to_arg.each do |var, arg|
            resolved_references = resolved_references.map do |ref|
              ref.name == var ? ref.with(name: arg) : ref
            end
          end

          Node::RuleRhs::Action.new(
            code: action.code,
            resolved_references: resolved_references,
            alias_name: action.alias_name,
            tag: action.tag,
            location: action.location
          )
        end
      end
    end
  end
end
