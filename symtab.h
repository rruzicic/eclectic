#ifndef SYMTAB_H
#define SYMTAB_H

#define SYMTAB_LENGTH 64

typedef struct symtab_row {
    char*       name;
    unsigned    kind;  // function name, function parameter, variable, global variable
    unsigned    type;  // data type: int, bool, string, float...
    int         function_idx; // index of function that paramater belongs to (this parameter is only valid if kind=PAR)
    int         function_param_idx; // index of parameter in function declaration


} SYMBOL_TABLE_ROW;

// returns the index of a symbol with given name and type,
// if there is no such symbol it returns -1
int lookup(char* name, unsigned type);

int lookup_function_call_param(int function_idx, int function_param_idx);

int lookup_function_definiton_param(char* name, int function_idx);

int lookup_variable_declaration(char *name, int function_index);

int insert_row(char *name, unsigned kind, unsigned type);

int insert_var(char *name, unsigned type, int function_idx);

int insert_function_param(char *name, unsigned type, int function_idx, int function_param_idx);

int get_next_empty_element(void);

void init_symtab(void);

void clear_symtab(void);

void clear_symbols(unsigned begin_index);

void print_table(void);

unsigned get_type(unsigned idx);

int get_func_param_num(int index);

char* get_name(unsigned index);

#endif