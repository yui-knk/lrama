# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    module Node
      module RuleRhs
        class Action < Node::Base
          # Keep the lexer token for source locations; expansion state belongs to the action.
          attr_reader :code #: Lexer::Token::UserCode
          attr_reader :text #: String
          attr_reader :references #: Array[Grammar::Reference]
          attr_reader :alias_name #: String?
          attr_reader :tag #: Lexer::Token::Tag?
          attr_accessor :referred #: bool

          # @rbs (code: Lexer::Token::UserCode, ?text: String, ?references: Array[Grammar::Reference],
          #       ?alias_name: String?, ?tag: Lexer::Token::Tag?, location: Lexer::Location) -> void
          def initialize(code:, text: code.s_value, references: Lexer::ReferenceScanner.new(text).scan,
                         alias_name: nil, tag: nil, location:)
            @code = code
            @text = text.freeze
            @references = references
            @alias_name = alias_name
            @tag = tag
            @referred = false
            super(location: location)
          end
        end
      end
    end
  end
end
