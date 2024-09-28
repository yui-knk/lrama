/*
Derived from Inferno's utils/iyacc/yaccpar
https://bitbucket.org/inferno-os/inferno-os/src/18eb7a2d4ffc48d0a90687ace604e4e388440626/utils/iyacc/yaccpar

This copyright NOTICE applies to all files in this directory and
subdirectories, unless another copyright notice appears in a given
file or subdirectory.  If you take substantial code from this software to use in
other programs, you must somehow include with it an appropriate
copyright notice that includes the copyright notice and the other
notices below.  It is fine (and often tidier) to do that in a separate
file such as NOTICE, LICENCE or COPYING.

    Copyright © 1994-1999 Lucent Technologies Inc
    Portions Copyright © 1995-1997 C H Forsyth (charles.forsyth@gmail.com)
    Portions Copyright © 1997-1999 Vita Nuova Limited
    Portions Copyright © 2000-2008 Vita Nuova Holdings Limited (www.vitanuova.com)
    Portions Copyright © 2004,2006 Bruce Ellis
    Portions Copyright © 2005-2007 C H Forsyth (charles.forsyth@gmail.com)
    Revisions Copyright © 2000-2008 Lucent Technologies Inc. and others
    Portions Copyright © 2009 The Go Authors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

<%- if output.aux.prologue -%>
#line <%= output.aux.prologue_first_lineno %> "<%= output.grammar_file_path %>"
<%= output.aux.prologue %>
#line [@oline@] [@ofile@]
<%- end -%>

#ifndef YY_NULLPTR
#define YY_NULLPTR NULL
#endif

#if !defined YYSTYPE && !defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE {
#line <%= output.grammar.union.lineno %> "<%= output.grammar_file_path %>"
<%= output.grammar.union.braces_less_code %>
#line [@oline@] [@ofile@]
} YYSTYPE;

#define YYSTYPE_IS_DECLARED 1
#endif

#if !defined YYLTYPE && !defined YYLTYPE_IS_DECLARED
typedef struct YYLTYPE {
    int first_line;
    int first_column;
    int last_line;
    int last_column;
} YYLTYPE;

#define YYLTYPE_IS_DECLARED 1
#endif

#include <assert.h>

enum yysymbol_kind_t {
<%= output.symbol_enum %>
};
typedef enum yysymbol_kind_t yysymbol_kind_t;

#define YYFLAG      -1000
#define yyclearin   yychar = -1
#define yyerrok     yyerrflag = 0

#ifndef YYMAXDEPTH
#define YYMAXDEPTH 200
#endif

#ifdef  yydebug
#include    "y.debug"
#else
#define yydebug     0
#endif

static const char *const yytname[] = {
<%= output.yytname %>
};

typedef int yytype_int8;
typedef unsigned int yytype_uint8;
typedef int yytype_int16;
typedef unsigned int yytype_uint16;

#define YYFINAL <%= output.yyfinal %>
#define YYLAST <%= output.yylast %>
#define YYNTOKENS <%= output.yyntokens %>

#define YYPACT_NINF <%= output.yypact_ninf %>
#define YYTABLE_NINF <%= output.yytable_ninf %>

#define YYMAXUTOK <%= output.yymaxutok %>
#define YYTRANSLATE(yytoken) \
  ((0 <= (yytoken) && (yytoken) <= YYMAXUTOK) ? ((yysymbol_kind_t) yytranslate[yytoken]) : (YYSYMBOL_YYUNDEF))

static const <%= output.int_type_for(output.context.yytranslate) %> yytranslate[] = {
<%= output.int_array_to_string(output.context.yytranslate) %>
};

static const <%= output.int_type_for(output.context.yypact) %> yypact[] = {
<%= output.int_array_to_string(output.context.yypact) %>
};

static const <%= output.int_type_for(output.context.yydefact) %> yydefact[] = {
<%= output.int_array_to_string(output.context.yydefact) %>
};

static const <%= output.int_type_for(output.context.yypgoto) %> yypgoto[] = {
<%= output.int_array_to_string(output.context.yypgoto) %>
};

static const <%= output.int_type_for(output.context.yydefgoto) %> yydefgoto[] = {
<%= output.int_array_to_string(output.context.yydefgoto) %>
};

static const <%= output.int_type_for(output.context.yytable) %> yytable[] = {
<%= output.int_array_to_string(output.context.yytable) %>
};

static const <%= output.int_type_for(output.context.yycheck) %> yycheck[] = {
<%= output.int_array_to_string(output.context.yycheck) %>
};

static const <%= output.int_type_for(output.context.yyr1) %> yyr1[] = {
<%= output.int_array_to_string(output.context.yyr1) %>
};

static const <%= output.int_type_for(output.context.yyr2) %> yyr2[] = {
<%= output.int_array_to_string(output.context.yyr2) %>
};


#define yyunreachable() assert(0 && "unreachable")

/*  parser for yacc output  */

int yynerrs = 0;        /* number of errors */
int yyerrflag = 0;      /* error recovery flag */

extern  int fprint(int, char*, ...);

static const char *
yysymbolname(yysymbol_kind_t yysymbol)
{
    return yytname[yysymbol];
}

int
yyparse(void)
{
    struct
    {
        YYSTYPE yyv;
        int yys;
    } yys[YYMAXDEPTH], *yyp;
    int yystate, yyn;
    long yychar;

    int yyrule;
    yysymbol_kind_t yytoken = YYSYMBOL_YYEMPTY;
    YYSTYPE yylval;
    YYSTYPE yyval;
    YYLTYPE yylloc;
    YYLTYPE yyloc;

    yystate = 0;
    yychar = -1;
    yynerrs = 0;
    yyerrflag = 0;
    yyp = &yys[-1];
    goto yystack;

ret0:
    {
        yyn = 0;
        goto ret;
    }

ret1:
    {
        yyn = 1;
        goto ret;
    }

ret:
    {
        return yyn;
    }

yystack:
    {
        /* put a state and value onto the stack */
        if (yydebug >= 4)
            fprint(1, "char %s", yysymbolname(yytoken));

        yyp++;
        if (yyp >= &yys[YYMAXDEPTH]) {
            yyerror(<%= output.yyerror_args %>, "yacc stack overflow");
            goto ret1;
        }
        yyp->yys = yystate;
        yyp->yyv = yyval;

        if (yystate == YYFINAL) {
            goto ret0;
        }
    }
    /* fall through */

yynewstate:
    {
        int yyoffset, yyindex, yyaction;

        yyoffset = yypact[yystate];
        if (yyoffset == YYPACT_NINF) {
            goto yydefault;
        }

        if (yychar < 0) {
            yychar = yylex <%= output.yylex_formals %>;
        }
        if (yychar == <%= output.error_symbol.id.s_value %>) {
            yychar = <%= output.undef_symbol.id.s_value %>;
            yytoken = <%= output.error_symbol.enum_name %>;
            goto ret1;
        }

        yytoken = YYTRANSLATE(yychar);

        yyindex = yyoffset + yytoken;
        if (yyindex < 0 || YYLAST < yyindex) {
            goto yydefault;
        }
        if (yycheck[yyindex] != yytoken) {
            goto yydefault;
        }

        yyaction = yytable[yyindex];
        if (yyaction == YYTABLE_NINF) {
            goto ret1;
        }
        if (yyaction > 0) {
            /* Shift */
            yychar = -1;
            yyval = yylval;
            yystate = yyaction;
            goto yystack;
        }
        else {
            /* Reduce */
            yyrule = -yyaction;
            goto yyreduce;
        }
    }
    yyunreachable();

yydefault:
    {
        /* default state action */
        yyrule = yydefact[yystate];
        if (yyrule == 0) {
            goto ret1;
        }
    }
    /* fall through */

yyreduce:
    /* reduction by yyrule */
    {
        int yyoffset, yyindex;
        int yy_lhs_nterm, yy_rhs_len;

        if (yydebug >= 2)
            fprint(1, "reduce %d\t%s", yyn);

        yy_lhs_nterm = yyr1[yyrule] - YYNTOKENS;
        yy_rhs_len = yyr2[yyrule];

        /* Set `$1` to `$$` (`yyval`) as default value before calling semantic action */
        yyval = yyp[-yy_rhs_len + 1].yyv;

        /*
         * `$$` is expanded to `yyval`
         * `$n` is expanded to `yyvsp[-i]`
         */
        switch (yyrule) {
            // $A
        }

        // stack pop by yy_rhs_len
        yyp -= yy_rhs_len;

        yyoffset = yypgoto[yy_lhs_nterm];
        if (yyoffset == YYPACT_NINF) {
            yystate = yydefgoto[yy_lhs_nterm];
        }
        else {
            yyindex = yyoffset + yystate;
            if (yyindex < 0 || YYLAST < yyindex) {
                yystate = yydefgoto[yy_lhs_nterm];
            }
            else if (yycheck[yyindex] != yystate) {
                yystate = yydefgoto[yy_lhs_nterm];
            }
            else {
                yystate = yytable[yyindex];
            }
        }

        goto yystack;  /* stack new state and value */
    }
    yyunreachable();
}

<%- if output.aux.epilogue -%>
#line <%= output.aux.epilogue_first_lineno %> "<%= output.grammar_file_path %>"
<%= output.aux.epilogue %>
#line [@oline@] [@ofile@]
<%- end -%>
