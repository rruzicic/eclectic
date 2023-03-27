#ifndef SYMTAB_H
#define SYMTAB_H

#define SYMTAB_LENGTH 64

typedef struct symtab_row {
    char*       name;
    unsigned    kind;  // function name, function parameter, variable, global variable
    unsigned    type;  // data type: int, bool, string, float...

} SYMBOL_TABLE_ROW;

// returns the index of a symbol with given name and type,
// if there is no such symbol it returns -1
int lookup(char* name, unsigned type);

int insert_row(char *name, unsigned kind, unsigned type);

int get_next_empty_element(void);

void init_symtab(void);

void clear_symtab(void);

void clear_symbols(unsigned begin_index);

unsigned get_type(unsigned idx);

char* get_name(unsigned index);

#endif