# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    module Node
      module RuleRhs
        class Action < Node::Base
          # @rbs!
          #   @text: String?
          #   @references: Array[Grammar::Reference]?

          attr_reader :code #: Lexer::Token::UserCode
          attr_reader :alias_name #: String?
          attr_reader :tag #: Lexer::Token::Tag?

          # @rbs (code: Lexer::Token::UserCode, ?text: String?, ?references: Array[Grammar::Reference]?, ?alias_name: String?, ?tag: Lexer::Token::Tag?, location: Lexer::Location) -> void
          def initialize(code:, text: nil, references: nil, alias_name: nil, tag: nil, location:)
            @code = code
            @text = text
            @references = references
            @alias_name = alias_name
            @tag = tag
            super(location: location)
          end

          # @rbs () -> String
          def text
            @text || code.s_value
          end

          # @rbs () -> Array[Grammar::Reference]
          def references
            @references || code.references
          end
        end
      end
    end
  end
end
