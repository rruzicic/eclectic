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
  return index;
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

// Deletes all rows from symbol table.
void clear_symtab(void) {
  first_empty = SYMTAB_LENGTH - 1;
  clear_symbols(0);
}

void init_symtab(void) {
  clear_symtab();
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
  }
  first_empty = begin_index;
}
