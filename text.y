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
int function_idx = -1;


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
%type <i> function_call

%type <i> expression assignment_expression conditional_expression logical_or_expression logical_and_expression
%type <i> equality_expression unary_expression relational_expression additive_expression multiplicative_expression primary_expression

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
  : GLOBAL type ID {
    if (lookup($3, GVAR) == -1) {
      insert_row($3, GVAR, $2);
    } else {
      err("redefinition of global variable %s", $3);
    }
  }
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
  : FUNC ID {
    if (lookup($2, FUNC_KIND) == -1) {
      function_idx = insert_row($2, FUNC_KIND, INT_TYPE);
    }
    else {
      err("function %s already declared", $2);
    }
  }
  LEFT_PAREN function_params RIGHT_PAREN function_return_type LEFT_CURLY statement_list RIGHT_CURLY
  {
    clear_symbols(function_idx + 1);
  }
  ;

function_params
  :
  | type ID {
    if (lookup($2, PAR) == -1) {
      insert_row($2, PAR, $1);
    }
    else {
      err("redefinition of parameter %s", $2);
    }
  }
  | function_params COMMA type ID {
    if (lookup($4, PAR) == -1) {
      insert_row($4, PAR, $3);
    }
    else {
      err("redefinition of parameter %s", $4);
    }
  }
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
    if ($1 != $4) {
      err("could not assign expression to variable, mismatched types");
    } else if (lookup($2, VAR|PAR|GVAR) == -1) {
      insert_row($2, VAR, $1);
    } else {
      err("variable/parameter with that name already exists");
    }
  }
  ;

assign_statement 
  : ID ASSIGN expression { 
    int idx = lookup($1, VAR|PAR);
    if (idx == -1) {
      err("use of undeclared variable %s", $1);
    } else {
      unsigned type = get_type(idx);
      if (type != $3) {
        err("could not asssign expression to a variable, mismatched types");
      } else {
        // codegen
      }
    }
   }
  ;

print_statement
  : PRINT LEFT_PAREN expression RIGHT_PAREN
  ;

function_call
  : ID LEFT_PAREN function_call_params RIGHT_PAREN {
    $$ = lookup($1, FUNC_KIND); 
    if ($$ == -1) {
      err("call to undefined function %s", $1);
    }
  }
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
  : assignment_expression { $$ = $1; }
  ;

assignment_expression 
  : conditional_expression { $$ = $1; }
  | ID assignment_operators assignment_expression { $$ = $3; }
  ;

conditional_expression
  : logical_or_expression { $$ = $1; }
  ;

logical_or_expression 
  : logical_and_expression { $$ = $1; }
  | logical_or_expression OR_OP logical_and_expression // check types
  ;

logical_and_expression 
  : equality_expression { $$ = $1; }
  | logical_and_expression AND_OP equality_expression // check types
  ;

equality_expression
  : unary_expression { $$ = $1; }
  | equality_expression EQ_OP unary_expression // check types
  | equality_expression NEQ_OP unary_expression
  ;

unary_expression
  : relational_expression { $$ = $1; }
  | NOT_OP relational_expression { $$ = $2; } // check types
  ;

relational_expression
  : additive_expression { $$ = $1; }
  | relational_expression LT_OP additive_expression 
  | relational_expression GT_OP additive_expression
  | relational_expression LTE_OP additive_expression
  | relational_expression GTE_OP additive_expression
  ;

additive_expression
  : multiplicative_expression { $$ = $1; }
  | additive_expression PLUS_OP multiplicative_expression
  | additive_expression MINUS_OP multiplicative_expression
  ;

multiplicative_expression
  : primary_expression { $$ = $1; }
  | multiplicative_expression multiplicative_operator primary_expression {
    if ($1 == $3) {
      $$ = $1;
    } else {
      err("unsupported operation between two types");
    }
  }
  ;

multiplicative_operator 
  : MUL_OP
  | DIV_OP
  | MOD_OP
  ;  

primary_expression
  : ID {
    int idx = lookup($1, VAR|PAR|GVAR);
    if (idx == -1) {
      err("use of undefined variable %s", $1);
    }
    else {
      $$ = get_type(idx);
    }
  }
  | literal {
    $$ = $1;
  }
  | function_call {
    int idx = $1;
    if (idx == -1) {
      err("call of undefined function %s", get_name($1));
    }
    else {
      $$ = get_type(idx);
    }
  }
  | LEFT_PAREN expression RIGHT_PAREN {
    $$ = $2;
  }
  ;

literal  
  : INT_NUM {
    $$ = INT_TYPE;
  }
  | boolean_literal {
    $$ = BOOL_TYPE;
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
  int ret_val = yyparse();

  if (err_cnt != 0) {
    return 1;
  } else if (warn_cnt != 0) {
    return 2;
  } else {
    return ret_val;
  }
}
int yyerror(char *s) {
  fprintf(stderr, "\nline %d: ERROR: %s\n", yylineno, s);
  return 0;
}

void warning(char *s) {
  fprintf(stderr, "\nline %d: WARNING: %s", yylineno, s);
  warn_cnt++;
}
