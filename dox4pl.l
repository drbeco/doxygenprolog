%{

/***************************************************************************
 *   dox4pl.l                                 Version 20150627.125100      *
 *                                                                         *
 *   DoxygenProlog                                                         *
 *   Copyright (C) 2015         by Ruben Carlo Benante                     *
 ***************************************************************************
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 3 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
 ***************************************************************************
 *   To contact the author, please write to:                               *
 *   Ruben Carlo Benante                                                   *
 *   Email: rcb@beco.cc                                                    *
 *   Webpage: www.beco.cc                                                  *
 *   Phone: +55 (81) 3184-7555                                             *
 ***************************************************************************/

/* ---------------------------------------------------------------------- */
/**
 * \file dox4pl.l
 * \ingroup GroupUnique
 * \brief DoxygenProlog
 * \details This program is a simple filter that converts a PROLOG source
 *  into something like C doxygen can understand to do its job.
 * \version 20150627.125100
 * \date 2015-06-27
 * \author Ruben Carlo Benante <<rcb@beco.cc>>
 * \par Webpage
 * <<a href="www.beco.cc">www.beco.cc</a>>
 * \copyright (c) 2015 GNU GPL v3
 * \note This program is free software: you can redistribute it
 * and/or modify it under the terms of the
 * GNU General Public License as published by
 * the Free Software Foundation version 3 of the License.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License
 * along with this program.
 * If not, write to the Free Software Foundation, Inc.,
 * 59 Temple Place - Suite 330, Boston, MA. 02111-1307, USA.
 * Or read it online at <<http://www.gnu.org/licenses/>>.
 *
 * \todo Manual page 3.
 *
 */

/* ---------------------------------------------------------------------- */
/* includes */

#include <stdio.h> /* Standard I/O functions */
#include <stdlib.h> /* Miscellaneous functions (rand, malloc, srand)*/
#include <getopt.h> /* get options from system argc/argv */

/* ---------------------------------------------------------------------- */
/* definitions */

#define VERSION (20150627.125100) /**< Version Number */

/* Debug */
#ifndef DEBUG /* gcc -DDEBUG=1 */
#define DEBUG 0 /**< Activate/deactivate debug mode */
#endif

/** \brief Debug message if DEBUG on */
#define IFDEBUG(M, ...) if(DEBUG) fprintf(stderr, "[DEBUG dox4pl: file:%s line:%d]: " M "\n", __FILE__, __LINE__, ##__VA_ARGS__); else {;}

/* limits */
#define SBUFF 256 /**< String buffer */

/* ---------------------------------------------------------------------- */
/* globals */

static int verb=0; /**< verbose level, global within the file */
char ident[SBUFF]; /**< Identifier name and arguments */
int mt; /**< Is it a Prolog: 1=module, 0=term ? */
int p; /**< Non-balanced open parentheses or brackets  */
int ca; /**< argument counter */

/* ---------------------------------------------------------------------- */
/* prototypes */

void help(void); /* print some help */
void copyr(void); /* print version and copyright information */
float version(void); /* returns the version float number YYMMDD.hhmmss */
int yywrap(void); /* exit after finish */
/* int yyerror(void); / * show an error message (we don't want to show any) */
  
%}

%option nounput noinput

%x COMENTA
%x MOD
%x REG
%x LOOP
%x FINAL
%x CONJUNCAO
%x CCOMENTA

ACO "/\*"
FCO "\*/"
IDE [a-z]+[a-zA-Z0-9_]*
SE ":-"
BR [ \t\r\n]
QQ (.|[\n])
BT ("\\"[^\n])
AS "\""
AP "'"
SY1 [^"\\\n]
SY2 [^'\\\n]
TT1 ({BT}|{SY1})
TT2 ({BT}|{SY2})
TX1 ({AS}{TT1}*{AS})
TX2 ({AP}{TT2}*{AP})
TX ({TX1}|{TX2})

%%

{SE} {
  IFDEBUG("{SE}");
  BEGIN(MOD);
}

{IDE} {
  IFDEBUG("{IDE}: %s", yytext);
  mt=0; /* 0=termo, 1=mod */
  strcpy(ident, yytext);
  BEGIN(REG);
}

{ACO} {
  IFDEBUG("{ACO}");
  ECHO;
  BEGIN(COMENTA);
}

<COMENTA>{QQ} {
  /* IFDEBUG("<COMENTA>{QQ}"); */
  ECHO;
}

<COMENTA>{FCO} {
  IFDEBUG("<COMENTA>{FCO}");
  ECHO;
  printf("\n");
  BEGIN(INITIAL);
}

"%".* {
  IFDEBUG("%%.*");
  printf("/* ");
  ECHO;
  printf(" */\n");
}

"#".* {
  IFDEBUG("#.*");
  printf("/* ");
  ECHO;
  printf(" */\n");
}

"//".* {
  IFDEBUG("//.*");
/*   printf("/ * "); */
  ECHO;
/*   printf(" * /"); */
  printf("\n");
}

{BR} {
  IFDEBUG("{BR}");
/*   ECHO; */
  ; /* ignora */
}

. {
  IFDEBUG(".");
  ; /* ignora */
}

<MOD>{IDE} {
  IFDEBUG("<MOD>{IDE}: %s", yytext);
  mt=1; /* 0=termo, 1=mod */
  strcpy(ident, yytext);
  BEGIN(REG);
}

<MOD>{BR}+ {
  IFDEBUG("<MOD>{BR}+");
  ; /* ignora */
}

<REG>[.] {
  IFDEBUG("<REG>[.]");
  if(mt)
    printf("define_t ");
  else
    printf("fact_t ");
  printf("%s(void);\n", ident);
  BEGIN(INITIAL);
}

<REG>"(" {
  IFDEBUG("<REG>'('");
  p=1;
  ca=1;
  BEGIN(LOOP);
}

<REG>{SE} {
  IFDEBUG("<REG>{SE}");
  if(mt)
    printf("error_t ");
  else
    printf("rule_t ");
  printf("%s(void);\n", ident);
  BEGIN(CONJUNCAO);
}

<REG>{BR}+ {
  IFDEBUG("<REG>{BR}+");
  ; /* ignora */
}

<LOOP>{TX} {
  IFDEBUG("<LOOP>{TX}");
  ; /* ignora string */
}

<LOOP>[])] {
  IFDEBUG("<LOOP>[ ]) ]");
  p--;
  if(!p)
    BEGIN(FINAL);
}

<LOOP>[[(] {
  IFDEBUG("<LOOP>[ [( ]");
  p++;
}

<LOOP>"," {
  if(p==1)
    ca++;
  IFDEBUG("<LOOP>',' %d", ca);
}

<LOOP>{QQ} {
  IFDEBUG("<LOOP>{QQ}");
  ; /* ignora */
}

<FINAL>[.] {
  IFDEBUG("<FINAL>[.]");
  if(mt)
    printf("define_t ");
  else
    printf("fact_t ");
  printf("%s(int A", ident);
  int i, c='B';
  for(i=1; i<ca; i++, c++)
    printf(", int %c", c);
  printf(");\n");
  BEGIN(INITIAL);
}

<FINAL>{SE} {
  IFDEBUG("<FINAL>{SE}");
  if(mt)
    printf("error_t ");
  else
    printf("rule_t ");
  printf("%s(int A", ident);
  int i, c='B';
  for(i=1; i<ca; i++, c++)
    printf(", int %c", c);
  printf(");\n");
  BEGIN(CONJUNCAO);
}

<FINAL>{BR}+ {
  IFDEBUG("<FINAL>{BR}+");
}

<CONJUNCAO>[.] {
  IFDEBUG("<CONJUNCAO>[.]");
  BEGIN(INITIAL);
  ; /* ignora */
}

<CONJUNCAO>{ACO} {
  IFDEBUG("<CONJUNCAO>{ACO}");
  ECHO;
  BEGIN(CCOMENTA);
}

<CCOMENTA>{QQ} {
  /* IFDEBUG("<CCOMENTA>{QQ}"); */
  ECHO;
  ; /* ignora */
}

<CCOMENTA>{FCO} {
  IFDEBUG("<CCOMENTA>{FCO}");
  ECHO;
  printf("\n");
  BEGIN(CONJUNCAO);
}

<CONJUNCAO>"%".* {
  IFDEBUG("<CONJUNCAO>%%.*");
  printf("/* ");
  ECHO;
  printf(" */\n");
}

<CONJUNCAO>"#".* {
  IFDEBUG("<CONJUNCAO>#.*");
  printf("/* ");
  ECHO;
  printf(" */\n");
}

<CONJUNCAO>"//".* {
  IFDEBUG("//.*");
/*   printf("/ * "); */
  ECHO;
/*   printf(" * /"); */
  printf("\n");
}

<CONJUNCAO>{TX} {
  IFDEBUG("{TX}");
  ; /* ignora */
}

<CONJUNCAO>{BR} {
  IFDEBUG("{BR}");
  ; /* ignora */
}

<CONJUNCAO>{QQ} {
  IFDEBUG("<CONJUNCAO>{QQ}");
  ; /* ignora */
}


%%

/* ---------------------------------------------------------------------- */
/**
 * \ingroup GroupUnique
 * \brief This is the main event of the evening
 * \details Ladies and Gentleman... It's tiiiime!
 * Fightiiiiing at the blue corner,
 *
 * \param[in] argc Argument counter
 * \param[in] argv Argument strings (argument values)
 *
 * \retval 0 If succeed (EXIT_SUCCESS).
 * \retval 1 Or another error code if failed.
 *
 * \par Example
 * \code
 *    Inside doxygen configuration file:
 *            FILTER_PATTERNS = *.pl="dox4pl"
 *    In the command line:
 *            $./dox4pl filetofilter
 * \endcode
 *
 * \warning It's still experimental. Please contact if some piece of PROLOG source
 * is not detected correctly (provide the piece of source with a minimum example, the expected
 * output and the actual output).
 * \note You can read more about it at <<a href="www.beco.cc">www.beco.cc</a>>
 * \author Ruben Carlo Benante
 * \version 20150627.125100
 * \date 2015-06-27
 *
 */
int main(int argc, char *argv[])
{
  int opt; /* return from getopt() */
  char *filename; /* keep file name */
  FILE *finput=NULL;

  yyin=stdin; /* input from stdin (default) or open file */

  /* getopt() configured options:
   *        -h  help
   *        -V  version
   *        -v  verbose
   *        -q  quiet (oposite of verbose)
   */
  opterr = 0;
  while((opt = getopt(argc, argv, "hVvq")) != EOF)
    switch(opt)
    {
      case 'h':
        help();
        break;
      case 'V':
        copyr();
        break;
      case 'v':
        verb++;
        break;
      case 'q':
        verb--;
        break;
      case '?': /* no argument, unknown option */
      default:
        fprintf(stderr, "/*\n dox4pl usage:\n Type\n\t$%s -h\t\tfor help.\n*/\n", argv[0]);
        return EXIT_FAILURE;
    }

  /* There is an unknown option not processed by getopt() */
  if(argc>optind)
  {
    filename=strdup(argv[optind]); /* Lets hope its a filename */
    finput = fopen(filename,"r"); /* It can fail. Test before use. */
  }

  if(verb>1)
    printf("/* dox4pl: verbose level set at: %d */\n", verb);

  if(finput == NULL) /* Test if really opened */
  {
    if(verb>0)
      fprintf(stderr, "/* dox4pl: I can't open %s for reading. I'm still reading from stdin. */\n", (filename==NULL?"NULL":filename));
  }
  else
    yyin = finput;

  if(yylex()) /* failed miserably */
  {
    fprintf(stderr, "/* dox4pl: lexical analyse failed miserably. */\n");
    return 1;
  }

  if(verb>0)
    printf("/* dox4pl ver. %13.6f: Copyright (C) 2015 Ruben Carlo Benante <rcb@beco.cc>, GNU GPL version 3 */\n", version());

  if(finput != NULL) /* If open, close it */
    fclose(finput);
  return EXIT_SUCCESS;
}

/* ---------------------------------------------------------------------- */
/**
 * \ingroup GroupUnique
 * \brief Prints help information and exit
 * \details Prints help information (usually called by opt -h)
 * \return Void
 * \author Ruben Carlo Benante
 * \version 20150627.125100
 * \date 2015-06-27
 *
 */
void help(void)
{
  IFDEBUG("help()");
  printf("%s - %s\n", "dox4pl", "DoxygenProlog");
  printf("\nUsage: %s [-h|-V] [-v] [-f] source\n", "d");
  printf("\nOptions:\n");
  printf("\t-h,         --help\n\t\tShow this help.\n");
  printf("\t-V,         --version\n\t\tShow version and copyright information.\n");
  printf("\t-v,         --verbose\n\t\tSet verbose level (cumulative).\n");
  printf("\t-f source,  --file source\n");
  printf("\t\tRead from source (prolog file).\n");
  printf("\t\tIf not given a source file, it will read from stdin.\n");
  printf("\n\tWrite the following lines into your doxygen configuration file (.cfg):\n\n");
  printf("\t\tFILE_PATTERNS   = *.pl *.prolog\n");
  printf("\t\tFILTER_PATTERNS = *.pl=\"dox4pl\"\n");
  /* add more options here */
  printf("\nExit status:\n\t0 if ok.\n\t1 some error occurred.\n");
  printf("Todo:\n\tLong options not implemented yet.\n");
  printf("Author:\n\tWritten by %s <%s>\n", "Ruben Carlo Benante", "rcb@beco.cc");
  printf("\tSee dox4pl -V for copyright information.\n\n");
  exit(EXIT_FAILURE);
}

/* ---------------------------------------------------------------------- */
/**
 * \ingroup GroupUnique
 * \brief Prints version and copyright information and exit
 * \details Prints version and copyright information (usually called by opt -V)
 * \return Void
 * \author Ruben Carlo Benante
 * \version 20150627.125100
 * \date 2015-06-27
 *
 */
void copyr(void)
{
  IFDEBUG("copyr()");
  printf("%s - Version %13.6f\n", "dox4pl", version());
  printf("\nCopyright (C) %d %s <%s>, GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>. This  is  free  software:  you are free to change and redistribute it. There is NO WARRANTY, to the extent permitted by law. USE IT AS IT IS. The author takes no responsability to any damage this software may inflige in your data.\n\n", 2015, "Ruben Carlo Benante", "rcb@beco.cc");
  if(verb>3) printf("copyr(): Verbose: %d\n", verb); /* -vvvv */
  exit(EXIT_FAILURE);
}

/* ---------------------------------------------------------------------- */
/**
 * \ingroup GroupUnique
 * \brief Returns the version number
 * \details This function may be used to update easily the version number,
 * instead of using the MACRO.
 * \return Float VERSION in the form YYMMDD.hhmmss
 * \author Ruben Carlo Benante
 * \version 20150627.125100
 * \date 2015-06-27
 *
 */
float version(void)
{
  IFDEBUG("version()");
  if(verb>3)
    printf("Version %13.6f\n", VERSION); /* -vvvv */
  return (VERSION); /* YYMMDD.hhmmss */
}


/* ---------------------------------------------------------------------- */
/**
 * \ingroup GroupUnique
 * \brief Tells yylex to finish when input is exaust
 * \return 1 to finish the program when no more input available
 * \author Ruben Carlo Benante
 * \version 20150627.125100
 * \date 2015-06-27
 *
 */
int yywrap(void)
{
  return 1;
}

/*
 * \ingroup GroupUnique
 * \brief Called in case of syntax error, print an error message.
 * \return 1 To indicate an error
 *
 * /
int yyerror(void)
{
  printf("/ * dox4pl error: %s * /\n", yytext);
  return 1;
}
*/

/* ---------------------------------------------------------------------- */
/* vi: set ai et ts=2 sw=2 tw=0 wm=0 fo=croql : C config for Vim modeline */
/* Template by Dr. Beco <rcb at beco dot cc> Version 20150619.231433      */
