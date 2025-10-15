%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h" /* importa as definições de tokens do parser (Bison)*/
%}

%%

"if"        { return KW_IF; }
"while"     { return KW_WHILE; }
"for"       { return KW_FOR; }
"return"    { return KW_RETURN; }
"int"       { return KW_INT; }
"float"     { return KW_FLOAT; }
"void"      { return KW_VOID; }
"printf"    { return KW_PRINTF; }
"scanf"     { return KW_SCANF; }

"//".*                      { /* Ignora comentários de linha */ }
"/*"([^*]|\*+[^*/])*\*+\/   { /* Ignora comentários de bloco */ }

[a-zA-Z_][a-zA-Z0-9_]*  { yylval.strValue = strdup(yytext); return IDENT; }

[0-9]+                  { yylval.intValue = atoi(yytext); return NUM; }
[0-9]+"."[0-9]+         { yylval.floatValue = atof(yytext); return FLOAT; }

"+" { return PLUS; }
"-" { return MINUS; }
"*" { return TIMES; }
"/" { return DIVIDE; }

"=="    { return EQ; }
"!="    { return NEQ; }
">"     { return GT; }
"<"     { return LT; }
">="    { return GE; }
"<="    { return LE; }

"&&"    { return AND; }
"||"    { return OR; }
"!"     { return NOT; }

"(" { return LPAREN; }
")" { return RPAREN; }
"{" { return LBRACE; }
"}" { return RBRACE; }
";" { return SEMI; }
"," { return COMMA; }

[ \t\n\r]+  { /* Ignorar */ }

. { printf("Token desconhecido: %s\n", yytext); }

%%

/* --- FIM DE ARQUIVO --- */
int yywrap(void) {
    return 1;
}

/* --- FUNÇÃO PRINCIPAL (EXECUTA O ANALISADOR LÉXICO) --- */
int main(void) {
    yylex();
    return 0;
}