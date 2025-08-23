# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    module Node
      module RuleRhs
        class InstantiateRule < Node::Base
          attr_reader :s_value #: String
          attr_reader :args #: Array[Lexer::Token::Base]
          attr_reader :alias_name #: String?
          attr_reader :lhs_tag #: Lexer::Token::Tag

          def initialize(s_value:, args:, alias_name: nil, lhs_tag: nil, location:)
            @s_value = s_value
            @args = args
            @alias_name = alias_name
            @lhs_tag = lhs_tag
            super(location: location)
          end
        end
      end
    end
  end
end
