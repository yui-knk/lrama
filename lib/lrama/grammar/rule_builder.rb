# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    class RuleBuilder
      # TODO: rbs-inline 0.11.0 doesn't support instance variables.
      #       Move these type declarations above instance variable definitions, once it's supported.
      #       see: https://github.com/soutaro/rbs-inline/pull/149
      #
      # @rbs!
      #   @position_in_original_rule_rhs: Integer?
      #   @trailing_precedence: bool
      #   @rules: Array[Rule]
      #   @rule_builders_for_parameterized: Array[RuleBuilder]
      #   @bound_actions: Hash[Node::RuleRhs::Action, BoundAction]
      #   @referenced_occurrences: Hash[RhsOccurrence, bool]
      #   @parameterized_rules: Array[Rule]
      #   @midrule_action_rules: Array[Rule]
      #   @replaced_rhs: Array[Grammar::Symbol::Id]?
      #   @replaced_rhs_locations: Array[Lexer::Location?]?

      attr_accessor :lhs #: Grammar::Symbol::Id?
      attr_accessor :lhs_location #: Lexer::Location?
      attr_accessor :lhs_alias_name #: String?
      attr_accessor :line #: Integer?
      attr_reader :rule_counter #: Counter
      attr_reader :midrule_action_counter #: Counter
      attr_reader :parameterized_resolver #: Grammar::Parameterized::Resolver
      attr_reader :lhs_tag #: Lexer::Token::Tag?
      attr_reader :rhs #: Array[Node::RuleRhs::rhs]
      attr_reader :rhs_occurrences #: Array[RhsOccurrence]
      attr_reader :action #: Node::RuleRhs::Action?
      attr_reader :precedence_sym #: Grammar::Symbol?

      # @rbs (Counter rule_counter, Counter midrule_action_counter, Grammar::Parameterized::Resolver parameterized_resolver, ?Integer position_in_original_rule_rhs, ?lhs_tag: Lexer::Token::Tag?) -> void
      def initialize(rule_counter, midrule_action_counter, parameterized_resolver, position_in_original_rule_rhs = nil, lhs_tag: nil)
        @rule_counter = rule_counter
        @midrule_action_counter = midrule_action_counter
        @parameterized_resolver = parameterized_resolver
        @position_in_original_rule_rhs = position_in_original_rule_rhs
        @trailing_precedence = false

        @lhs = nil
        @lhs_location = nil
        @lhs_alias_name = nil
        @lhs_tag = lhs_tag
        @rhs = []
        @rhs_occurrences = []
        @action = nil
        @precedence_sym = nil
        @line = nil
        @rules = []
        @rule_builders_for_parameterized = []
        @bound_actions = {}
        @referenced_occurrences = {}
        @parameterized_rules = []
        @midrule_action_rules = []
      end

      # @rbs (Node::RuleRhs::rhs rhs) -> void
      def add_rhs(rhs)
        @line ||= rhs.location.first_line

        @rhs << rhs
        @rhs_occurrences << RhsOccurrence.new(rhs)
        @trailing_precedence = false
      end

      # @rbs (Grammar::Symbol? precedence_sym) -> void
      def precedence_sym=(precedence_sym)
        @precedence_sym = precedence_sym
        @trailing_precedence = !precedence_sym.nil?
      end

      # @rbs () -> void
      def complete_input
        if (action = final_action)
          @action = action
          @rhs.pop
          @rhs_occurrences.pop
        end

        freeze_rhs
      end

      # @rbs () -> void
      def setup_rules
        preprocess_references
        process_rhs
        resolve_inline_rules
        build_rules
      end

      # @rbs () -> Array[Grammar::Rule]
      def rules
        @parameterized_rules + @midrule_action_rules + @rules
      end

      # @rbs (?Node::RuleRhs::Action? syntax) -> BoundAction?
      def bound_action(syntax = action)
        syntax && @bound_actions.fetch(syntax)
      end

      # @rbs () -> bool
      def has_inline_rules?
        rhs.any? do |node|
          (node.is_a?(Node::RuleRhs::Symbol) || node.is_a?(Node::RuleRhs::InstantiateRule)) &&
            @parameterized_resolver.find_inline(node)
        end
      end

      private

      # @rbs () -> void
      def freeze_rhs
        @rhs.freeze
        @rhs_occurrences.freeze
      end

      # @rbs () -> Node::RuleRhs::Action?
      def final_action
        return if @trailing_precedence

        action = @rhs.last
        action if action.is_a?(Node::RuleRhs::Action)
      end

      # @rbs () -> void
      def preprocess_references
        numberize_references
      end

      # @rbs () -> void
      def build_rules
        symbols = @replaced_rhs #: Array[Grammar::Symbol::Id]
        locations = @replaced_rhs_locations #: Array[Lexer::Location?]
        return if has_inline_rules?

        rule = Rule.new(
          id: @rule_counter.increment,
          _lhs: lhs,
          _rhs: symbols,
          _lhs_location: lhs_location, _rhs_locations: locations,
          lhs_tag: lhs_tag, action: bound_action,
          position_in_original_rule_rhs: @position_in_original_rule_rhs, precedence_sym: precedence_sym, lineno: line
        )
        @rules = [rule]
        @parameterized_rules = @rule_builders_for_parameterized.map do |rule_builder|
          rule_builder.rules
        end.flatten
        @midrule_action_rules.each do |r|
          r.original_rule = rule
        end
      end

      # `#process_rhs` lowers RHS nodes to symbol IDs.
      #
      # @rbs () -> void
      def process_rhs
        return if @replaced_rhs

        replaced_rhs = [] #: Array[Grammar::Symbol::Id]
        replaced_rhs_locations = [] #: Array[Lexer::Location?]

        rhs.each_with_index do |node, i|
          case node
          when Node::RuleRhs::Symbol
            token = node.token
            replaced_rhs << Grammar::Symbol::Id.from_token(token)
            replaced_rhs_locations << token.location
          when Node::RuleRhs::InstantiateRule
            parameterized_rule = @parameterized_resolver.find_rule(node)
            raise "Unexpected node. #{node}" unless parameterized_rule

            bindings = Binding.new(parameterized_rule.parameters, node.args)
            lhs_s_value = bindings.concatenated_args_str(node)
            if (created_lhs = @parameterized_resolver.created_lhs(lhs_s_value))
              replaced_rhs << created_lhs
            else
              lhs_id = Grammar::Symbol::Id.new(name: lhs_s_value, kind: :ident)
              replaced_rhs << lhs_id
              @parameterized_resolver.created_lhs_list << lhs_id
              parameterized_rule.rhs.each do |r|
                rule_builder = RuleBuilder.new(@rule_counter, @midrule_action_counter, @parameterized_resolver, lhs_tag: node.lhs_tag || parameterized_rule.tag)
                rule_builder.lhs = lhs_id
                rule_builder.lhs_location = node.location
                r.symbols.each { |sym| rule_builder.add_rhs(bindings.resolve_symbol(sym)) }
                rule_builder.line = line
                rule_builder.precedence_sym = r.precedence_sym
                if (action = r.resolve_action(bindings))
                  rule_builder.add_rhs(action)
                end
                rule_builder.complete_input
                rule_builder.setup_rules
                @rule_builders_for_parameterized << rule_builder
              end
            end
            replaced_rhs_locations << node.location
          when Node::RuleRhs::Action
            prefix = @referenced_occurrences[rhs_occurrences[i]] ? "@" : "$@"
            tag = node.tag || lhs_tag
            lhs_id = Grammar::Symbol::Id.new(name: prefix + @midrule_action_counter.increment.to_s, kind: :ident)
            replaced_rhs << lhs_id
            replaced_rhs_locations << nil

            @midrule_action_rules << Rule.new(
              id: @rule_counter.increment, _lhs: lhs_id, _rhs: [], _rhs_locations: [],
              lhs_tag: tag, action: @bound_actions.fetch(node),
              position_in_original_rule_rhs: i, lineno: node.location.first_line
            )
          when Node::RuleRhs::Empty
            # Noop
          else
            raise "Unexpected node. #{node}"
          end
        end

        @replaced_rhs = replaced_rhs
        @replaced_rhs_locations = replaced_rhs_locations
      end

      # @rbs () -> void
      def resolve_inline_rules
        while @rule_builders_for_parameterized.any?(&:has_inline_rules?) do
          @rule_builders_for_parameterized = @rule_builders_for_parameterized.flat_map do |rule_builder|
            if rule_builder.has_inline_rules?
              inlined_builders = Inline::Resolver.new(rule_builder).resolve
              inlined_builders.each { |builder| builder.setup_rules }
              inlined_builders
            else
              rule_builder
            end
          end
        end
      end

      # @rbs () -> void
      def numberize_references
        resolver = ReferenceResolver.new(lhs: lhs, lhs_alias_name: lhs_alias_name, rhs_occurrences: rhs_occurrences)
        (rhs + [action]).compact.each.with_index(1) do |node, i|
          next unless node.is_a?(Node::RuleRhs::Action)

          bound = resolver.resolve(node, position: i)
          @bound_actions[node] = bound
          bound.resolved_references.each do |ref|
            target = ref.target
            @referenced_occurrences[target] = true if ref.type != :at && target.is_a?(RhsOccurrence)
          end
        end
      end
    end
  end
end
