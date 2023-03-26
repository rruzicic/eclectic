%{
#include <stdio.h>
#include <stdlib.h>
#include "symtab.h"
#include "defs.h"
int yylex(void);
int yyparse(void);
int yyerror(char *);
void warning(char *s);

char char_buffer[CHAR_BUFFER_LENGTH];

extern int yylineno;
int err_cnt = 0;
int warn_cnt = 0;


%}

%union {
  int i;
  char *s;
}


%token ASSIGN
%token ASSIGN_PLUS
%token ASSIGN_MINUS

%token LEFT_CURLY
%token RIGHT_CURLY
%token LEFT_PAREN
%token RIGHT_PAREN
%token COMMA

%token PLUS_OP
%token MINUS_OP
%token MUL_OP
%token DIV_OP
%token MOD_OP

%token EQ_OP
%token NEQ_OP
%token GT_OP
%token LT_OP
%token GTE_OP
%token LTE_OP

%token AND_OP
%token OR_OP
%token NOT_OP

%token INT
%token BOOL

%token IF
%token ELSE
%token WHILE
%token FUNC
%token PRINT
%token RETURN
%token GLOBAL

%token TRUE_VAL
%token FALSE_VAL

%token <s> INT_NUM

%token <s> ID

%type <i> literal type



%%

program 
  : global_var_list function_list
  ;

global_var_list
  :
  | global_var_declaration
  | global_var_list global_var_declaration
  ;

global_var_declaration 
  : GLOBAL type ID
  ;

type
  : INT { $$ = INT_TYPE; }
  | BOOL { $$ = BOOL_TYPE; }
  ;

function_list
  : function
  | function_list function
  ;

function
  : FUNC ID LEFT_PAREN function_params RIGHT_PAREN function_return_type LEFT_CURLY statement_list RIGHT_CURLY
  ;

function_params
  :
  | type ID 
  | function_params COMMA type ID 
  ;

function_return_type
  :
  | type
  ;

statement_list
  : 
  | statement_list statement
  ;

statement 
  : var_declaration
  | assign_statement
  | print_statement
  | return_statement
  | function_call
  | if_statement
  | while_statement
  ;

while_statement
  : WHILE expression LEFT_CURLY statement_list RIGHT_CURLY
  ;

if_statement 
  : IF expression LEFT_CURLY statement_list RIGHT_CURLY
  | IF expression LEFT_CURLY statement_list RIGHT_CURLY ELSE LEFT_CURLY statement_list RIGHT_CURLY
  | IF expression LEFT_CURLY statement_list RIGHT_CURLY ELSE if_statement
  ; 

var_declaration
  : type ID {
    if (lookup($2, VAR|PAR|GVAR) == -1) {
      insert_row($2, VAR, $1);
    } else {
      err("variable/parameter with that name already exists");
    }
  }
  | type ID ASSIGN expression {

  }
  ;

assign_statement 
  : ID ASSIGN expression
  ;

print_statement
  : PRINT LEFT_PAREN expression RIGHT_PAREN
  ;

function_call
  : ID LEFT_PAREN function_call_params RIGHT_PAREN
  ;

function_call_params
  :
  | expression
  | function_call_params COMMA expression 
  ;

assignment_operators
  : ASSIGN
  | ASSIGN_PLUS
  | ASSIGN_MINUS
  ;

expression
  : assignment_expression
  ;

assignment_expression 
  : conditional_expression
  | ID assignment_operators assignment_expression
  ;

conditional_expression
  : logical_or_expression
  ;

logical_or_expression 
  : logical_and_expression
  | logical_or_expression OR_OP logical_and_expression
  ;

logical_and_expression 
  : equality_expression
  | logical_and_expression AND_OP equality_expression
  ;

equality_expression
  : unary_expression
  | equality_expression EQ_OP unary_expression
  | equality_expression NEQ_OP unary_expression
  ;

unary_expression
  : relational_expression
  | NOT_OP relational_expression 
  ;

relational_expression
  : additive_expression
  | relational_expression LT_OP additive_expression
  | relational_expression GT_OP additive_expression
  | relational_expression LTE_OP additive_expression
  | relational_expression GTE_OP additive_expression
  ;

additive_expression
  : multiplicative_expression
  | additive_expression PLUS_OP multiplicative_expression
  | additive_expression MINUS_OP multiplicative_expression
  ;

multiplicative_expression
  : primary_expression
  | multiplicative_expression MUL_OP primary_expression
  | multiplicative_expression DIV_OP primary_expression
  | multiplicative_expression MOD_OP primary_expression
  ;

primary_expression
  : ID {

  }
  | literal {

  }
  | function_call
  | LEFT_PAREN expression RIGHT_PAREN
  ;

literal  
  : INT_NUM {
    $$ = 1;
  }
  | boolean_literal {
    $$ = 2;
  }
  ;

boolean_literal
  : TRUE_VAL
  | FALSE_VAL
  ;  

return_statement
  : RETURN expression 
  ;

%%


int main() {
  init_symtab();
  //TODO: different returns based on warn or err count
  return yyparse();
}
int yyerror(char *s) {
  fprintf(stderr, "\nline %d: ERROR: %s\n", yylineno, s);
  return 0;
}

void warning(char *s) {
  fprintf(stderr, "\nline %d: WARNING: %s", yylineno, s);
  warn_cnt++;
}
