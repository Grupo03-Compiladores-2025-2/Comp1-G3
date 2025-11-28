/*
 * Implementação das funções da AST.
 * Inclui criação de nós, liberação recursiva de memória e
 * impressão da árvore sintática para debug.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"

static char *strdup_s(const char *s)
{
  if (!s)
    return NULL;

  char *r = malloc(strlen(s) + 1);
  if (!r)
    return NULL;

  strcpy(r, s);
  return r;
}

ASTNode *createNode(NodeType type)
{
  ASTNode *n = calloc(1, sizeof(ASTNode));
  if (!n)
  {
    fprintf(stderr, "FATAL: malloc falhou\n");
    exit(1);
  }

  n->type = type;
  return n;
}

void freeAST(ASTNode *n)
{
  if (!n)
    return;

  freeAST(n->condition);
  freeAST(n->left);
  freeAST(n->right);
  freeAST(n->else_body);
  freeAST(n->next);

  if (n->id)
    free(n->id);
  if (n->op)
    free(n->op);

  free(n);
}

static void indent(int n)
{
  for (int i = 0; i < n; ++i)
  {
    putchar(' ');
  }
}

void printAST(ASTNode *n, int level)
{
  if (!n)
    return;

  indent(level);

  switch (n->type)
  {
  case NODE_PROGRAM:
    printf("PROGRAM\n");
    break;
  case NODE_FUNC_DECL:
    printf("FUNC_DECL\n");
    break;
  case NODE_VAR_DECL:
    printf("VAR_DECL %s (op=%s)\n", n->id ?: "(null)", n->op ?: "(null)");
    break;
  case NODE_ASSIGN:
    printf("ASSIGN %s\n", n->id ?: "(null)");
    break;
  case NODE_IF:
    printf("IF\n");
    break;
  case NODE_WHILE:
    printf("WHILE\n");
    break;
  case NODE_FOR:
    printf("FOR\n");
    break;
  case NODE_PRINTF:
    printf("PRINTF\n");
    break;
  case NODE_RETURN:
    printf("RETURN\n");
    break;
  case NODE_BIN_OP:
    printf("BIN_OP %s\n", n->op ?: "(null)");
    break;
  case NODE_CONST_INT:
    printf("INT %d\n", n->intVal);
    break;
  case NODE_CONST_FLOAT:
    printf("FLOAT %g\n", n->floatVal);
    break;
  case NODE_VAR_USE:
    printf("VAR_USE %s\n", n->id ?: "(null)");
    break;
  case NODE_SWITCH:
    printf("SWITCH\n");
    break;
  case NODE_CASE:
    printf("CASE\n");
    break;
  case NODE_BREAK:
    printf("BREAK\n");
    break;
  default:
    printf("UNKNOWN NODE\n");
    break;
  }

  if (n->condition)
    printAST(n->condition, level + 2);
  if (n->left)
    printAST(n->left, level + 2);
  if (n->right)
    printAST(n->right, level + 2);
  if (n->else_body)
    printAST(n->else_body, level + 2);
  if (n->next)
    printAST(n->next, level);
}
