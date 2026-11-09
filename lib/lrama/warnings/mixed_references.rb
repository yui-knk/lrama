# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Warnings
    # Warning rationale: Mixing positional and named references in one rule
    # - It reduces readability and makes semantic actions harder to maintain
    # - Named references are generally more robust when RHS changes
    # Scope:
    # - This warning targets semantic value references (`$...`)
    #   location references (`@...`), and index references (`$:...`)
    #   and special LHS references (`$$`, `$<tag>$`, `@$`, `$:$`)
    class MixedReferences
      # @rbs (Lrama::Logger logger, bool warnings) -> void
      def initialize(logger, warnings)
        @logger = logger
        @warnings = warnings
      end

      # @rbs (Lrama::Grammar grammar) -> void
      def warn(grammar)
        return unless @warnings

        build_grouped_usage(grammar).each do |rule, usage|
          next unless usage[:positional] && usage[:named]

          @logger.warn("rule `#{rule.as_comment}` mixes positional and named references; use named references consistently")
        end
      end

      private

      # @rbs (Lrama::Grammar grammar) -> Hash[Lrama::Grammar::Rule, { positional: bool, named: bool }]
      def build_grouped_usage(grammar)
        grouped_usage = {} #: Hash[Lrama::Grammar::Rule, { positional: bool, named: bool }]

        grammar.rules.each do |rule|
          next unless (action = rule.action)

          original_rule = rule.original_rule || rule
          usage = (grouped_usage[original_rule] ||= { positional: false, named: false })
          classify_references(action.references, usage)
        end

        grouped_usage
      end

      # @rbs (Array[Lrama::Grammar::Reference] references, { positional: bool, named: bool } usage) -> void
      def classify_references(references, usage)
        references.each do |ref|
          if positional_reference?(ref)
            usage[:positional] = true
          elsif named_reference?(ref)
            usage[:named] = true
          end
        end
      end

      # @rbs (Lrama::Grammar::Reference ref) -> bool
      def positional_reference?(ref)
        return false unless reference_type_supported?(ref)
        return false if ref.index.nil?

        ref.name.nil?
      end

      # @rbs (Lrama::Grammar::Reference ref) -> bool
      def named_reference?(ref)
        return false unless reference_type_supported?(ref)

        !ref.name.nil? && ref.name != "$"
      end

      # @rbs (Lrama::Grammar::Reference ref) -> bool
      def reference_type_supported?(ref)
        ref.type == :dollar || ref.type == :at || ref.type == :index
      end
    end
  end
end
