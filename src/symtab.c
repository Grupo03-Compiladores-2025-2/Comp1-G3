/*
 * Implementação da tabela de símbolos usada na fase semântica do compilador.
 *
 * A estrutura atual é uma lista encadeada simples, armazenando:
 *     - nome da variável
 *     - tipo declarado
 *
 * As operações incluem:
 *     - Inserção de novos símbolos
 *     - Busca por nome
 *     - Liberação da tabela ao final da compilação
 *
 * Obs.: Não há controle de escopos; toda a tabela é global.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

Symbol *symbolTable = NULL;

static char *strdup_safe(const char *s)
{
    if (!s)
        return NULL;
    char *r = strdup(s);
    if (!r)
    {
        fprintf(stderr, "FATAL: strdup falhou\n");
        exit(1);
    }
    return r;
}

void addSymbol(char *name, char *type)
{
    if (!name)
    {
        fprintf(stderr, "FATAL: addSymbol recebeu name == NULL\n");
        exit(1);
    }
    if (!type)
    {
        type = "int";
    }

    Symbol *existing = findSymbol(name);
    if (existing)
    {
        fprintf(stderr, "Aviso: addSymbol detectou duplicata para '%s'\n", name);
    }

    Symbol *newSym = (Symbol *)malloc(sizeof(Symbol));
    if (!newSym)
    {
        fprintf(stderr, "FATAL: malloc falhou em addSymbol\n");
        exit(1);
    }

    newSym->name = strdup_safe(name);
    newSym->type = strdup_safe(type);
    newSym->next = symbolTable;
    symbolTable = newSym;
}

Symbol *findSymbol(char *name)
{
    if (!name)
        return NULL;

    Symbol *current = symbolTable;

    while (current != NULL)
    {
        if (strcmp(current->name, name) == 0)
        {
            return current;
        }
        current = current->next;
    }

    return NULL;
}

void freeSymbolTable()
{
    Symbol *current = symbolTable;

    while (current != NULL)
    {
        Symbol *temp = current;
        current = current->next;

        free(temp->name);
        free(temp->type);
        free(temp);
    }

    symbolTable = NULL;
}
