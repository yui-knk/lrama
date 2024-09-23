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


#define YYFLAG      -1000
#define yyclearin   yychar = -1
#define yyerrok     yyerrflag = 0

#ifdef  yydebug
#include    "y.debug"
#else
#define yydebug     0
char*   yytoknames[1];      /* for debugging */
char*   yystates[1];        /* for debugging */
#endif

/*  parser for yacc output  */

int yynerrs = 0;        /* number of errors */
int yyerrflag = 0;      /* error recovery flag */

extern  int fprint(int, char*, ...);
extern  int sprint(char*, char*, ...);

char*
yytokname(int yyc)
{
    static char x[16];

    if (yyc > 0 && yyc <= sizeof(yytoknames) / sizeof(yytoknames[0]))
    if (yytoknames[yyc-1])
        return yytoknames[yyc-1];
    sprint(x, "<%d>", yyc);
    return x;
}

char*
yystatname(int yys)
{
    static char x[16];

    if (yys >= 0 && yys < sizeof(yystates) / sizeof(yystates[0]))
    if (yystates[yys])
        return yystates[yys];
    sprint(x, "<%d>\n", yys);
    return x;
}

long
yylex1(void)
{
    long yychar;
    long *t3p;
    int c;

    yychar = yylex();
    if (yychar <= 0) {
        c = yytok1[0];
        goto out;
    }
    if (yychar < sizeof(yytok1) / sizeof(yytok1[0])) {
        c = yytok1[yychar];
        goto out;
    }
    if (yychar >= YYPRIVATE)
        if (yychar < YYPRIVATE + sizeof(yytok2) / sizeof(yytok2[0])) {
            c = yytok2[yychar-YYPRIVATE];
            goto out;
        }
    for (t3p = yytok3;; t3p+=2) {
        c = t3p[0];
        if (c == yychar) {
            c = t3p[1];
            goto out;
        }
        if (c == 0)
            break;
    }
    c = 0;

out:
    if (c == 0)
        c = yytok2[1];  /* unknown char */
    if (yydebug >= 3)
        fprint(2, "lex %.4lux %s\n", yychar, yytokname(c));
    return c;
}

int
yyparse(void)
{
    struct
    {
        YYSTYPE yyv;
        int yys;
    } yys[YYMAXDEPTH], *yyp, *yypt;
    short *yyxi;
    int yyj, yym, yystate, yyn, yyg;
    long yychar;
    YYSTYPE save1, save2;
    int save3, save4;

    save1 = yylval;
    save2 = yyval;
    save3 = yynerrs;
    save4 = yyerrflag;

    yystate = 0;
    yychar = -1;
    yynerrs = 0;
    yyerrflag = 0;
    yyp = &yys[-1];
    goto yystack;

ret0:
    yyn = 0;
    goto ret;

ret1:
    yyn = 1;
    goto ret;

ret:
    yylval = save1;
    yyval = save2;
    yynerrs = save3;
    yyerrflag = save4;
    return yyn;

yystack:
    /* put a state and value onto the stack */
    if (yydebug >= 4)
        fprint(2, "char %s in %s", yytokname(yychar), yystatname(yystate));

    yyp++;
    if (yyp >= &yys[YYMAXDEPTH]) {
        yyerror("yacc stack overflow");
        goto ret1;
    }
    yyp->yys = yystate;
    yyp->yyv = yyval;

yynewstate:
    yyn = yypact[yystate];
    if (yyn <= YYFLAG)
        goto yydefault; /* simple state */
    if (yychar < 0)
        yychar = yylex1();
    yyn += yychar;
    if (yyn < 0 || yyn >= YYLAST)
        goto yydefault;
    yyn = yyact[yyn];
    if (yychk[yyn] == yychar) { /* valid shift */
        yychar = -1;
        yyval = yylval;
        yystate = yyn;
        if (yyerrflag > 0)
            yyerrflag--;
        goto yystack;
    }

yydefault:
    /* default state action */
    yyn = yydef[yystate];
    if (yyn == -2) {
        if (yychar < 0)
            yychar = yylex1();

        /* look through exception table */
        for (yyxi = yyexca;; yyxi+=2)
            if (yyxi[0] == -1 && yyxi[1] == yystate)
                break;
        for (yyxi += 2;; yyxi += 2) {
            yyn = yyxi[0];
            if (yyn < 0 || yyn == yychar)
                break;
        }
        yyn = yyxi[1];
        if (yyn < 0)
            goto ret0;
    }
    if (yyn == 0) {
        /* error ... attempt to resume parsing */
        switch (yyerrflag) {
          case 0:   /* brand new error */
            yyerror("syntax error");
            yynerrs++;
            if (yydebug >= 1) {
                fprint(2, "%s", yystatname(yystate));
                fprint(2, "saw %s\n", yytokname(yychar));
            }

          case 1:
          case 2: /* incompletely recovered error ... try again */
            yyerrflag = 3;

            /* find a state where "error" is a legal shift action */
            while (yyp >= yys) {
                yyn = yypact[yyp->yys] + YYERRCODE;
                if (yyn >= 0 && yyn < YYLAST) {
                    yystate = yyact[yyn];  /* simulate a shift of "error" */
                    if (yychk[yystate] == YYERRCODE)
                        goto yystack;
                }

                /* the current yyp has no shift onn "error", pop stack */
                if (yydebug >= 2)
                    fprint(2, "error recovery pops state %d, uncovers %d\n",
                        yyp->yys, (yyp-1)->yys );
                yyp--;
            }
            /* there is no state on the stack with an error shift ... abort */
            goto ret1;

          case 3:  /* no shift yet; clobber input char */
            if (yydebug >= 2)
                fprint(2, "error recovery discards %s\n", yytokname(yychar));
            if (yychar == YYEOFCODE)
                goto ret1;
            yychar = -1;
            goto yynewstate;   /* try again in the same state */
        }
    }

    /* reduction by production yyn */
    if (yydebug >= 2)
        fprint(2, "reduce %d in:\n\t%s", yyn, yystatname(yystate));

    yypt = yyp;
    yyp -= yyr2[yyn];
    yyval = (yyp+1)->yyv;
    yym = yyn;

    /* consult goto table to find next state */
    yyn = yyr1[yyn];
    yyg = yypgo[yyn];
    yyj = yyg + yyp->yys + 1;

    if (yyj >= YYLAST || yychk[yystate=yyact[yyj]] != -yyn)
        yystate = yyact[yyg];
    switch (yym) {
        $A
    }
    goto yystack;  /* stack new state and value */
}
