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

%token IF
%token ELSE
%token WHILE
%token FUNC
%token PRINT
%token RETURN
%token GLOBAL

%token INT_NUM

%token ID



%%

program 
  : global_var_list function_list
  ;

global_var_list
  :
  | global_var_declaration
  | global_var_list global_var_declaration
  ;

global_var_declaration :
  GLOBAL type ID
  ;

type
  : INT
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
  //| while_statement
  ;

if_statement 
  : IF expression LEFT_CURLY statement_list RIGHT_CURLY
  | IF expression LEFT_CURLY statement_list RIGHT_CURLY ELSE LEFT_CURLY statement_list RIGHT_CURLY
  | IF expression LEFT_CURLY statement_list RIGHT_CURLY ELSE if_statement
  ; 

var_declaration
  : type ID
  | type ID ASSIGN expression
  // inference goes here
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

expression
  : assignment_expression
  ;

assignment_expression 
  : conditional_expression
  | ID ASSIGN assignment_expression
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
  : relational_expression
  | equality_expression EQ_OP relational_expression
  | equality_expression NEQ_OP relational_expression
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
  : ID
  | literal
  | function_call
  | LEFT_PAREN expression RIGHT_PAREN
  ;

literal  
  : INT_NUM
  ;

return_statement
  : RETURN expression 
  ;

%%


int main() {
  //TODO: different returns based on warn or err count
  return yyparse();
}
int yyerror(char *s) {
  fprintf(stderr, "\nline %d: ERROR: %s\n", yylineno, s);
  return 0;
}

