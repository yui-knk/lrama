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
          attr_reader :reference_bindings #: Hash[String, String]

          # @rbs (code: Grammar::Code, ?alias_name: String?, ?tag: Lexer::Token::Tag?, ?reference_bindings: Hash[String, String], location: Lexer::Location) -> void
          def initialize(code:, alias_name: nil, tag: nil, reference_bindings: {}, location:)
            @code = code
            @alias_name = alias_name
            @tag = tag
            @reference_bindings = reference_bindings.freeze
            super(location: location)
            freeze
          end

        end
      end
    end
  end
end
