# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class Inline
      class Resolver
        # @rbs (Lrama::Grammar::RuleBuilder rule_builder) -> void
        def initialize(rule_builder)
          @rule_builder = rule_builder
        end

        # @rbs () -> Array[Lrama::Grammar::RuleBuilder]
        def resolve
          resolved_builders = [] #: Array[Lrama::Grammar::RuleBuilder]
          @rule_builder.rhs.each_with_index do |node, i|
            next unless node.is_a?(Node::RuleRhs::Symbol) || node.is_a?(Node::RuleRhs::InstantiateRule)

            if (rule = @rule_builder.parameterized_resolver.find_inline(node))
              rule.rhs.each do |rhs|
                resolved_builders << build_rule(rhs, node, i, rule)
              end
              break
            end
          end
          resolved_builders
        end

        private

        # @rbs (Parameterized::Rhs rhs, Node::RuleRhs::value node, Integer index, Parameterized::Rule rule) -> RuleBuilder
        def build_rule(rhs, node, index, rule)
          bindings = node.is_a?(Node::RuleRhs::InstantiateRule) ? Binding.new(rule.parameters, node.args) : nil
          symbols = rhs.symbols.map { |sym| bindings ? bindings.resolve_symbol(sym) : sym }
          expansion = symbols.map { |sym| RhsOccurrence.new(sym) }
          inline_action = bindings ? rhs.resolve_action(bindings) : rhs.action
          inline_bound = inline_action && ReferenceResolver.new(
            lhs: Grammar::Symbol::Id.new(name: rule.name, kind: :ident),
            lhs_alias_name: nil, rhs_occurrences: expansion
          ).resolve(inline_action, position: expansion.length + 1)
          resolver = ReferenceResolver.new(
            lhs: @rule_builder.lhs, lhs_alias_name: @rule_builder.lhs_alias_name,
            rhs_occurrences: @rule_builder.rhs_occurrences
          )

          builder = RuleBuilder.new(
            @rule_builder.rule_counter,
            @rule_builder.midrule_action_counter,
            @rule_builder.parameterized_resolver,
            lhs_tag: @rule_builder.lhs_tag
          )
          builder.lhs = @rule_builder.lhs
          builder.lhs_location = @rule_builder.lhs_location
          builder.lhs_alias_name = @rule_builder.lhs_alias_name
          builder.line = @rule_builder.line

          @rule_builder.rhs.each_with_index do |rhs_node, i|
            if i == index
              expansion.each { |occurrence| builder.add_rhs(occurrence.node, occurrence: occurrence) }
            else
              if rhs_node.is_a?(Node::RuleRhs::Action)
                rhs_node = expand_action(rhs_node, resolver, i + 1, index, expansion, inline_bound)
              end
              builder.add_rhs(rhs_node, occurrence: @rule_builder.rhs_occurrences[i])
            end
          end
          builder.precedence_sym = @rule_builder.precedence_sym
          if (action = @rule_builder.action)
            builder.add_rhs(expand_action(action, resolver, @rule_builder.rhs.length + 1, index, expansion, inline_bound))
          end
          builder.complete_input
          builder
        end

        # @rbs (Node::RuleRhs::Action action, ReferenceResolver resolver, Integer position, Integer index, Array[RhsOccurrence] expansion, BoundAction? inline_bound) -> Node::RuleRhs::Action
        def expand_action(action, resolver, position, index, expansion, inline_bound)
          removed = @rule_builder.rhs_occurrences[index]
          fragments = resolver.resolve(action, position: position).fragments.flat_map do |fragment|
            if fragment.is_a?(Code::TextFragment)
              [fragment]
            elsif fragment.target.equal?(removed)
              if fragment.type == :dollar && inline_bound
                inline_fragments(inline_bound, index, expansion)
              else
                target = fragment.type == :dollar ? expansion.first : expansion.last
                if target.nil?
                  if fragment.type == :dollar
                    fragment.code.invalid_ref(fragment.reference, "Cannot refer to an empty inline rule.")
                  end
                  target = (index > 0 ? @rule_builder.rhs_occurrences[index - 1] : nil) || ReferenceTarget::Stack.new(0)
                end
                [fragment.retarget(target)]
              end
            elsif fragment.target.is_a?(ReferenceTarget::Stack) && fragment.target.number > index + 1
              [fragment.retarget(ReferenceTarget::Stack.new(fragment.target.number + expansion.length - 1))]
            else
              [fragment]
            end
          end
          Node::RuleRhs::Action.new(
            code: action.code, fragments: fragments,
            reference_bindings: action.reference_bindings,
            alias_name: action.alias_name, tag: action.tag, location: action.location
          )
        end

        # References outside an inline RHS are relative to its insertion point.
        # @rbs (BoundAction action, Integer index, Array[RhsOccurrence] expansion) -> Array[Code::TextFragment | ResolvedReference]
        def inline_fragments(action, index, expansion)
          occurrences = @rule_builder.rhs_occurrences[0...index] + expansion + (@rule_builder.rhs_occurrences[(index + 1)..-1] || [])
          action.fragments.map do |fragment|
            if fragment.is_a?(ResolvedReference) && fragment.target.is_a?(ReferenceTarget::Stack)
              number = index + fragment.target.number
              target = (number > 0 ? occurrences[number - 1] : nil) || ReferenceTarget::Stack.new(number)
              fragment.retarget(target)
            else
              fragment
            end
          end
        end
      end
    end
  end
end
