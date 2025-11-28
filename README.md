# Comp.TXT – Compilador C → Python 3

O Comp.TXT é um compilador desenvolvido pelo Grupo G03 na disciplina de Compiladores (FGA0003). Seu propósito é traduzir programas escritos em C para código equivalente em Python 3, seguindo o fluxo clássico de compilação: análise léxica, análise sintática, geração de AST, análise semântica e geração de código.

O resultado final é um código Python fiel à lógica original e totalmente executável.

## 👥 Equipe de Desenvolvimento
<table><thead><tr><th></th><th>Nome</th><th>Matrícula</th><th>Principais Contribuições</th></tr></thead><tbody><tr><td><img src="https://avatars.githubusercontent.com/u/58157127?v=4" alt="Image" width="80" height="80"></td><td>Carlos Eduardo Mendes de Mesquita</td><td>190085584</td><td>Desenvolvimento da Análise Léxica e Sintática,<br>Implementação da Tabela de Símbolos.</td></tr><tr><td><img src="https://avatars.githubusercontent.com/u/56442048?v=4" alt="Image" width="80" height="80"></td><td>Eric Akio Lages Nishimura</td><td>190105895</td><td>Definição de Escopo do Projeto,<br>Desenvolvimento da Análise Léxica.</td></tr><tr><td><img src="https://avatars.githubusercontent.com/u/91230616?v=4" width="80" height="80"></td><td>Esther Silva Cardoso de Sousa</td><td>190106034</td><td>Desenvolvimento de Testes Positivos<br>Testes Negativos, Ajustes de Testes.</td></tr>
<tr><td><img src="https://avatars.githubusercontent.com/u/92321749?v=4" alt="Image" width="80" height="80"></td><td>Laís Cecília Soares Paes</td><td>211029512</td><td>Definição de Escopo do Projeto, Ajustes de Testes,<br>Desenvolvimento da Análise Semântica.</td></tr><tr><td><img src="https://avatars.githubusercontent.com/u/73966483?s=400&u=9370a079379c5c5891f9be5b51840a5f1ec50634&v=4" alt="Image" width="80" height="80"></td><td>Yves Gustavo Ribeiro Pimenta</td><td>190097043</td><td>Desenvolvimento da Análise Sintática e Semântica,<br>Geração de Código Intermediário e<br>Geração de Código Python.</td></tr></tbody></table>

## 📌 Funcionalidades Implementadas

O compilador atualmente suporta um subconjunto bem definido da linguagem C, traduzindo suas construções para Python.

1. Tipos e Declarações
    - Suporte a int e float.

    - Declarações com ou sem inicialização (incluindo múltiplas declarações com vírgula).

    - Reconhecimento de literais inteiros, floats e strings.

2. Operadores e Expressões
    - Aritméticos: ```+```, ```-```, ```*```, ```/```, ```%```
    
    - Relacionais: ```==```, ```!=```, ```>```, ```<```, ```>=```, ```<=```
    
    - Lógicos: ``` &&```, ```||```, ```!```
    
    - Atribuição: ```=```

    - Incremento/Decremento: ```x++```, ```x--``` (pós-fixados)

3. Estruturas de Controle
    - ```if```, ```if/else```
    
    - ```while```
    
    - ```do/while```
    
    - ```for```
    
    - ```switch/case```

4. Entrada/Saída
    - ```printf()``` → ```print()```
    - ```scanf()``` → ```input()```

## ⚠️ Limitações e Escopo Restrito
O compilador foi projetado com escopo reduzido, portanto:
- Não há suporte para: char, double, long, ponteiros, arrays.
- Somente main() é suportada. Funções customizadas ainda não são traduzidas.
- Pré-processamento é tratado de forma simplificada (#include, por exemplo).


## ⚙️ Compilação e Execução com Makefile
Certifique-se de ter instalado:
- Flex — análise léxica

- Bison — análise sintática

- GCC — compilação dos módulos C
  
### Compilação (Gerando o Executável)
Gera o executável c2py:
```
make
```

### Limpeza dos Artefatos
Remove arquivos gerados automaticamente:
```
make clean
```

### Executar o Compilador
Traduz um arquivo .c para Python:
```
./c2py <arquivo_entrada>.c > <arquivo_saida>.py
```

### Executar o código Python resultante
```
python3 <arquivo_saida>.py
```