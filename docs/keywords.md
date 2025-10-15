# Palavras-chave nas linguagens

Este artefato é dedicado a listar na tabela 1, as palavras-chave protegidas na linguagem C e seu equivalente na linguagem Python que não fazem manipulação de memória.

**Tabela 1:** Palavras-chave

| Token em C | Equivalente em python | Descrição | Obs. |
|------------|-----------------------|-----------|------|
| int | int | número inteiro | |
| char | str | caracter | |
| float | float* | ponto flutuante | python trata todos os floats como doubles |
| double | float | ponto flutuante mais preciso |  |
| struct | class* | especificador de estrutura | structs não podem ter métodos |
| goto |  | retorna ou avança o código para um rótulo dentro da função | |
| return | return retorna uma expressão ou um resultado para a chamada de função | |
| break | break | obriga o código a sair do loop | |
| continue | continue | obriga o código a ir para a parte do loop que altera a variável de corrida | |
| if | if | define um fluxo condicional | |
| else | else | fluxo caso a condicional do if falhar | C: else if; <br>py: elif/else |
| for | for | laço com número definido de repetições | |
| do | | executa uma iteração do while antes de verificar a condição | |
| while | while | laço com um número não definido de repetições (condicional) | |
| switch | | define uma família de fluxos condicionais em que todos os fluxos dependem de um valor | py: if/elif |
| case | | um fluxo dentro do switch | py: if/elif |
| default |  | fluxo dentro do "switch" caso todos os "case" falhem | else |
|  | len() | comprimento de estrutura vetorial | |
| typeof() | type() | tipo de um valor ou variável | |
| '&&' | and | operador lógico E | |
| '||' | or | operador lógico OU | |
| '!' | not | operador lógico "não" | |
| true | True | valor lógico verdadeiro | |
| false | False | valor lógico falso | |
| enum | class{nome}(enum.Enum) | estrutura que associa variáveis a valores numéricos | py: precisa importar biblioteca enum |