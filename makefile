# /***************************************************************************
#  *   makefile                                 Version 20150627.125100      *
#  *                                                                         *
#  *   DoxygenProlog makefile                                                *
#  *   Copyright (C) 2015         by Ruben Carlo Benante                     *
#  ***************************************************************************
#  *   This program is free software; you can redistribute it and/or modify  *
#  *   it under the terms of the GNU General Public License as published by  *
#  *   the Free Software Foundation; either version 3 of the License, or     *
#  *   (at your option) any later version.                                   *
#  *                                                                         *
#  *   This program is distributed in the hope that it will be useful,       *
#  *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
#  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
#  *   GNU General Public License for more details.                          *
#  *                                                                         *
#  *   You should have received a copy of the GNU General Public License     *
#  *   along with this program; if not, write to the                         *
#  *   Free Software Foundation, Inc.,                                       *
#  *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
#  ***************************************************************************
#  *   To contact the author, please write to:                               *
#  *   Ruben Carlo Benante                                                   *
#  *   Email: rcb@beco.cc                                                    *
#  *   Webpage: www.beco.cc                                                  *
#  *   Phone: +55 (81) 3184-7555                                             *
#  ***************************************************************************/

CFLAGS = -Wall -Wextra -g -O0 -std=gnu99
DEBUG = -DDEBUG=1
LEX = flex
CC = gcc

.PHONY: all clean

all: dox4pl

dox4pl : lex.yy.c
	@echo --- gcc -------------------------------------------------
	$(CC) lex.yy.c -o dox4pl $(CFLAGS)

debug : lex.yy.c
	@echo --- gcc -DDEBUG=1 ---------------------------------------
	$(CC) lex.yy.c -o dox4pl $(CFLAGS) $(DEBUG)

lex.yy.c : dox4pl.l
	@echo --- flex ------------------------------------------------
	$(LEX) dox4pl.l

clean:
	rm -f lex.yy.c dox4pl *.o

install:
	sudo cp dox4pl /usr/local/bin

