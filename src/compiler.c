/*
 * Este arquivo implementa as etapas centrais do compilador:
 *  - Análise Semântica: verificação de declarações, escopos, uso de variáveis e regras de controle.
 *  - Otimização da AST (Constant Folding): simplificação de operações constantes.
 *  - Geração de Código Python: transformação da AST em um código Python equivalente,
 *    incluindo regras especiais para for/while, switch/case e do...while.
 *
 * Também inclui o ponto de entrada principal do compilador.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "symtab.h"

extern ASTNode *createNode(NodeType type);
extern void freeAST(ASTNode *n);

static void printIndent(int indentLevel)
{
    for (int i = 0; i < indentLevel; i++)
        printf("    ");
}

static int controlDepth = 0;

extern void addSymbol(char *id, char *type);
extern Symbol *findSymbol(char *id);
extern void freeSymbolTable();

/* ===========================================================
   1. ANÁLISE SEMÂNTICA
   =========================================================== */
void semanticAnalysis(ASTNode *node)
{
    if (!node)
        return;

    /* Declarações agrupadas (ex.: int a, b, c;) */
    if (node->type == NODE_VAR_DECL_LIST)
    {
        ASTNode *decl = node->left;

        /* Registrar variáveis */
        while (decl && decl->type == NODE_VAR_DECL)
        {
            if (findSymbol(decl->id))
            {
                fprintf(stderr, "Erro Semantico: Variavel '%s' ja foi declarada!\n", decl->id);
                exit(1);
            }
            addSymbol(decl->id, decl->op ? decl->op : "int");
            decl = decl->next;
        }

        /* Analisar inicializações */
        decl = node->left;
        while (decl && decl->type == NODE_VAR_DECL)
        {
            if (decl->right)
                semanticAnalysis(decl->right);
            decl = decl->next;
        }

        if (node->next)
            semanticAnalysis(node->next);
        return;
    }

    switch (node->type)
    {
    case NODE_ASSIGN:
        if (!findSymbol(node->id))
        {
            fprintf(stderr, "Erro Semantico: Variavel '%s' usada antes de declaracao!\n", node->id);
            exit(1);
        }
        if (node->right)
            semanticAnalysis(node->right);
        break;

    case NODE_VAR_USE:
        if (!findSymbol(node->id))
        {
            fprintf(stderr, "Erro Semantico: Variavel '%s' usada antes de declaracao!\n", node->id);
            exit(1);
        }
        break;

    case NODE_SWITCH:
    case NODE_WHILE:
        if (node->condition)
            semanticAnalysis(node->condition);

        controlDepth++;
        if (node->left)
            semanticAnalysis(node->left);
        controlDepth--;
        break;

    case NODE_CASE:
        if (node->condition)
            semanticAnalysis(node->condition);
        if (node->left)
            semanticAnalysis(node->left);
        break;

    case NODE_BREAK:
        if (controlDepth == 0)
        {
            fprintf(stderr, "Erro Semantico: 'break' fora de loop/switch!\n");
            exit(1);
        }
        break;

    default:
        if (node->condition)
            semanticAnalysis(node->condition);
        if (node->left)
            semanticAnalysis(node->left);
        if (node->right)
            semanticAnalysis(node->right);
        if (node->else_body)
            semanticAnalysis(node->else_body);
        break;
    }

    if (node->next)
        semanticAnalysis(node->next);
}

/* ===========================================================
   2. OTIMIZAÇÃO (Constant Folding)
   =========================================================== */
void optimizeAST(ASTNode *node)
{
    if (!node)
        return;

    if (node->left)
        optimizeAST(node->left);
    if (node->right)
        optimizeAST(node->right);
    if (node->condition)
        optimizeAST(node->condition);
    if (node->else_body)
        optimizeAST(node->else_body);

    if (node->type == NODE_VAR_DECL_LIST && node->left)
        optimizeAST(node->left);

    /* Simplificação de operações constantes */
    if (node->type == NODE_BIN_OP &&
        node->left && node->right &&
        node->left->type == NODE_CONST_INT &&
        node->right->type == NODE_CONST_INT &&
        node->op)
    {
        int result = 0;

        if (strcmp(node->op, "+") == 0)
            result = node->left->intVal + node->right->intVal;
        else if (strcmp(node->op, "-") == 0)
            result = node->left->intVal - node->right->intVal;
        else if (strcmp(node->op, "*") == 0)
            result = node->left->intVal * node->right->intVal;
        else if (strcmp(node->op, "/") == 0 && node->right->intVal != 0)
            result = node->left->intVal / node->right->intVal;
        else
            goto skip_opt;

        node->type = NODE_CONST_INT;
        node->intVal = result;
        free(node->op);
        node->op = NULL;
    }

skip_opt:
    if (node->next)
        optimizeAST(node->next);
}

/* ===========================================================
   3. GERAÇÃO DE PYTHON
   =========================================================== */
void generatePython(ASTNode *node, int indentLevel)
{
    if (!node)
        return;

    switch (node->type)
    {
    case NODE_VAR_DECL_LIST:
    {
        ASTNode *curr = node->left;

        while (curr && curr->type == NODE_VAR_DECL)
        {
            printIndent(indentLevel);
            printf("%s", curr->id);

            if (curr->right)
            {
                printf(" = ");
                generatePython(curr->right, 0);
            }
            else
            {
                printf(curr->op && strcmp(curr->op, "float") == 0 ? " = 0.0" : " = 0");
            }

            printf("\n");
            curr = curr->next;
        }

        if (node->next)
            generatePython(node->next, indentLevel);
        return;
    }

    case NODE_SWITCH:
    {
        ASTNode *case_list = node->left;
        int first = 1;

        printIndent(indentLevel);
        printf("temp_switch_val = ");
        generatePython(node->condition, 0);
        printf("\n");

        while (case_list)
        {
            if (case_list->type != NODE_CASE)
                break;

            printIndent(indentLevel);

            if (case_list->condition)
            {
                printf(first ? "if temp_switch_val == " : "elif temp_switch_val == ");
                generatePython(case_list->condition, 0);
                printf(":\n");
                first = 0;
            }
            else
            {
                printf("else:\n");
            }

            ASTNode *body = case_list->left;

            while (body)
            {
                if (body->type != NODE_BREAK)
                    generatePython(body, indentLevel + 1);
                body = body->next;
            }

            case_list = case_list->next;
        }

        if (node->next)
            generatePython(node->next, indentLevel);
        return;
    }

    case NODE_ASSIGN:
        printIndent(indentLevel);
        printf("%s = ", node->id);
        generatePython(node->right, 0);
        printf("\n");
        break;

    case NODE_RETURN:
        printIndent(indentLevel);
        printf("return ");
        node->left ? generatePython(node->left, 0) : printf("None");
        printf("\n");
        break;

    case NODE_SCANF:
        if (node->right && node->right->type == NODE_ADDRESS_OF)
        {
            printIndent(indentLevel);
            printf("%s = ", node->right->id);

            if (strstr(node->left->id, "%f") || strstr(node->left->id, "%F"))
                printf("float(input())\n");
            else
                printf("int(input())\n");
        }
        break;

    case NODE_PRINTF:
        printIndent(indentLevel);
        printf("print(");
        if (node->left)
            generatePython(node->left, 0);
        printf(")\n");
        break;

    case NODE_IF:
        printIndent(indentLevel);
        printf("if ");
        generatePython(node->condition, 0);
        printf(":\n");

        if (node->left)
            generatePython(node->left, indentLevel + 1);

        if (node->else_body)
        {
            printIndent(indentLevel);
            printf("else:\n");
            generatePython(node->else_body, indentLevel + 1);
        }

        if (node->next)
            generatePython(node->next, indentLevel);
        return;

    case NODE_WHILE:
        printIndent(indentLevel);

        if (node->op && strcmp(node->op, "do_while") == 0)
        {
            /* Simulação do do...while */
            if (node->left)
                generatePython(node->left, indentLevel);

            printf("while ");
            generatePython(node->condition, 0);
            printf(":\n");

            if (node->left)
                generatePython(node->left, indentLevel + 1);
        }
        else
        {
            printf("while ");
            generatePython(node->condition, 0);
            printf(":\n");

            if (node->left)
                generatePython(node->left, indentLevel + 1);
        }

        if (node->next)
            generatePython(node->next, indentLevel);
        return;

    case NODE_FOR:
        if (node->init_stmt)
            generatePython(node->init_stmt, indentLevel);

        printIndent(indentLevel);
        printf("while ");
        generatePython(node->condition, 0);
        printf(":\n");

        if (node->left)
            generatePython(node->left, indentLevel + 1);
        if (node->incr_stmt)
            generatePython(node->incr_stmt, indentLevel + 1);

        if (node->next)
            generatePython(node->next, indentLevel);
        return;

    case NODE_BIN_OP:
        printf("(");
        if (node->left)
            generatePython(node->left, 0);
        if (node->op)
            printf(" %s ", node->op);
        if (node->right)
            generatePython(node->right, 0);
        printf(")");
        break;

    case NODE_CONST_INT:
        printf("%d", node->intVal);
        break;

    case NODE_CONST_STRING:
        printf("%s", node->id);
        break;

    case NODE_VAR_USE:
        printf("%s", node->id);
        break;

    case NODE_BREAK:
        printIndent(indentLevel);
        printf("break\n");
        break;

    case NODE_INCREMENT:
        printIndent(indentLevel);
        printf("%s += 1\n", node->id);
        break;

    case NODE_DECREMENT:
        printIndent(indentLevel);
        printf("%s -= 1\n", node->id);
        break;

    default:
        if (node->condition)
            generatePython(node->condition, indentLevel);
        if (node->left)
            generatePython(node->left, indentLevel);
        if (node->right)
            generatePython(node->right, indentLevel);
        if (node->else_body)
            generatePython(node->else_body, indentLevel);
        break;
    }
}

/* ===========================================================
   4. MAIN
   =========================================================== */

extern ASTNode *root;
extern int yyparse();
extern FILE *yyin;

int main(int argc, char **argv)
{
    if (argc > 1)
    {
        yyin = fopen(argv[1], "r");
        if (!yyin)
        {
            fprintf(stderr, "Falha ao abrir arquivo %s\n", argv[1]);
            return 1;
        }
    }

    if (yyparse() != 0)
    {
        fprintf(stderr, "\nERRO FATAL: Falha na análise sintatica (Parser).\n");
        freeSymbolTable();
        return 1;
    }

    semanticAnalysis(root);
    optimizeAST(root);

    printf("def main():\n");
    generatePython(root, 1);

    printf("\nif __name__ == \"__main__\":\n");
    printf("    main()\n");

    freeSymbolTable();
    return 0;
}
