# rbs_inline: enabled
# frozen_string_literal: true

require_relative "node/base"
require_relative "node/nterm_decl"
require_relative "node/parameterized_rule"
require_relative "node/precedence_decl"
require_relative "node/prologue_decl"
require_relative "node/require_decl"
require_relative "node/rule"
require_relative "node/rule_rhs"
require_relative "node/symbol"
require_relative "node/token"
require_relative "node/token_decl"
require_relative "node/type_decl"

module Lrama
  class Grammar
    module Node
    end
  end
end
