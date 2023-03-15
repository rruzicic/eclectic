%option noyywrap yylineno
%{
    #include "text.tab.h"
%}

%%

[ \t\n]+      { /* skip */ }

"//"    {printf("COMMENT\n");}

"="     /*{ return ASSIGN; }*/ {printf("ASSIGN\n");}
"+="    /*{ return ASSIGN_PLUS; }*/ {printf("ASSIGN_PLUS\n");}
"-="    /*{ return ASSIGN_MINUS; }*/ {printf("ASSIGN_MINUS\n");}

"{"     /*{ return LEFT_CURLY; }*/
"}"     /*{ return RIGHT_CURLY; }*/

"+"     /*{ return PLUS; }*/ {printf("PLUS\n");}
"-"     /*{ return MINUS; }*/ {printf("MINUS\n");}
"*"     /*{ return MUL; }*/ {printf("MUL\n");}
"/"     /*{ return DIV; }*/ {printf("DIV\n");}
"%"     /*{ return MOD; }*/ {printf("MOD\n");}

"=="    /*{ return EQ; }*/ {printf("EQ\n");}
"!="    /*{ return NOT_EQ; }*/ {printf("NOT_EQ\n");}
">"     /*{ return GT; }*/ {printf("GT\n");}
"<"     /*{ return LT; }*/ {printf("LT\n");}
">="    /*{ return GTE; }*/ {printf("GTE\n");}
"<="    /*{ return LTE; }*/ {printf("LTE\n");}

"and"   /*{ return AND; }*/ {printf("AND\n");}
"or"    /*{ return OR; }*/ {printf("OR\n");}
"!"     /*{ return NOT; }*/ {printf("NOT\n");}

"if"    /*{ return IF; }*/ {printf("IF\n");}
"else"  /*{ return ELSE; }*/ {printf("ELSE\n");}
"while" /*{ return WHILE; }*/ {printf("WHILE\n");}
"func"  /*{ return FUNC; }*/ {printf("FUNC\n"); return FUNC; }
"print" /*{ return PRINT; }*/ {printf("PRINT\n");}

[a-zA-Z][a-zA-Z0-9]{0,30}   {printf("VAR_NAME\n");}

.       { printf("\nlexical error"); }
%%