module Lrama
  class Grammar
    class ParameterizingRule
      class Resolver
        def initialize
          @rules = []
          @cache = {}
        end

        def add_parameterizing_rule(rule)
          @rules << rule
        end

        def defined?(token)
          !select_rules(token).empty?
        end

        def find(token)
          select_rules(token).last
        end

        def add_cache(str)
          @cache[str] = true
        end

        def cached?(str)
          !!@cache[str]
        end

        private

        def select_rules(token)
          @rules.select do |rule|
            rule.name == token.rule_name &&
              rule.required_parameters_count == token.args_count
          end
        end
      end
    end
  end
end
