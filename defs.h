#ifndef DEFS_H
#define DEFS_H

#define CHAR_BUFFER_LENGTH   128
extern char char_buffer[CHAR_BUFFER_LENGTH];
extern int err_cnt;
extern int warn_cnt;
extern void warning(char *s);
extern int yyerror(char *s);
extern int out_lin;

#define err(args...)  sprintf(char_buffer, args), yyerror(char_buffer), err_cnt++
#define warn(args...) sprintf(char_buffer, args), warning(char_buffer), warn_cnt++
#define code(args...) ({fprintf(output, args); \
          if (++out_lin > 2000) err("Too many output lines"), exit(1); })

enum Kind {
    NO_KIND     = 1 << 0,
    FUNC_KIND   = 1 << 1,
    VAR         = 1 << 2,
    PAR         = 1 << 3,
    GVAR        = 1 << 4,

};

enum Type {
    NO_TYPE     = 1 << 0,
    INT_TYPE    = 1 << 1,
    BOOL_TYPE   = 1 << 2,
    VOID_TYPE   = 1 << 3, // Only for function return type.
};

#endif