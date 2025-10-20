%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"  /* importa tokens do parser */
%}

/* Habilita contador de linhas interno do Flex */
%option yylineno

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

[0-9]+"."[0-9]+         { yylval.floatValue = atof(yytext); return FLOAT; }
[0-9]+                  { yylval.intValue = atoi(yytext); return NUM; }

"+" { return PLUS; }
"-" { return MINUS; }
"*" { return TIMES; }
"/" { return DIVIDE; }
"%" { return MOD; }

"=="    { return EQ; }
"!="    { return NEQ; }
">="    { return GE; }
"<="    { return LE; }
">"     { return GT; }
"<"     { return LT; }

"&&"    { return AND; }
"||"    { return OR; }
"!"     { return NOT; }
"="     { return ASSIGN; }

"(" { return LPAREN; }
")" { return RPAREN; }
"{" { return LBRACE; }
"}" { return RBRACE; }
";" { return SEMI; }
"," { return COMMA; }

[ \t]+          { /* ignora espaços */ }
\n              { /* Flex já incrementa yylineno automaticamente */ }
"#".*            { /* ignora diretivas C */ }

. { printf("Token desconhecido: %s (linha %d)\n", yytext, yylineno); }

%%

int yywrap(void) {
    return 1;
}
