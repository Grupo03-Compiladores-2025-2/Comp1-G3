/*
 * Este arquivo (parser.y) implementa o Analisador Sintático (Parser) do compilador 
 * utilizando Bison. Ele define a gramática da linguagem C simplificada,
 * constrói a Árvore de Sintaxe Abstrata (AST) e lida com a precedência de operadores.
 */

%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "ast.h"

    extern int yylineno;
    extern char* yytext;
    int yylex();
    void yyerror(const char *s);

    ASTNode* root = NULL;
%}

/* -----------------------------------------------------------
 * UNION: Definição dos Tipos dos Símbolos
 * ----------------------------------------------------------- */
%union {
    int intValue;
    float floatValue;
    char* strValue;
    struct ASTNode* node;
}

/* -----------------------------------------------------------
 * TOKENS (Terminais)
 * ----------------------------------------------------------- */

/* Identificadores e Constantes */
%token <strValue> IDENT
%token <strValue> STRING_LITERAL
%token <intValue> NUM
%token <floatValue> FLOAT

/* Palavras-Chave */
%token KW_IF KW_ELSE KW_WHILE KW_FOR KW_RETURN KW_INT KW_FLOAT KW_VOID KW_PRINTF KW_SCANF
%token KW_SWITCH KW_CASE KW_DEFAULT KW_BREAK
%token KW_DO

/* Operadores */
%token EQ NEQ GE LE GT LT AND OR NOT ASSIGN
%token PLUS MINUS TIMES DIVIDE MOD 
%token INC_OP DEC_OP
%token AMPERSAND

/* Delimitadores */
%token LPAREN RPAREN LBRACE RBRACE SEMI COMMA
%token COLON

/* -----------------------------------------------------------
 * TIPOS NÃO-TERMINAIS
 * ----------------------------------------------------------- */
%type <node> program statement_list statement expression var_decl declaration_list declaration case_list case_clause
%type <node> simple_assign_stmt simple_incr_decr_stmt 

/* -----------------------------------------------------------
 * PRECEDÊNCIA E ASSOCIATIVIDADE
 * ----------------------------------------------------------- */
%left OR
%left AND
%left EQ NEQ GT LT GE LE
%left PLUS MINUS
%left TIMES DIVIDE MOD
%right NOT /* Operador Unário (maior precedência) */

%start program

%%

/* ===========================================================
 * G R A M Á T I C A
 * =========================================================== */

/* ---------------------- PROGRAMA ------------------------- */

program:
      KW_VOID IDENT LPAREN RPAREN LBRACE statement_list RBRACE { $$ = $6; root = $$; }
    | KW_INT IDENT LPAREN RPAREN LBRACE statement_list RBRACE  { $$ = $6; root = $$; }
    | LBRACE statement_list RBRACE                            { $$ = $2; root = $$; }
    ;

/* ---------------------- STATEMENT LIST ------------------- */

statement_list:
      statement statement_list { $1->next = $2; $$ = $1; }
    | /* vazio */              { $$ = NULL; }
    ;

/* ---------------------- STATEMENTS ----------------------- */

statement:
      /* Declaração e Atribuição */
      var_decl SEMI { $$ = $1; }
    | IDENT ASSIGN expression SEMI {
          $$ = createNode(NODE_ASSIGN);
          $$->id = $1;
          $$->right = $3;
      }
    | IDENT INC_OP SEMI { 
          $$ = createNode(NODE_INCREMENT); 
          $$->id = $1;
      }
    | IDENT DEC_OP SEMI { 
          $$ = createNode(NODE_DECREMENT);
          $$->id = $1;
      }
      
      /* I/O */
    | KW_PRINTF LPAREN expression RPAREN SEMI {
          $$ = createNode(NODE_PRINTF);
          $$->left = $3;
      }
    | KW_SCANF LPAREN expression COMMA expression RPAREN SEMI { 
          $$ = createNode(NODE_SCANF);
          $$->left = $3;
          $$->right = $5;
      }
      
      /* Estruturas de Controle: IF */
    | KW_IF LPAREN expression RPAREN LBRACE statement_list RBRACE {
          $$ = createNode(NODE_IF);
          $$->condition = $3;
          $$->left = $6;
      }
    | KW_IF LPAREN expression RPAREN LBRACE statement_list RBRACE KW_ELSE LBRACE statement_list RBRACE {
          $$ = createNode(NODE_IF);
          $$->condition = $3;
          $$->left = $6;
          $$->else_body = $10;
      }
    | KW_IF LPAREN expression RPAREN LBRACE statement_list RBRACE KW_ELSE statement {
          $$ = createNode(NODE_IF);
          $$->condition = $3;
          $$->left = $6;
          $$->else_body = $9; /* CORRIGIDO: $9 é o statement subsequente ('if') */
      }
      
      /* Estruturas de Controle: LOOPS */
    | KW_WHILE LPAREN expression RPAREN LBRACE statement_list RBRACE {
          $$ = createNode(NODE_WHILE);
          $$->condition = $3;
          $$->left = $6;
      }
    | KW_DO LBRACE statement_list RBRACE KW_WHILE LPAREN expression RPAREN SEMI { 
          $$ = createNode(NODE_WHILE); 
          $$->condition = $7;
          $$->left = $3;
          $$->op = strdup("do_while");
      }
    | KW_FOR LPAREN simple_assign_stmt SEMI expression SEMI simple_incr_decr_stmt RPAREN LBRACE statement_list RBRACE {
          $$ = createNode(NODE_FOR);
          $$->init_stmt = $3;
          $$->condition = $5; 
          $$->incr_stmt = $7;
          $$->left = $10;       
      }
      
      /* Estruturas de Controle: SWITCH/BREAK/RETURN */
    | KW_RETURN expression SEMI { 
          $$ = createNode(NODE_RETURN);
          $$->left = $2;
      }
    | KW_SWITCH LPAREN expression RPAREN LBRACE case_list RBRACE {
          $$ = createNode(NODE_SWITCH);
          $$->condition = $3;
          $$->left = $6;
      }
    | KW_BREAK SEMI { $$ = createNode(NODE_BREAK); }
    ;

/* ---------------------- REGRAS AUXILIARES PARA FOR ----------------------- */

simple_assign_stmt:
      IDENT ASSIGN expression {
          $$ = createNode(NODE_ASSIGN);
          $$->id = $1;
          $$->right = $3;
      }
    | var_decl { 
          $$ = $1; /* Permite declaração na inicialização (e.g., int i=0) */
      }
    | /* vazio */ { $$ = NULL; } 
    ;

simple_incr_decr_stmt:
      IDENT INC_OP {
          $$ = createNode(NODE_INCREMENT);
          $$->id = $1;
      }
    | IDENT DEC_OP {
          $$ = createNode(NODE_DECREMENT);
          $$->id = $1;
      }
    | IDENT ASSIGN expression { 
          $$ = createNode(NODE_ASSIGN);
          $$->id = $1;
          $$->right = $3;
      }
    | /* vazio */ { $$ = NULL; } 
    ;


/* ---------------------- SWITCH/CASE/DEFAULT ----------------------- */

case_list:
      case_clause case_list { $1->next = $2; $$ = $1; }
    | /* vazio */           { $$ = NULL; }
    ;

case_clause:
      KW_CASE expression COLON statement_list {
          $$ = createNode(NODE_CASE);
          $$->condition = $2;
          $$->left = $4;
      }
    | KW_DEFAULT COLON statement_list {
          $$ = createNode(NODE_CASE);
          $$->condition = NULL; /* Sinaliza default */
          $$->left = $3;
      }
    ;

/* ---------------------- DECLARAÇÃO DE VARIÁVEIS ----------------------- */

var_decl:
      KW_INT declaration_list {
          $$ = createNode(NODE_VAR_DECL_LIST); 
          $$->left = $2; 
          
          ASTNode *tmp = $2;
          while (tmp) {
              tmp->op = strdup("int");
              tmp = tmp->next;
          }
      }
    | KW_FLOAT declaration_list {
          $$ = createNode(NODE_VAR_DECL_LIST); 
          $$->left = $2; 
          
          ASTNode *tmp = $2;
          while (tmp) {
              tmp->op = strdup("float");
              tmp = tmp->next;
          }
      }
    ;

declaration_list:
      declaration { $$ = $1; }
    | declaration COMMA declaration_list {
          $1->next = $3;
          $$ = $1;
      }
    ;

declaration:
      IDENT {
          $$ = createNode(NODE_VAR_DECL);
          $$->id = $1;
      }
    | IDENT ASSIGN expression {
          $$ = createNode(NODE_VAR_DECL);
          $$->id = $1;
          $$->right = $3;
      }
    ;

/* ---------------------- EXPRESSÕES ----------------------- */

expression:
      /* Constantes e Variáveis */
      STRING_LITERAL { 
          $$ = createNode(NODE_CONST_STRING);
          $$->id = $1;
      }
    | NUM {
          $$ = createNode(NODE_CONST_INT);
          $$->intVal = $1;
      }
    | FLOAT {
          $$ = createNode(NODE_CONST_FLOAT);
          $$->floatVal = $1;
      }
    | IDENT {
          $$ = createNode(NODE_VAR_USE);
          $$->id = $1;
      }
    | AMPERSAND IDENT { /* Endereço de (&) */
          $$ = createNode(NODE_ADDRESS_OF);
          $$->id = $2;
      }
      
      /* Agrupamento e Unário */
    | LPAREN expression RPAREN { $$ = $2; }
    | NOT expression { 
          $$ = createNode(NODE_UNARY_OP); 
          $$->left = $2; 
          $$->op = strdup("!"); 
      }
    
      /* Operadores Binários (Aritméticos, Relacionais, Lógicos) */
    | expression PLUS expression {
          $$ = createNode(NODE_BIN_OP); $$->left = $1; $$->right = $3; $$->op = strdup("+");
      }
    | expression MINUS expression {
          $$ = createNode(NODE_BIN_OP); $$->left = $1; $$->right = $3; $$->op = strdup("-");
      }
    | expression TIMES expression {
          $$ = createNode(NODE_BIN_OP); $$->left = $1; $$->right = $3; $$->op = strdup("*");
      }
    | expression DIVIDE expression {
          $$ = createNode(NODE_BIN_OP); $$->left = $1; $$->right = $3; $$->op = strdup("/");
      }
    | expression MOD expression {
          $$ = createNode(NODE_BIN_OP); $$->left = $1; $$->right = $3; $$->op = strdup("%%");
      }
    | expression EQ expression {
          $$ = createNode(NODE_BIN_OP); $$->left = $1; $$->right = $3; $$->op = strdup("==");
      }
    | expression NEQ expression {
          $$ = createNode(NODE_BIN_OP); $$->left = $1; $$->right = $3; $$->op = strdup("!=");
      }
    | expression GT expression {
          $$ = createNode(NODE_BIN_OP); $$->left = $1; $$->right = $3; $$->op = strdup(">");
      }
    | expression LT expression {
          $$ = createNode(NODE_BIN_OP); $$->left = $1; $$->right = $3; $$->op = strdup("<");
      }
    | expression GE expression {
          $$ = createNode(NODE_BIN_OP); $$->left = $1; $$->right = $3; $$->op = strdup(">=");
      }
    | expression LE expression {
          $$ = createNode(NODE_BIN_OP); $$->left = $1; $$->right = $3; $$->op = strdup("<=");
      }
    | expression AND expression { 
          $$ = createNode(NODE_BIN_OP); $$->left = $1; $$->right = $3; $$->op = strdup("and");
      }
    | expression OR expression { 
          $$ = createNode(NODE_BIN_OP); $$->left = $1; $$->right = $3; $$->op = strdup("or");
      }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe na linha %d: %s\n", yylineno, s);
}