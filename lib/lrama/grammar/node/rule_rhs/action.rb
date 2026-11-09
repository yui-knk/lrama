# rbs_inline: enabled
# frozen_string_literal: true

require "forwardable"

module Lrama
  class Grammar
    module Node
      module RuleRhs
        class Action < Node::Base
          # @rbs!
          #   def text: () -> String
          #   def references: () -> Array[Grammar::Reference]

          extend Forwardable

          def_delegators :code, :text, :references

          attr_reader :code #: Grammar::Code
          attr_reader :alias_name #: String?
          attr_reader :tag #: Lexer::Token::Tag?
          attr_accessor :referred #: bool
          attr_reader :resolved_references #: Array[ResolvedReference]?

          # @rbs (code: Grammar::Code, ?alias_name: String?, ?tag: Lexer::Token::Tag?, ?resolved_references: Array[ResolvedReference]?, location: Lexer::Location) -> void
          def initialize(code:, alias_name: nil, tag: nil, resolved_references: nil, location:)
            @code = code
            @alias_name = alias_name
            @tag = tag
            @resolved_references = resolved_references&.freeze
            @referred = false
            super(location: location)
          end

          # @rbs (Array[ResolvedReference] references) -> Array[ResolvedReference]
          def resolved_references=(references)
            @resolved_references = references.freeze
          end
        end
      end
    end
  end
end
