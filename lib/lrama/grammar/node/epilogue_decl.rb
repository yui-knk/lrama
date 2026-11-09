# rbs_inline: enabled
# frozen_string_literal: true

module Lrama
  class Grammar
    module Node
      class EpilogueDecl < Base
        attr_reader :code #: Grammar::Code

        # @rbs (code: Grammar::Code, location: Lexer::Location) -> void
        def initialize(code:, location:)
          @code = code
          super(location: location)
        end
      end
    end
  end
end
