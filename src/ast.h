/*
 * Implementa a estrutura de Árvore Sintática Abstrata (AST).
 * Define os tipos de nós, a estrutura de cada nó, e funções para criar,
 * liberar e imprimir a árvore. A AST representa o código-fonte,
 * permitindo análises semânticas e geração de código.
 */

#ifndef AST_H
#define AST_H

typedef enum
{
    NODE_PROGRAM,
    NODE_FUNC_DECL,
    NODE_VAR_DECL,
    NODE_VAR_DECL_LIST,
    NODE_ASSIGN,
    NODE_IF,
    NODE_WHILE,
    NODE_FOR,
    NODE_PRINTF,
    NODE_RETURN,
    NODE_BIN_OP,
    NODE_CONST_INT,
    NODE_CONST_FLOAT,
    NODE_VAR_USE,
    NODE_SWITCH,
    NODE_CONST_STRING,
    NODE_INCREMENT,
    NODE_DECREMENT,
    NODE_SCANF,
    NODE_ADDRESS_OF,
    NODE_CASE,
    NODE_BREAK
} NodeType;

typedef struct ASTNode
{
    NodeType type;

    int intVal;
    float floatVal;
    char *id;
    char *op;

    struct ASTNode *left;
    struct ASTNode *right;
    struct ASTNode *next;
    struct ASTNode *condition;
    struct ASTNode *else_body;
    struct ASTNode *init_stmt;
    struct ASTNode *incr_stmt;

} ASTNode;

ASTNode *createNode(NodeType type);
void freeAST(ASTNode *node);

#endif
