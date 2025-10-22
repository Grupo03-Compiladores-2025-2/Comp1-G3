%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex(void);
extern FILE *yyin;
extern int yylineno;

void yyerror(const char *s);

/* Função para identar código Python */
char* indent(const char* code, int level) {
    int len = strlen(code);
    int indent_size = level * 4; 
    char* result = malloc(len + indent_size * 10 + 1);
    result[0] = '\0';
    const char* p = code;
    while (*p) {
        for (int i = 0; i < indent_size; i++) strcat(result, " ");
        while (*p && *p != '\n') {
            char temp[2] = {*p, '\0'};
            strcat(result, temp);
            p++;
        }
        strcat(result, "\n");
        if (*p == '\n') p++;
    }
    return result;
}
%}

/* ===== TIPOS ===== */
%union {
    int intValue;
    float floatValue;
    char *strValue;
}

/* ===== TOKENS ===== */
%token <strValue> IDENT
%token <intValue> NUM
%token <floatValue> FLOAT

%token KW_IF KW_WHILE KW_FOR KW_RETURN
%token KW_INT KW_FLOAT KW_VOID
%token KW_PRINTF KW_SCANF

%token PLUS MINUS TIMES DIVIDE MOD
%token EQ NEQ GT LT GE LE
%token AND OR NOT
%token ASSIGN
%token LPAREN RPAREN LBRACE RBRACE SEMI COMMA

/* ===== PRIORIDADES ===== */
%left OR
%left AND
%left EQ NEQ
%left LT LE GT GE
%left PLUS MINUS
%left TIMES DIVIDE MOD
%right NOT

/* ===== NÃO-TERMINAIS ===== */
%type <strValue> program function stmt_list stmt expr

%%

program:
    function
  | program function
  ;

function:
    KW_INT IDENT LPAREN RPAREN LBRACE stmt_list RBRACE
        {
            printf("def %s():\n%s\n", $2, indent($6, 1));
            free($2); free($6);
        }
  | KW_VOID IDENT LPAREN RPAREN LBRACE stmt_list RBRACE
        {
            printf("def %s():\n%s\n", $2, indent($6, 1));
            free($2); free($6);
        }
  ;

stmt_list:
    /* vazio */ { $$ = strdup(""); }
  | stmt_list stmt
        {
            $$ = malloc(strlen($1) + strlen($2) + 2);
            sprintf($$, "%s%s", $1, $2);
            free($1); free($2);
        }
  ;

stmt:
    /* if/while/for continuam iguais */
    KW_IF LPAREN expr RPAREN LBRACE stmt_list RBRACE
        {
            int len = strlen($3) + strlen($6) + 32;
            $$ = malloc(len);
            sprintf($$, "if %s:\n%s", $3, indent($6,1));
            free($3); free($6);
        }
  | KW_WHILE LPAREN expr RPAREN LBRACE stmt_list RBRACE
        {
            int len = strlen($3) + strlen($6) + 32;
            $$ = malloc(len);
            sprintf($$, "while %s:\n%s", $3, indent($6,1));
            free($3); free($6);
        }
  | KW_PRINTF LPAREN expr RPAREN SEMI
        {
            int len = strlen($3) + 30;
            $$ = malloc(len);
            sprintf($$, "print(%s)\n", $3);
            free($3);
        }
  | KW_SCANF LPAREN expr RPAREN SEMI
        {
            int len = strlen($3) + 50;
            $$ = malloc(len);
            sprintf($$, "%s = input()\n", $3);
            free($3);
        }
  | KW_RETURN expr SEMI
        {
            int len = strlen($2) + 20;
            $$ = malloc(len);
            sprintf($$, "return %s\n", $2);
            free($2);
        }

    /* Declaração com atribuição */
  | KW_INT IDENT ASSIGN expr SEMI
        {
            int len = strlen($2) + strlen($4) + 10;
            $$ = malloc(len);
            sprintf($$, "%s = %s\n", $2, $4);
            free($2); free($4);
        }
  | KW_FLOAT IDENT ASSIGN expr SEMI
        {
            int len = strlen($2) + strlen($4) + 10;
            $$ = malloc(len);
            sprintf($$, "%s = float(%s)\n", $2, $4);
            free($2); free($4);
        }

    /* Declaração sem atribuição */
  | KW_INT IDENT SEMI
        {
            int len = strlen($2) + 4;
            $$ = malloc(len);
            sprintf($$, "%s = 0\n", $2); // inicializa com 0
            free($2);
        }
  | KW_FLOAT IDENT SEMI
        {
            int len = strlen($2) + 6;
            $$ = malloc(len);
            sprintf($$, "%s = 0.0\n", $2); // inicializa com 0.0
            free($2);
        }

    /* Atribuição simples */
  | IDENT ASSIGN expr SEMI
        {
            int len = strlen($1) + strlen($3) + 10;
            $$ = malloc(len);
            sprintf($$, "%s = %s\n", $1, $3);
            free($1); free($3);
        }

    /* Expressões soltas */
  | expr SEMI
        {
            $$ = malloc(strlen($1) + 4);
            sprintf($$, "%s\n", $1);
            free($1);
        }
;
;

expr:
    NUM
        {
            char buffer[32];
            sprintf(buffer, "%d", $1);
            $$ = strdup(buffer);
        }
  | FLOAT
        {
            char buffer[32];
            sprintf(buffer, "%f", $1);
            $$ = strdup(buffer);
        }
  | IDENT
        { $$ = strdup($1); free($1); }
  | expr PLUS expr
        { $$ = malloc(strlen($1)+strlen($3)+4); sprintf($$, "%s + %s", $1, $3); free($1); free($3); }
  | expr MINUS expr
        { $$ = malloc(strlen($1)+strlen($3)+4); sprintf($$, "%s - %s", $1, $3); free($1); free($3); }
  | expr TIMES expr
        { $$ = malloc(strlen($1)+strlen($3)+4); sprintf($$, "%s * %s", $1, $3); free($1); free($3); }
  | expr DIVIDE expr
        { $$ = malloc(strlen($1)+strlen($3)+4); sprintf($$, "%s / %s", $1, $3); free($1); free($3); }
  | expr MOD expr
        { $$ = malloc(strlen($1)+strlen($3)+4); sprintf($$, "%s %% %s", $1, $3); free($1); free($3); }
  ;

%%

/* ===== FUNÇÕES AUXILIARES ===== */
void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe na linha %d: %s\n", yylineno, s);
}

int main(int argc, char **argv) {
    if (argc > 1)
        yyin = fopen(argv[1], "r");
    else
        yyin = stdin;

    yyparse();

    if (yyin != stdin)
        fclose(yyin);

    return 0;
}
