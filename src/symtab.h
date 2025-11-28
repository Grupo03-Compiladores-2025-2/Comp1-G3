/*
 * Este arquivo define a estrutura e a API da tabela de símbolos utilizada pelo compilador.
 * A tabela armazena variáveis declaradas (nome e tipo) e oferece funções para:
 *   - Inserir símbolos
 *   - Buscar símbolos
 *   - Liberar toda a tabela ao final
 */

#ifndef SYMTAB_H
#define SYMTAB_H

typedef struct Symbol
{
    char *name;
    char *type; // "int", "float", etc.
    struct Symbol *next;
} Symbol;

void addSymbol(char *name, char *type);
Symbol *findSymbol(char *name);
void freeSymbolTable();

#endif
