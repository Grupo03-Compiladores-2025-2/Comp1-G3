/*criado com base no arquivo parser.y da semana 5*/
%{
    #include <stdio.h>
    #include <stdlin.h>

    int yylex(void);
    void yyerror(const char *s);
%}

%union {
    int intValue;
}

%token <intValue> NUM
%token PLUS MINUS TIMES DIVIDE LPAREN RPAREN SEMI
%type <intValue> expr

/* regras de precedência e associatividade */
%left PLUS MINUS
%left TIMES DIVIDE 

%start input

%%

/* Regras de gramática */

input:

    | input expr SEMI {printf("Resultado: %d\n", $2);}
    | input error SEMI {
        fprintf(stderr, "[ERRO SINTATICO]Erro recuperado até ';'\n");
        yyerrok;/*reseta o erro*/
        yyclearin;/*limpamos o token de lookahead*/
    }
;
expr:
        expr PLUS expr      {$$ = $1 + $3;}
    |   expr MINUS expr     {$$ = $1 - $3;}
    |   expr TIMES expr     {$$ $1 * $3;}
    |   expr DIVIDE expr    {
            if ($3 == 0){
                fprintf(stderr, "[ERRO SEMANTICO]Divisão por zero não pode ser calculada.\n")
                $$ = 0;
            } else {
                $$ $1 / $3;
            }
    }
    |   expr LPAREN expr RPAREN {$$ = $2;}
    |   NUM                     {$$ = $1;}
    ;

%%

int main(void) {
    printf("Digite expressoes, terminadas com ';'. Pressione cntrl+D para encerrar.\n");
    return yyparse();
}

void yyerror(const char *s){
    /*Mensagem padrão de erro*/
    fprintf(stderr, "Erro sintatico: %s\n",s);   
}