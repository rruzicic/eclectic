#ifndef DEFS_H
#define DEFS_H

#define CHAR_BUFFER_LENGTH   128
extern char char_buffer[CHAR_BUFFER_LENGTH];

extern void warning(char *s);
extern int yyerror(char *s);
#define err(args...)  sprintf(char_buffer, args), yyerror(char_buffer)
#define warn(args...) sprintf(char_buffer, args), warning(char_buffer)

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
    
};

#endif