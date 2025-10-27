#ifndef AST_H
#define AST_H

#include "tipos.h"

NoAST *criarNoNum(int valor);
NoAST *criarNoId(char *nome);
NoAST *criarNoOp(char operador, NoAST *esq, NoAST *dir);
void imprimirAST(NoAST *raiz);

#endif