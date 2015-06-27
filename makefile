CFLAGS = -Wall -Wextra -g -O0 -std=gnu99 -Wno-unused-function
LEX = flex
CC = gcc

.PHONY: all clean

all: dox2pl

dox2pl : lex.yy.c
	@echo --- gcc -------------------------------------------------
	$(CC) lex.yy.c -o dox2pl $(CFLAGS)

lex.yy.c : dox2pl.l
	@echo --- flex ------------------------------------------------
	$(LEX) dox2pl.l

clean:
	rm -f lex.yy.c dox2pl *.o
