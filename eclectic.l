%option noyywrap yylineno
%{
    #include <string.h>
    #include "eclectic.tab.h"
    extern YYSTYPE yylval;
%}

%%

[ \t\n]+                    { /* skip */ }


"="                         { printf("ASSIGN\n"); return ASSIGN; }
"+="                        { printf("ASSIGN_PLUS\n"); return ASSIGN_PLUS; } 
"-="                        { printf("ASSIGN_MINUS\n"); return ASSIGN_MINUS; } 

"{"                         { printf("LEFT_CURLY\n"); return LEFT_CURLY; }
"}"                         { printf("RIGHT_CURLY\n"); return RIGHT_CURLY; }
"("                         { printf("LEFT_PAREN\n"); return LEFT_PAREN; }
")"                         { printf("RIGHT_PAREN\n"); return RIGHT_PAREN; }
","                         { printf("COMMA\n"); return COMMA; }

"+"                         { printf("PLUS_OP\n"); return PLUS_OP; } 
"-"                         { printf("MINUS_OP\n"); return MINUS_OP; } 
"*"                         { printf("MUL_OP\n"); return MUL_OP; } 
"/"                         { printf("DIV_OP\n"); return DIV_OP; } 
"%"                         { printf("MOD_OP\n"); return MOD_OP; } 

"=="                        { printf("EQ_OP\n"); return EQ_OP; } 
"!="                        { printf("NEQ_OP\n"); return NEQ_OP; } 
">"                         { printf("GT_OP\n"); return GT_OP; } 
"<"                         { printf("LT_OP\n"); return LT_OP; } 
">="                        { printf("GTE_OP\n"); return GTE_OP; } 
"<="                        { printf("LTE_OP\n"); return LTE_OP; } 

"and"                       { printf("BITWISE_OP\n"); return AND_OP; } 
"or"                        { printf("BITWISE_OP\n"); return OR_OP; } 
"!"                         { printf("NOT\n"); return NOT_OP; } 


"int"                       { printf("INT\n"); return INT; } 
"bool"                      { printf("BOOL\n"); return BOOL; } 


"if"                        { printf("IF\n"); return IF; } 
"else"                      { printf("ELSE\n"); return ELSE; } 
"while"                     { printf("WHILE\n"); return WHILE; } 
"func"                      { printf("FUNC\n"); return FUNC; } 
"print"                     { printf("PRINT\n"); return PRINT; } 
"return"                    { printf("RETURN\n"); return RETURN;}
"global"                    { printf("GLOBAL\n"); return GLOBAL; }

"true"                      { printf("TRUE_VAL\n"); return TRUE_VAL; }
"false"                     { printf("FALSE_VAL\n"); return FALSE_VAL; }

[0-9]{1,20}                 { yylval.s = strdup(yytext); printf("INT_NUM\n"); return INT_NUM; }

[a-zA-Z][a-zA-Z0-9]{0,30}   { yylval.s = strdup(yytext); printf("ID\n"); return ID; }

\/\/.*                      { printf("COMMENT\n"); }

.                           { printf("\nlexical error"); return 1; }
%%