%{
#include <stdio.h>
int yylex(void);
int yyparse(void);
int yyerror(char *);
extern int yylineno;

%}


%token ASSIGN
%token ASSIGN_PLUS
%token ASSIGN_MINUS

%token CURLY_LEFT
%token CURLY_RIGHT

%token PLUS
%token MINUS
%token MUL
%token DIV
%token MOD

%token EQ
%token NOT_EQ
%token GT
%token LT
%token GTE
%token LTE

%token AND
%token OR
%token NOT

%token IF
%token ELSE
%token WHILE
%token FUNC
%token PRINT

%%
func : FUNC;
%%


int main() {
    yyparse();
}
int yyerror(char *s) {
  fprintf(stderr, "line %d: SYNTAX ERROR %s\n", yylineno, s);
} 
