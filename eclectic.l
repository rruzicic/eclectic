%option noyywrap yylineno
%{
    #include <string.h>
    #include "eclectic.tab.h"
    #include "defs.h"
    extern YYSTYPE yylval;

    void comment(void);
%}

%%

[ \t\n]+                    { /* skip */ }
"/*"			            { comment(); }


"="                         { return ASSIGN; }
"+="                        { return ASSIGN_PLUS; } 
"-="                        { return ASSIGN_MINUS; } 

"{"                         { return LEFT_CURLY; }
"}"                         { return RIGHT_CURLY; }
"("                         { return LEFT_PAREN; }
")"                         { return RIGHT_PAREN; }
","                         { return COMMA; }

"+"                         { return PLUS_OP; } 
"-"                         { return MINUS_OP; } 
"*"                         { return MUL_OP; } 
"/"                         { return DIV_OP; } 
"%"                         { return MOD_OP; } 

"=="                        { return EQ_OP; } 
"!="                        { return NEQ_OP; } 
">"                         { return GT_OP; } 
"<"                         { return LT_OP; } 
">="                        { return GTE_OP; } 
"<="                        { return LTE_OP; } 

"and"                       { return AND_OP; } 
"or"                        { return OR_OP; } 
"!"                         { return NOT_OP; } 


"int"                       { return INT; } 
"bool"                      { return BOOL; } 


"if"                        { return IF; } 
"else"                      { return ELSE; } 
"while"                     { return WHILE; } 
"func"                      { return FUNC; } 
"print"                     { return PRINT; } 
"return"                    { return RETURN;}
"global"                    { return GLOBAL; }

"true"                      { return TRUE_VAL; }
"false"                     { return FALSE_VAL; }

[0-9]{1,20}                 { yylval.s = strdup(yytext); return INT_NUM; }

[a-zA-Z][a-zA-Z0-9]{0,30}   { yylval.s = strdup(yytext); return ID; }

\/\/.*                      { }

.                           { return 1; }
%%

void comment(void) {
	char c, prev = 0;
  
	while ((c = input()) != 0)
	{
		if (c == '/' && prev == '*')
			return;
		prev = c;
	}
	err("unterminated comment");
}