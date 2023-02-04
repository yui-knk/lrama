require "lrama/report"

module Lrama
  # Parser for parse.y, generates a grammar
  class Parser
    include Lrama::Report::Duration

    T = Lrama::Lexer::Token

    class TokenScanner
      def initialize(tokens)
        @tokens = tokens
        @index = 0
      end

      def current_token
        @tokens[@index]
      end

      def current_type
        current_token && current_token.type
      end

      def next
        token = current_token
        @index += 1
        return token
      end

      def consume(*token_types)
        if token_types.include?(current_type)
          token = current_token
          self.next
          return token
        end

        return nil
      end

      def consume!(*token_types)
        consume(*token_types) || (raise "#{token_types} is expected but #{current_type}. #{current_token}")
      end

      def consume_multi(*token_types)
        a = []

        while token_types.include?(current_type)
          a << current_token
          self.next
        end

        raise "No token is consumed. #{token_types}" if a.empty?

        return a
      end

      def eots?
        current_token.nil?
      end
    end

    def initialize(text)
      @text = text
    end

    def parse
      report_duration(:parse) do
        lexer = Lexer.new(@text)
        grammar = Grammar.new
        process_prologue(grammar, lexer)
        parse_bison_declarations(TokenScanner.new(lexer.bison_declarations_tokens), grammar)
        parse_grammar_rules(TokenScanner.new(lexer.grammar_rules_tokens), grammar)
        process_epilogue(grammar, lexer)
        grammar.prepare
        grammar.compute_nullable
        grammar.validate!

        grammar
      end
    end

    private

    def process_prologue(grammar, lexer)
      grammar.prologue_first_lineno = lexer.prologue.first[1] if lexer.prologue.first
      grammar.prologue = lexer.prologue.map(&:first).join
    end

    def process_epilogue(grammar, lexer)
      grammar.epilogue_first_lineno = lexer.epilogue.first[1] if lexer.epilogue.first
      grammar.epilogue = lexer.epilogue.map(&:first).join
    end

    def parse_bison_declarations(ts, grammar)
      precedence_number = 0

      while !ts.eots? do
        case ts.current_type
        when T::P_expect
          ts.next
          grammar.expect = ts.consume!(T::Number).s_value
        when T::P_define
          ts.next
          # Ignore
          ts.consume_multi(T::Ident)
        when T::P_printer
          lineno = ts.current_token.line
          ts.next
          code = ts.consume!(T::User_code)
          code = grammar.build_code(:printer, code)
          ident_or_tags = ts.consume_multi(T::Ident, T::Tag)
          grammar.add_printer(ident_or_tags: ident_or_tags, code: code, lineno: lineno)
        when T::P_lex_param
          ts.next
          code = ts.consume!(T::User_code)
          code = grammar.build_code(:lex_param, code)
          grammar.lex_param = code.token_code.s_value
        when T::P_parse_param
          ts.next
          code = ts.consume!(T::User_code)
          code = grammar.build_code(:parse_param, code)
          grammar.parse_param = code.token_code.s_value
        when T::P_initial_action
          ts.next
          code = ts.consume!(T::User_code)
          code = grammar.build_code(:initial_action, code)
          ts.consume(T::Semicolon)
          grammar.initial_action = code
        when T::P_union
          lineno = ts.current_token.line
          ts.next
          code = ts.consume!(T::User_code)
          code = grammar.build_code(:union, code)
          ts.consume(T::Semicolon)
          grammar.set_union(code, lineno)
        when T::P_attr
          # %attr ident
          lineno = ts.current_token.line
          ts.next
          id = ts.consume!(T::Ident)
          grammar.add_attr(id: id, lineno: lineno)
        when T::Case
          # case
          # in ident
          #   lhs[attr1];
          #   lhs[attr2] -> rhs[attr2];
          # end
          ts.next
          while ts.consume(T::In) do
            id = ts.consume!(T::Ident)

            while (lhs = ts.consume(T::Lhs)) do
              ts.consume!(T::Lbrack)
              l_attr = ts.consume!(T::Ident)
              ts.consume!(T::Rbrack)

              case ts.current_type
              when T::Semicolon
                ts.next
              when T::Arrow
                ts.next
                ts.consume!(T::Rhs)
                ts.consume!(T::Lbrack)
                r_attr = ts.consume!(T::Ident)
                ts.consume!(T::Rbrack)
                ts.consume!(T::Semicolon)
              else
                # Noop
              end
            end
          end
          ts.consume!(T::End)
        when T::P_token
          # %token tag? (ident number? string?)+
          #
          # * ident can be char, e.g. '\\', '\t', '\13'
          # * number is a token_id for term
          #
          # These are valid token declaration (from CRuby parse.y)
          #
          # %token END_OF_INPUT   0 "end-of-input"
          # %token <id> '\\'      "backslash"
          # %token tSP            "escaped space"
          # %token tUPLUS         132 "unary+"
          # %token tCOLON3        ":: at EXPR_BEG"
          # %token tSTRING_DBEG tSTRING_DVAR tLAMBEG tLABEL_END
          #
          #
          # See: https://www.gnu.org/software/bison/manual/html_node/Symbol-Decls.html
          ts.next
          opt_tag = ts.consume(T::Tag)

          while (id = ts.consume(T::Ident, T::Char)) do
            opt_number = ts.consume(T::Number)
            opt_string = ts.consume(T::String)
            # Can replace 0 (EOF)
            grammar.add_term(
              id: id,
              alias_name: opt_string && opt_string.s_value,
              token_id: opt_number && opt_number.s_value,
              tag: opt_tag,
              replace: true,
            )
          end
        when T::P_type
          # %type tag? (ident|char|string)+
          #
          # See: https://www.gnu.org/software/bison/manual/html_node/Symbol-Decls.html
          ts.next
          opt_tag = ts.consume(T::Tag)

          while (id = ts.consume(T::Ident, T::Char, T::String)) do
            grammar.add_type(
              id: id,
              tag: opt_tag
            )
          end
        when T::P_nonassoc
          # %nonassoc (ident|char|string)+
          ts.next
          while (id = ts.consume(T::Ident, T::Char, T::String)) do
            sym = grammar.add_term(id: id)
            grammar.add_nonassoc(sym, precedence_number)
          end
          precedence_number += 1
        when T::P_left
          # %left (ident|char|string)+
          ts.next
          while (id = ts.consume(T::Ident, T::Char, T::String)) do
            sym = grammar.add_term(id: id)
            grammar.add_left(sym, precedence_number)
          end
          precedence_number += 1
        when T::P_right
          # %right (ident|char|string)+
          ts.next
          while (id = ts.consume(T::Ident, T::Char, T::String)) do
            sym = grammar.add_term(id: id)
            grammar.add_right(sym, precedence_number)
          end
          precedence_number += 1
        when nil
          # end of input
          raise "Reach to end of input within declarations"
        else
          raise "Unexpected token: #{ts.current_token}"
        end
      end
    end

    def parse_grammar_rules(ts, grammar)
      while !ts.eots? do
        parse_grammar_rule(ts, grammar)
      end
    end

    # TODO: Take care of %prec of rule.
    #       If %prec exists, user code before %prec
    #       is NOT an action. For example "{ code 3 }" is NOT an action.
    #
    #  keyword_class { code 2 } tSTRING '!' keyword_end { code 3 } %prec "="
    def parse_grammar_rule(ts, grammar)
      # LHS
      lhs = ts.consume!(T::Ident_Colon) # class:
      lhs.type = T::Ident

      rhs = parse_grammar_rule_rhs(ts, grammar)

      grammar.add_rule(lhs: lhs, rhs: rhs, lineno: rhs.first ? rhs.first.line : lhs.line)

      while true do
        case ts.current_type
        when T::Bar
          # |
          bar_lineno = ts.current_token.line
          ts.next
          rhs = parse_grammar_rule_rhs(ts, grammar)
          grammar.add_rule(lhs: lhs, rhs: rhs, lineno: rhs.first ? rhs.first.line : bar_lineno)
        when T::Semicolon
          # ;
          ts.next
          break
        when T::Ident_Colon
          # Next lhs can be here because ";" is optional.
          # Do not consume next token.
          break
        when nil
          # end of input can be here when ";" is omitted
          break
        else
          raise "Unexpected token: #{ts.current_token}"
        end
      end
    end

    def parse_grammar_rule_rhs(ts, grammar)
      a = []
      prec_seen = false
      code_after_prec = false

      while true do
        # TODO: Srting can be here
        case ts.current_type
        when T::Ident
          # keyword_class

          raise "Ident after %prec" if prec_seen
          a << ts.current_token
          ts.next
        when T::Char
          # '!'

          raise "Char after %prec" if prec_seen
          a << ts.current_token
          ts.next
        when T::P_prec
          # %prec tPLUS
          #
          # See: https://www.gnu.org/software/bison/manual/html_node/Contextual-Precedence.html

          ts.next
          prec_seen = true
          precedence_id = ts.consume!(T::Ident, T::String, T::Char)
          precedence_sym = grammar.find_symbol_by_id!(precedence_id)
          a << precedence_sym
        when T::User_code
          # { code } in the middle of rhs

          if prec_seen
            raise "Multiple User_code after %prec" if code_after_prec
            code_after_prec = true
          end

          code = ts.current_token
          grammar.build_references(code)
          a << code
          ts.next
        when T::Bar
          # |
          break
        when T::Semicolon
          # ;
          break
        when T::Ident_Colon
          # Next lhs can be here because ";" is optional.
          break
        when nil
          # end of input can be here when ";" is omitted
          break
        else
          raise "Unexpected token: #{ts.current_token}"
        end
      end

      return a
    end
  end
end
