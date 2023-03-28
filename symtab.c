#include "symtab.h"
#include "defs.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

SYMBOL_TABLE_ROW symtab[SYMTAB_LENGTH];
int first_empty = 0;

int get_next_empty_element(void) {
  if (first_empty < SYMTAB_LENGTH) {
    return first_empty++;
  } else {
    err("Compiler error! Symbol table overflow!");
    exit(EXIT_FAILURE);
  }
}

int insert_row(char *name, unsigned kind, unsigned type) {
  int index = get_next_empty_element();
  symtab[index].name = name;
  symtab[index].kind = kind;
  symtab[index].type = type;
  symtab[index].function_idx = -1;
  symtab[index].function_param_idx = -1;
  return index;
}

int insert_function_param(char *name, unsigned type, int function_idx, int function_param_idx) {
  int index = get_next_empty_element();
  symtab[index].name = name;
  symtab[index].kind = PAR;
  symtab[index].type = type;
  symtab[index].function_idx = function_idx;
  symtab[index].function_param_idx = function_param_idx;
  return index;
}

int insert_var(char *name, unsigned type, int function_idx) {
  int index = get_next_empty_element();
  symtab[index].name = name;
  symtab[index].kind = VAR;
  symtab[index].type = type;
  symtab[index].function_idx = function_idx;
  symtab[index].function_param_idx = -1;
  return index;
}

int lookup_function_call_param(int function_idx, int function_param_idx) {
  for (int i = 0; i < first_empty; i++) {
    if (symtab[i].function_idx == function_idx && symtab[i].function_param_idx == function_param_idx) {
      return i;
    }
  }
  return -1;
}

int lookup_function_definiton_param(char* name, int function_idx) {
  for (int i = 0; i < first_empty; i++) {
    if (strcmp(symtab[i].name, name) == 0 && symtab[i].kind == PAR && symtab[i].function_idx == function_idx) {
      return i;
    }
  }
  return -1;
}

int lookup_variable_declaration(char *name, int function_index) {
  for (int i = 0; i < first_empty; i++) {
    if (strcmp(symtab[i].name, name) == 0 && symtab[i].kind & VAR|PAR|GVAR && (symtab[i].function_idx == function_index || symtab[i].function_idx == -1)) {
      return i;
    }
  }
  return -1;
}

int lookup(char *name, unsigned kind) {
  for (int i = 0; i < first_empty; i++) {
    if (strcmp(symtab[i].name, name) == 0 && symtab[i].kind & kind) {
      return i;
    }
  }
  return -1;
}

unsigned get_type(unsigned index) {
  if (index > first_empty) {
    return NO_TYPE;
  }
  return symtab[index].type;
}

char* get_name(unsigned index) {
  if (index > first_empty) {
    return "";
  }
  return symtab[index].name;
}

int get_func_param_num(int index) {
  int sum = 0;
  for (int i = 0; i < first_empty; i++) {
    if (symtab[i].kind == PAR && symtab[i].function_idx == index) {
      sum++;
    }
  }
  return sum;
}

// Deletes all rows from symbol table.
void clear_symtab(void) {
  first_empty = SYMTAB_LENGTH - 1;
  clear_symbols(0);
}

void init_symtab(void) {
  clear_symtab();
}

void print_table() {
  printf("index\tname\tkind\ttype\tfun_idx\tfun_par_idx");
  for (int i = 0; i < first_empty; i++) {
    printf("\n %d\t%s\t%d\t%d\t%d\t%d\n", 
    i,
    symtab[i].name,
    symtab[i].kind,
    symtab[i].type,
    symtab[i].function_idx,
    symtab[i].function_param_idx
    );
  }
}

// Deletes all symbols in symbol table starting from begin_index all the way through to the last index in table.
void clear_symbols(unsigned begin_index) {
  if (begin_index == first_empty)
    return;
  if (begin_index > first_empty) {
    err("Compiler error! Wrong clear symbols argument");
    exit(EXIT_FAILURE);
  }
  for (int i = begin_index; i < first_empty; i++) {
    if (symtab[i].name)
      free(symtab[i].name);
    symtab[i].name = 0;
    symtab[i].kind = NO_KIND;
    symtab[i].type = NO_TYPE;
    symtab[i].function_idx = -1;
    symtab[i].function_param_idx = -1;
  }
  first_empty = begin_index;
}
