#include "codegen.h"

#include <stdio.h>
#include <string.h>
#include "defs.h"

FILE* output;

FILE* init_out_file() {
    output = fopen("output.wat", "w+");
    return output;
}

FILE* init_tmp_file() {
    return fopen("tmp_output.wat", "w+");
}


void print_string_numbers(char *string) {
    printf("\n[");
    for(int i = 0; string[i] != '\0'; i++) {
        printf("%d, ", string[i]);
    }
    printf("]\n");
}

void copy_tmp_to_output(FILE* tmp) {
    fclose(output);
    output = fopen("output.wat", "w+");
    fseek(tmp, 0, SEEK_SET);
    char c = fgetc(tmp);
    while (c != EOF)
    {
        fputc(c, output);
        c = fgetc(tmp);
    }
    fclose(tmp);
    remove("tmp_output.wat");
}


void append_local_variable(int function_idx, FILE* output, unsigned type, char *name) {
    char buffer[200];
    char cmp[200];
    sprintf(cmp, "\t;; LOCAL VARIABLES: function_idx=%d\n", function_idx);
    fseek(output, 0, SEEK_SET);
    FILE* tmp = init_tmp_file();
    while (fgets(buffer, 200, output) != NULL) {
        fprintf(tmp, "%s", buffer);
        if (strcmp(cmp, buffer) == 0) {
            fprintf(tmp, "\n\t(local $%s %s)", name, get_wasm_type(type));
        }   
    }

    copy_tmp_to_output(tmp);
}

char* get_wasm_type(unsigned type) {
    if (type == INT_TYPE) {
        return "i32";
    } else if (type == BOOL_TYPE) {
        return "i32";
    }
}

char* get_wasm_function_implicit_return(unsigned type) {
    if (type == INT_TYPE) {
        return "i32.const 0\n\treturn";
    } else if (type == BOOL_TYPE) {
        return "i32.const 0\n\treturn";
    } else if (type == VOID_TYPE) {
        return "";
    }
}




