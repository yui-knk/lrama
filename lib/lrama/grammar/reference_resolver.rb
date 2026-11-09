# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class ReferenceResolver
      # @rbs (lhs: Grammar::Symbol::Id?, lhs_alias_name: String?, rhs_occurrences: Array[RhsOccurrence]) -> void
      def initialize(lhs:, lhs_alias_name:, rhs_occurrences:)
        @lhs = lhs
        @lhs_alias_name = lhs_alias_name
        @rhs_occurrences = rhs_occurrences
      end

      # @rbs (Node::RuleRhs::Action action, position: Integer) -> BoundAction
      def resolve(action, position:)
        references = action.references.map do |ref|
          name = ref.name
          name = action.reference_bindings.fetch(name, name) if name
          target =
            if name == "$"
              ReferenceTarget::Lhs.new
            elsif name
              candidates = [@lhs, *@rhs_occurrences.map(&:node)].each_with_index.select { |node, _| named?(node, name) }
              action.code.invalid_ref(ref, "Referring symbol `#{name}` is duplicated.") if candidates.size >= 2
              candidate = candidates.first || action.code.invalid_ref(ref, "Referring symbol `#{name}` is not found.")
              candidate[1] == 0 ? ReferenceTarget::Lhs.new : @rhs_occurrences[candidate[1] - 1]
            else
              number = ref.number
              if number > 0 && (occurrence = @rhs_occurrences[number - 1])
                occurrence
              else
                ReferenceTarget::Stack.new(number)
              end
            end
          resolved = ResolvedReference.new(ref, target: target)
          index = resolved.position(@rhs_occurrences)
          if ref.type != :at && index && index >= position
            action.code.invalid_ref(ref, "Can not refer following component. #{index} >= #{position}.")
          end
          resolved
        end
        BoundAction.new(source: action, resolved_references: references, rhs_occurrences: @rhs_occurrences)
      end

      private

      # @rbs (Grammar::Symbol::Id? | Node::RuleRhs::rhs node, String name) -> bool
      def named?(node, name)
        case node
        when Grammar::Symbol::Id
          [node.name, @lhs_alias_name].compact.include?(name)
        when Node::RuleRhs::Symbol, Node::RuleRhs::InstantiateRule
          [node.name, node.alias_name].compact.include?(name)
        when Node::RuleRhs::Action
          [node.text, node.alias_name].compact.include?(name)
        else
          false
        end
      end
    end
  end
end
