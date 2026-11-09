# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    module Node
      module RuleRhs
        class Action < Node::Base
          attr_reader :code #: Grammar::Code
          attr_reader :text #: String
          attr_reader :references #: Array[Reference]
          attr_reader :fragments #: Array[Code::fragment]
          attr_reader :alias_name #: String?
          attr_reader :tag #: Lexer::Token::Tag?
          attr_reader :reference_bindings #: Hash[String, String]

          # @rbs (code: Grammar::Code, ?alias_name: String?, ?tag: Lexer::Token::Tag?, ?reference_bindings: Hash[String, String], ?fragments: Array[Code::fragment], location: Lexer::Location) -> void
          def initialize(code:, alias_name: nil, tag: nil, reference_bindings: {}, fragments: code.fragments, location:)
            @code = code
            @fragments = fragments.freeze
            @text = fragments.map(&:text).join.freeze
            @references = fragments.each_with_object([]) do |fragment, refs|
              refs << fragment.reference unless fragment.is_a?(Code::TextFragment)
            end.freeze
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
