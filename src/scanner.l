/* 
 * Este arquivo define o analisador léxico (lexer) da linguagem do compilador.
 * Ele reconhece palavras-chave, identificadores, números, operadores, strings,
 * símbolos e ignora espaços, comentários e diretivas. O lexer produz tokens
 * utilizados pelo parser para construir a AST e interpretar a estrutura do programa.
 */

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "ast.h"
    #include "parser.tab.h"
%}

%option yylineno
%option nounput noinput

%%

"if"        { return KW_IF; }
"else"      { return KW_ELSE; }
"while"     { return KW_WHILE; }
"for"       { return KW_FOR; }
"return"    { return KW_RETURN; }
"int"       { return KW_INT; }
"float"     { return KW_FLOAT; }
"void"      { return KW_VOID; }
"printf"    { return KW_PRINTF; }
"do"        { return KW_DO; }
"scanf"     { return KW_SCANF; }
"break"     { return KW_BREAK; }
"switch"    { return KW_SWITCH; }
"case"      { return KW_CASE; }
"default"   { return KW_DEFAULT; }

":"         { return COLON; }

"//".*                              { }
"/*"([^*]|\*+[^*/])*\*+\/           { }

\"([^\\\n"]|\\.)*\" {
    yylval.strValue = strdup(yytext);
    return STRING_LITERAL;
}

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.strValue = strdup(yytext);
    return IDENT;
}

[0-9]+\.[0-9]+([eE][+-]?[0-9]+)? {
    yylval.floatValue = atof(yytext);
    return FLOAT;
}

[0-9]+ {
    yylval.intValue = atoi(yytext);
    return NUM;
}

"==" { return EQ; }
"!=" { return NEQ; }
">=" { return GE; }
"<=" { return LE; }
">"  { return GT; }
"<"  { return LT; }

"&&" { return AND; }
"&"  { return AMPERSAND; }
"||" { return OR; }
"!"  { return NOT; }

"="  { return ASSIGN; }

"+"  { return PLUS; }
"-"  { return MINUS; }
"*"  { return TIMES; }
"/"  { return DIVIDE; }
"%"  { return MOD; }

"("  { return LPAREN; }
")"  { return RPAREN; }
"{"  { return LBRACE; }
"}"  { return RBRACE; }
";"  { return SEMI; }
","  { return COMMA; }

"++" { return INC_OP; }
"--" { return DEC_OP; }

[ \t\r]+   { }
\n         { }

"#".*       { }

. {
    fprintf(stderr, "Token desconhecido: %s (linha %d)\n", yytext, yylineno);
    return yytext[0];
}

%%

int yywrap(void) {
    return 1;
}
