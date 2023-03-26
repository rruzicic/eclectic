SHELL = /bin/bash
SRC = text
.PHONY: clean

$(SRC): defs.h lex.yy.c $(SRC).tab.c symtab.c symtab.h
	gcc -o $@ $+

lex.yy.c: $(SRC).l $(SRC).tab.c
	flex $<

$(SRC).tab.c: $(SRC).y
	bison -d $<

clean:
	rm -f lex.yy.c
	rm -f $(SRC).tab.c
	rm -f $(SRC).tab.h
	rm -f $(SRC).output
	rm -f $(SRC)