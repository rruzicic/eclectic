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
int function_param_idx = -1;
int function_call_param_idx = -1;
int function_call_idx = -1;

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
    function_param_idx = 0;
    if (lookup($2, FUNC_KIND) == -1) {
      function_idx = insert_row($2, FUNC_KIND, INT_TYPE);
    }
    else {
      err("function %s already declared", $2);
    }
  }
  LEFT_PAREN function_params RIGHT_PAREN function_return_type LEFT_CURLY statement_list RIGHT_CURLY
  {
    int func_param_num = get_func_param_num(function_idx);
    clear_symbols(function_idx + func_param_num + 1);
  }
  ;

function_params
  :
  | type ID {
    if (lookup_function_definiton_param($2, function_idx) == -1) {
      insert_function_param($2, $1, function_idx, function_param_idx);
    }
    else {
      err("redefinition of parameter %s", $2);
    }
    function_param_idx++;
  }
  | function_params COMMA type ID {
    if (lookup_function_definiton_param($4, function_idx) == -1) {
      insert_function_param($4, $3, function_idx, function_param_idx);
    }
    else {
      err("redefinition of parameter %s", $4);
    }
    function_param_idx++;
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
    print_table();
    if (lookup_variable_declaration($2, function_idx) == -1) {
      insert_var($2, $1, function_idx);
    } else {
      err("variable/parameter with that name already exists");
    }
  }
  | type ID ASSIGN expression {
    print_table();
    if ($1 != $4) {
      err("could not assign expression to variable, mismatched types");
    } else if (lookup_variable_declaration($2, function_idx) == -1) {
      insert_var($2, $1, function_idx);
    } else {
      err("variable/parameter with that name already exists");
    }
  }
  ;

assign_statement 
  : ID assignment_operators expression { 
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
  : ID LEFT_PAREN { 
    function_call_param_idx = 0;
    function_call_idx = lookup($1, FUNC_KIND);
   } function_call_params RIGHT_PAREN {
    $$ = lookup($1, FUNC_KIND); 
    if ($$ == -1) {
      err("call to undefined function %s", $1);
    }
  }
  ;

function_call_params
  :
  | expression {
    int idx = lookup_function_call_param(function_call_idx, function_call_param_idx);
    if (idx == -1) {
      err("function does not have param with that index(function_call_idx=%d, function_param_idx=%d)", 
      function_call_idx, 
      function_param_idx);
    }
    else if (get_type(idx) != $1) {
      printf("%d\n", $1);
      err("mismatched param type in call to function");
    }
    else {
      // codegen
    }
    function_call_param_idx++;
  }
  | function_call_params COMMA expression {
    int idx = lookup_function_call_param(function_call_idx, function_call_param_idx);
    if (idx == -1) {
      err("function does not have param with that index(function_call_idx=%d, function_param_idx=%d)", 
      function_call_idx, 
      function_param_idx);
    }
    else if (get_type(idx) != $3) {
      err("mismatched param type in call to function");
    }
    else {
      // codegen
    }
    function_call_param_idx++;
  }
  ;

expression
  : assignment_expression { $$ = $1; }
  ;

assignment_expression 
  : conditional_expression { $$ = $1; }
  //| ID assignment_operators assignment_expression { $$ = $3; }
  ;

assignment_operators
  : ASSIGN
  | ASSIGN_PLUS
  | ASSIGN_MINUS
  ;

conditional_expression
  : logical_or_expression { $$ = $1; }
  ;

logical_or_expression 
  : logical_and_expression { $$ = $1; }
  | logical_or_expression OR_OP logical_and_expression {
    if ($1 == BOOL_TYPE && $1 == $3) {
      // TODO: codegen
      $$ = $1;
    } else {
      err("could not apply || operator to given operands");
    }
  }
  ;

logical_and_expression 
  : equality_expression { $$ = $1; }
  | logical_and_expression AND_OP equality_expression {
    if ($1 == BOOL_TYPE && $1 == $3) {
      // TODO: codegen
      $$ = $1;
    } else {
      err("could not apply && operator to given operands");
    }
  }
  ;

equality_expression
  : unary_expression { $$ = $1; }
  | equality_expression equality_operator unary_expression {
    if ($1 != $3) {
      err("could not apply == != operator to given operands");
    } else {
      // TODO: codegen
      $$ = BOOL_TYPE;
    }
  }
  ;

equality_operator
  : EQ_OP
  | NEQ_OP
  ;

unary_expression
  : relational_expression { $$ = $1; }
  | NOT_OP relational_expression { 
    if ($2 != BOOL_TYPE) {
      err("could not apply ! operator to given operand");
    } else {
      // TODO: codegen
      $$ = BOOL_TYPE;
    }
   }
  ;

relational_expression
  : additive_expression { $$ = $1; }
  | relational_expression relational_operator additive_expression { 
    if ($1 != $3 || $1 == BOOL_TYPE || $3 == BOOL_TYPE) {
      err("could not apply > >= < <= operator to given operands");
    } else {
      // TODO: codegen
      $$ = BOOL_TYPE;
    }
   }
  ;

relational_operator
  : LT_OP
  | GT_OP
  | LTE_OP
  | GTE_OP
  ;

additive_expression
  : multiplicative_expression { $$ = $1; }
  | additive_expression additive_operator multiplicative_expression {
    if ($1 != $3) {
      err("could not apply + - operator to given operands");
    } else {
      // TODO: codegen
      $$ = $1;
    }
  }
  ;

additive_operator
  : PLUS_OP
  | MINUS_OP
  ;

multiplicative_expression
  : primary_expression { $$ = $1; }
  | multiplicative_expression multiplicative_operator primary_expression {
    if ($1 == $3) {
      $$ = $1;
    } else {
      err("could not apply * / %% operator to given operands");
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
