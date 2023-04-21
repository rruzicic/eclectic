%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"
#include "defs.h"
#include "codegen.h"

int yylex(void);
int yyparse(void);
int yyerror(char *);
void warning(char *s);
int out_lin = 0;
FILE *output;

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

%type <i> expression logical_or_expression logical_and_expression
%type <i> equality_expression unary_expression relational_expression additive_expression multiplicative_expression primary_expression

%type <s> additive_operator relational_operator multiplicative_operator equality_operator 
%type <i> assignment_operators
%%

program 
  : { 
      code("(module \n\t(import \"console\" \"log_number\" (func $log_number (param i32)))"); 
      code("\n\t(import \"console\" \"log_bool\" (func $log_bool (param i32)))");
      code("\n\t(import \"console\" \"log_string\" (func $log_string (param i32)))");

    }
    global_var_list function_list { 
    int idx = lookup("main", FUNC_KIND); 
    if (idx == -1) { 
      err("main function does not exist"); 
    } else if (get_type(idx) != VOID_TYPE) {
      err("main function is not of type void"); 
    } else if (get_func_param_num(idx) != 0) {
      err("main function has too many params: max 0"); 
    }
    code("\n)");
  }
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
  : FUNC ID 
  {
    function_param_idx = 0;
    if (lookup($2, FUNC_KIND) == -1) {
      function_idx = insert_row($2, FUNC_KIND, VOID_TYPE);
      if (strcmp($2, "main") == 0) {
        code("\n\t(func (export \"main\")");
      }
      else {
        code("\n\t(func $%s", $2);
      }
    }
    else {
      err("function %s already declared", $2);
    }
  }
  LEFT_PAREN function_params RIGHT_PAREN function_return_type LEFT_CURLY statement_list RIGHT_CURLY
  {
    code("\n\t%s", get_wasm_function_implicit_return(get_type(function_idx)));
    int func_param_num = get_func_param_num(function_idx);
    clear_symbols(function_idx + func_param_num + 1);
    code(")");
  }
  ;

function_params
  :
  | type ID 
  {
    if (lookup_function_definiton_param($2, function_idx) == -1) {
      insert_function_param($2, $1, function_idx, function_param_idx);
      code(" (param $%s %s) ", $2, get_wasm_type($1));
    }
    else {
      err("redefinition of parameter %s", $2);
    }
    function_param_idx++;
  }
  | function_params COMMA type ID 
  {
    if (lookup_function_definiton_param($4, function_idx) == -1) {
      insert_function_param($4, $3, function_idx, function_param_idx);
      code(" (param $%s %s) ", $4, get_wasm_type($3));
    }
    else {
      err("redefinition of parameter %s", $4);
    }
    function_param_idx++;
  }
  ;

function_return_type
  : { code("\n\t;; LOCAL VARIABLES: function_idx=%d\n", function_idx); }
  | type { 
    set_type(function_idx, $1); 
    code(" (result %s)", get_wasm_type($1));
    code("\n\t;; LOCAL VARIABLES: function_idx=%d\n", function_idx);
  }
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
  : WHILE expression LEFT_CURLY statement_list RIGHT_CURLY { 
    if ($2 != BOOL_TYPE) {
      err("while condition expression must be of type bool");
    }
    else {
      // codegen
    }
  }
  ;

if_statement 
  : if_part { code("\n\t)"); }
  | if_part ELSE 
  {
    code("\n\t(else");  
  } 
  LEFT_CURLY statement_list RIGHT_CURLY
  {
    code("\n\t)"); 
    code("\n\t)"); 
  }
  | if_part ELSE 
  {
    code("\n\t(else");  
  }
  if_statement 
  { 
    code("\n\t)"); 
    code("\n\t)"); 
  }
  ; 

if_part
  : IF expression LEFT_CURLY 
  {
    if ($2 != BOOL_TYPE) {
      err("if condition expression must be of type bool");
    }
    else {
      code("\n\t(if");
      code("\n\t(then");  
    }
  }
  statement_list RIGHT_CURLY 
  { 
    code("\n\t)");
  }
  ;

var_declaration
  : type ID 
  {
    if (lookup_variable_declaration($2, function_idx) == -1) {
      insert_var($2, $1, function_idx);
      append_local_variable(function_idx, output, INT_TYPE, $2);
      
    } else {
      err("variable/parameter with that name already exists");
    }
  }
  | type ID 
  { 
    append_local_variable(function_idx, output, $1, $2); 
  } 
  ASSIGN expression 
  {
    if ($1 != $5) {
      err("could not assign expression to variable, mismatched types");
    } else if (lookup_variable_declaration($2, function_idx) == -1) {
      insert_var($2, $1, function_idx);
      code("\n\t(local.set $%s)", $2);
    } else {
      err("variable/parameter with that name already exists");
    }
  }
  ;

assign_statement 
  : ID assignment_operators
  {
    switch($2) {
      case 0:
      break;
      case 1:
        code("\n\t(local.get $%s)", $1);
      break;
      case 2:
        code("\n\t(local.get $%s)", $1);
      break;
    }
  }
  expression 
  { 
    int idx = lookup($1, VAR|PAR);
    if (idx == -1) {
      err("use of undeclared variable %s", $1);
    } else {
      unsigned type = get_type(idx);
      if (type != $4) {
        err("could not asssign expression to a variable, mismatched types");
      } else {
        switch($2) {
          case 0:
            code("\n\t(local.set $%s)", $1);
          break;
          case 1:
            code("\n\t%s.add", get_wasm_type(type));
            code("\n\t(local.set $%s)", $1);
          break;
          case 2:
            code("\n\t%s.sub", get_wasm_type(type));
            code("\n\t(local.set $%s)", $1);
          break;
        }
      }
    }
  }
  ;

assignment_operators
  : ASSIGN { $$ = 0; }
  | ASSIGN_PLUS { $$ = 1; }
  | ASSIGN_MINUS { $$ = 2; }
  ;

print_statement
  : PRINT LEFT_PAREN expression RIGHT_PAREN 
  {
    if ($3 == INT_TYPE) {
      code("\n\tcall $log_number");
    }
    else if ($3 == BOOL_TYPE) {
      code("\n\tcall $log_bool");
    }
  }
  ;

function_call
  : ID LEFT_PAREN 
  { 
    function_call_param_idx = 0;
    function_call_idx = lookup($1, FUNC_KIND);
  } 
  function_call_params RIGHT_PAREN 
  {
    $$ = lookup($1, FUNC_KIND); 
    if ($$ == -1) {
      err("call to undefined function %s", $1);
    }
    else {
      code("\n\tcall $%s", $1);
    }
  }
  ;

function_call_params
  :
  | expression 
  {
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
  | function_call_params COMMA expression 
  {
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
  : logical_or_expression { $$ = $1; }
  ;

logical_or_expression 
  : logical_and_expression { $$ = $1; }
  | logical_or_expression OR_OP logical_and_expression 
  {
    if ($1 == BOOL_TYPE && $1 == $3) {
      code("\n\t%s.or", get_wasm_type($1));
      $$ = $1;
    } else {
      err("could not apply || operator to given operands");
    }
  }
  ;

logical_and_expression 
  : equality_expression { $$ = $1; }
  | logical_and_expression AND_OP equality_expression 
  {
    if ($1 == BOOL_TYPE && $1 == $3) {
      code("\n\t%s.and", get_wasm_type($1));
      $$ = $1;
    } else {
      err("could not apply && operator to given operands");
    }
  }
  ;

equality_expression
  : unary_expression { $$ = $1; }
  | equality_expression equality_operator unary_expression 
  {
    if ($1 != $3) {
      err("could not apply == != operator to given operands");
    } else {
      $$ = BOOL_TYPE;
      code("\n\t%s.%s", get_wasm_type($1), $2);
    }
  }
  ;

equality_operator
  : EQ_OP { $$ = "eq"; }
  | NEQ_OP { $$ = "ne"; }
  ;

unary_expression
  : relational_expression { $$ = $1; }
  | NOT_OP relational_expression 
  { 
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
  | relational_expression relational_operator additive_expression 
  { 
    if ($1 != $3 || $1 == BOOL_TYPE || $3 == BOOL_TYPE) {
      err("could not apply > >= < <= operator to given operands");
    } else {
      $$ = BOOL_TYPE;
      code("\n\t%s.%s", get_wasm_type($1), $2);
    }
  }
  ;

relational_operator
  : LT_OP { $$ = "lt_u"; }
  | GT_OP { $$ = "gt_u"; }
  | LTE_OP { $$ = "le_u"; }
  | GTE_OP { $$ = "ge_u"; }
  ;

additive_expression
  : multiplicative_expression { $$ = $1; }
  | additive_expression additive_operator multiplicative_expression 
  {
    if ($1 != $3) {
      err("could not apply + - operator to given operands");
    } else {
      code("\n\t%s.%s", get_wasm_type($1), $2);

      $$ = $1;
    }
  }
  ;

additive_operator
  : PLUS_OP { $$ = "add"; }
  | MINUS_OP { $$ = "sub"; }
  ;

multiplicative_expression
  : primary_expression { $$ = $1; }
  | multiplicative_expression multiplicative_operator primary_expression 
  {
    if ($1 == $3) {
      $$ = $1;
      code("\n\t%s.%s", get_wasm_type($1), $2);
    } else {
      err("could not apply * / %% operator to given operands");
    }
  }
  ;

multiplicative_operator 
  : MUL_OP { $$ = "mul"; }
  | DIV_OP { $$ = "div_u"; }
  | MOD_OP { $$ = "rem_u"; }
  ;  

primary_expression
  : ID 
  {
    int idx = lookup($1, VAR|PAR|GVAR);
    if (idx == -1) {
      err("use of undefined variable %s", $1);
    }
    else {
      $$ = get_type(idx);
      code("\n\tlocal.get $%s", $1);
    }
  }
  | literal { $$ = $1; }
  | INT_NUM 
  {
    $$ = INT_TYPE;
    code("\n\t%s.const %d", get_wasm_type(INT_TYPE),atoi($1));
  }
  | function_call 
  {
    int idx = $1;
    if (idx == -1) {
      err("call of undefined function %s", get_name($1));
    }
    else {
      $$ = get_type(idx);
    }
  }
  | LEFT_PAREN expression RIGHT_PAREN { $$ = $2; }
  ;

literal  
  : boolean_literal 
  {
    $$ = BOOL_TYPE;
  }
  ;

boolean_literal
  : TRUE_VAL { code("\n\t i32.const 1");}
  | FALSE_VAL { code("\n\t i32.const 0");}
  ;  

return_statement
  : RETURN expression 
  {
    if (get_type(function_idx) == VOID_TYPE) {
      err("could not return, function is of type void");
    } else if ($2 != get_type(function_idx)) {
      err("wrong return type");
    } else {
      code("\n\treturn");
    }
  }
  ;

%%


int main() {
  init_symtab();
  output = init_out_file();
  
  int ret_val = yyparse();

  fclose(output);

  if (err_cnt != 0) {
    remove("output.wat");
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
