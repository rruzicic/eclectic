#ifndef CODEGEN_H
#define CODEGEN_H
#include <stdio.h>

void append_local_variable(int function_idx, FILE* output, unsigned type, char *name);

FILE* init_out_file();

char* get_wasm_type(unsigned type);

char* get_wasm_function_implicit_return(unsigned type);

#endif