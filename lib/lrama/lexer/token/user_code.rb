# rbs_inline: enabled
# frozen_string_literal: true

require_relative "../reference_scanner"

module Lrama
  class Lexer
    module Token
      class UserCode < Base
        attr_accessor :tag #: Lexer::Token::Tag?

        # @rbs () -> Array[Lrama::Grammar::Reference]
        def references
          @references ||= ReferenceScanner.new(s_value).scan
        end
      end
    end
  end
end
