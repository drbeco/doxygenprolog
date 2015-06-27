%{

  #include <stdlib.h>
  
/*    #define DEBUG(msg, ...) fprintf(stderr, "DEBUG: " msg "\n", ##__VA_ARGS__) */
  /* #define DEBUG(msg, val) fprintf(stderr, "DEBUG: " msg "\n", val) */
  #define DEBUG(msg, ...)

  char ident[512]; /* nome e argumentos do identificador */
  int mt; /* modulo ou termo */
  int p; /* qtdd de parenteses ou colchetes aberta */
  int ca; /* contador de argumentos */

%}

%x COMENTA
%x MOD
%x REG
%x LOOP
%x FINAL
%x CONJUNCAO

ACO "/\*"
FCO "\*/"
IDE [a-z]+[a-zA-Z0-9_]*
SE ":-"
BR [ \t\r\n]
QQ (.|[\n])
BT ("\\"[^\n])
AS "\""
SY [^"\\\n]
TT ({BT}|{SY})
TX ({AS}{TT}*{AS})


%%

{SE} {
  DEBUG("{SE}");
  BEGIN(MOD);
}

{IDE} {
  DEBUG("{IDE}: %s", yytext);
  mt=0; /* 0=termo, 1=mod */
  strcpy(ident, yytext);
  BEGIN(REG);
}

{ACO} {
  DEBUG("{ACO}");
  BEGIN(COMENTA);
}

<COMENTA>{QQ} {
  /*DEBUG("<COMENTA>{QQ}");*/
  ; /* ignora */
}

<COMENTA>{FCO} {
  DEBUG("<COMENTA>{FCO}");
  BEGIN(INITIAL);
}

"%".* {
  DEBUG("%%.*");
  ; /* ignora */
}

"#".* {
  DEBUG("%%.*");
  ; /* ignora */
}

{BR} {
  DEBUG("{BR}");
  ; /* ignora */
}

. {
  DEBUG(".");
  ; /* ignora */
}

<MOD>{IDE} {
  DEBUG("<MOD>{IDE}: %s", yytext);
  mt=1; /* 0=termo, 1=mod */
  strcpy(ident, yytext);
  BEGIN(REG);
}

<MOD>{BR}+ {
  DEBUG("<MOD>{BR}+");
}

<REG>[.] {
  DEBUG("<REG>[.]");
  if(mt)
    printf("define_t ");
  else
    printf("fact_t ");
  printf("%s(void);\n", ident);
  BEGIN(INITIAL);
}

<REG>"(" {
  DEBUG("<REG>'('");
  p=1;
  ca=1;
  BEGIN(LOOP);
}

<REG>{SE} {
  DEBUG("<REG>{SE}");
  if(mt)
    printf("error_t ");
  else
    printf("rule_t ");
  printf("%s(void);\n", ident);
  BEGIN(CONJUNCAO);
}

<REG>{BR}+ {
  DEBUG("<REG>{BR}+");
  ; /* ignora */
}

<LOOP>{TX} {
  DEBUG("<LOOP>{TX}");
  ; /* ignora string */
}

<LOOP>[])] {
  DEBUG("<LOOP>[])]");
  p--;
  if(!p)
    BEGIN(FINAL);
}

<LOOP>[[(] {
  DEBUG("<LOOP>[ [(]");
  p++;
}

<LOOP>"," {
  if(p==1)
    ca++;
  DEBUG("<LOOP>',' %d", ca);
}

<LOOP>{QQ} {
  DEBUG("<LOOP>{QQ}");
  ; /* ignora */
}

<FINAL>[.] {
  DEBUG("<FINAL>[.]");
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
  DEBUG("<FINAL>{SE}");
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
  DEBUG("<FINAL>{BR}+");
}

<CONJUNCAO>[.] {
  DEBUG("<CONJUNCAO>[.]");
  BEGIN(INITIAL);
  ; /* ignora */
}

<CONJUNCAO>{QQ} {
  DEBUG("<CONJUNCAO>{QQ}");
  ; /* ignora */
}

%%

int yywrap(void)
{
  return 1;
}

int yyerror(void)
{
  printf("Error: %s\n", yytext);
  /*exit(1);*/
  return 1;
}

/*int main( int argc, char **argv ) */
int main( void )
{
  if(yylex()) //falhou
  {
    fprintf(stderr, "//Fail.\n");
    return 1;
  }
  return 0;
}
