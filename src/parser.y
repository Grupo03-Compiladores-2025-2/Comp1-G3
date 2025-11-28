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

%union {
    int intValue;
    float floatValue;
    char* strValue;
    struct ASTNode* node;
}

/* Tokens */
%token <strValue> IDENT
%token <strValue> STRING_LITERAL
%token <intValue> NUM
%token <floatValue> FLOAT

%token KW_IF KW_ELSE KW_WHILE KW_FOR KW_RETURN KW_INT KW_FLOAT KW_VOID KW_PRINTF KW_SCANF
%token KW_SWITCH KW_CASE KW_DEFAULT KW_BREAK
%token EQ NEQ GE LE GT LT AND OR NOT ASSIGN
%token PLUS MINUS TIMES DIVIDE MOD 
%token LPAREN RPAREN LBRACE RBRACE SEMI COMMA
%token COLON
%token AMPERSAND
%token KW_DO
%token INC_OP DEC_OP

%type <node> program statement_list statement expression var_decl declaration_list declaration case_list case_clause
%type <node> simple_assign_stmt simple_incr_decr_stmt 

%left OR
%left AND
%left EQ NEQ GT LT GE LE
%left PLUS MINUS
%left TIMES DIVIDE MOD
%nonassoc NOT

%start program

%%

/* Programa */
program:
      KW_VOID IDENT LPAREN RPAREN LBRACE statement_list RBRACE { $$ = $6; root = $$; }
    | KW_INT IDENT LPAREN RPAREN LBRACE statement_list RBRACE  { $$ = $6; root = $$; }
    | LBRACE statement_list RBRACE                             { $$ = $2; root = $$; }
    ;

/* Lista de statements */
statement_list:
      statement statement_list { $1->next = $2; $$ = $1; }
    | /* vazio */              { $$ = NULL; }
    ;

/* Statements */
statement:
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
    | KW_PRINTF LPAREN expression RPAREN SEMI {
          $$ = createNode(NODE_PRINTF);
          $$->left = $3;
      }
    | KW_SCANF LPAREN expression COMMA expression RPAREN SEMI { 
          $$ = createNode(NODE_SCANF);
          $$->left = $3;
          $$->right = $5;
      }
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
    // REGRA FOR CORRIGIDA: Usa regras auxiliares e gerencia SEMI
    | KW_FOR LPAREN simple_assign_stmt SEMI expression SEMI simple_incr_decr_stmt RPAREN LBRACE statement_list RBRACE {
          $$ = createNode(NODE_FOR);
          $$->init_stmt = $3;
          $$->condition = $5; 
          $$->incr_stmt = $7;
          $$->left = $10;     
      }
    | KW_RETURN expression SEMI { // <-- CORRIGIDO: Removida a linha duplicada
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

/* ---------- REGRAS AUXILIARES PARA FOR (SEM PONTO E VÍRGULA) ---------- */

simple_assign_stmt:
      IDENT ASSIGN expression {
          $$ = createNode(NODE_ASSIGN);
          $$->id = $1;
          $$->right = $3;
      }
    | var_decl { // Permite declaração na inicialização do for (ex: for(int i=0;...))
          $$ = $1;
      }
    | /* vazio */ { $$ = NULL; } // Permite inicialização vazia (ex: for(;...;...))
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
    | IDENT ASSIGN expression { // Permite reatribuição no incremento (ex: i = i + 1)
          $$ = createNode(NODE_ASSIGN);
          $$->id = $1;
          $$->right = $3;
      }
    | /* vazio */ { $$ = NULL; } // Permite incremento vazio (ex: for(...;...;))
    ;


/* ---------- CASE LIST e CASE CLAUSE ---------- */

case_list:
      case_clause case_list { $1->next = $2; $$ = $1; }
    | /* vazio */            { $$ = NULL; }
    ;

case_clause:
      KW_CASE expression COLON statement_list {
          $$ = createNode(NODE_CASE);
          $$->condition = $2;
          $$->left = $4;
      }
    | KW_DEFAULT COLON statement_list {
          $$ = createNode(NODE_CASE);
          $$->condition = NULL; /* sinaliza default */
          $$->left = $3;
      }
    ;

/* ---------- DECLARAÇÃO DE VARIÁVEIS COM VÍRGULA ---------- */

var_decl:
      KW_INT declaration_list {
          $$ = createNode(NODE_VAR_DECL_LIST); // Cria o nó container
          $$->left = $2; // Aponta left para o início da lista de declarações
          
          ASTNode *tmp = $2;
          while (tmp) {
              tmp->op = strdup("int");
              tmp = tmp->next;
          }
      }
    | KW_FLOAT declaration_list {
          $$ = createNode(NODE_VAR_DECL_LIST); // Cria o nó container
          $$->left = $2; // Aponta left para o início da lista de declarações
          
          ASTNode *tmp = $2;
          while (tmp) {
              tmp->op = strdup("float");
              tmp = tmp->next;
          }
      }
    ;

/* Lista de declarações separadas por vírgula */
declaration_list:
      declaration { $$ = $1; }
    | declaration COMMA declaration_list {
          $1->next = $3;
          $$ = $1;
      }
    ;

/* declaração unitária: IDENT ou IDENT = expression */
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

/* ---------- EXPRESSÕES ---------- */
expression:
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
    | AMPERSAND IDENT {
          $$ = createNode(NODE_ADDRESS_OF);
          $$->id = $2;
      }
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
    
    // --- OPERADORES LÓGICOS (NOVOS) ---
    | expression AND expression { 
          $$ = createNode(NODE_BIN_OP); $$->left = $1; $$->right = $3; $$->op = strdup("and");
      }
    | expression OR expression { 
          $$ = createNode(NODE_BIN_OP); $$->left = $1; $$->right = $3; $$->op = strdup("or");
      }
    
    // --- OPERADORES RELACIONAIS ---
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
    
    | LPAREN expression RPAREN { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Erro de sintaxe na linha %d: %s\n", yylineno, s);
}