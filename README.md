# Compiladores 1
**Código da Disciplina**: FGA0003<br>
**Número do Grupo**: G03<br>

Este repositório é para o projeto desenvolvido pelo grupo 3 na disciplina de Compiladores 1.
O trabalho é aplicar os conceitos de análise léxica e sintática estudados em sala, implementando um compilador que traduz programas escritos em Python para programas equivalentes em C.

## 👥 Membros do grupo
<center> <table style="width: 100%;"> <tr> <td align="center"> <a href="https://github.com/CarlosEduardoMendesdeMesquita"> <img style="border-radius: 50%;" src="https://avatars.githubusercontent.com/u/58157127?v=4" width="100px;" alt="Carlos"/> <br/> <sub><b>Carlos Eduardo Mendes de Mesquita</b></sub> <br/> </a> <sub><b>190085584</b></sub> </td> <td align="center"> <a href="https://github.com/eric-kingu"> <img style="border-radius: 50%;" src="https://avatars.githubusercontent.com/u/56442048?v=4" width="100px;" alt="Eric"/> <br/> <sub><b>Eric Akio Lages Nishimura</b></sub> <br/> </a> <sub><b>190105895</b></sub> </td> <td align="center"> <a href="https://github.com/EstherSousa"> <img style="border-radius: 50%;" src="https://avatars.githubusercontent.com/u/91230616?v=4" width="100px;" alt="Esther"/> <br/> <sub><b>Esther Silva Cardoso de Sousa</b></sub> <br/> </a> <sub><b>190106034</b></sub> </td> <td align="center"> <a href="https://github.com/Laisczt"> <img style="border-radius: 50%;" src="https://avatars.githubusercontent.com/u/92321749?v=4" width="100px;" alt="Laís"/> <br/> <sub><b>Laís Cecília Soares Paes</b></sub> <br/> </a> <sub><b>211029512</b></sub> </td> <td align="center"> <a href="https://github.com/Yvestxt"> <img style="border-radius: 50%;" src="https://avatars.githubusercontent.com/u/73966483?v=4" width="100px;" alt="Yves"/> <br/> <sub><b>Yves Gustavo Ribeiro Pimenta</b></sub> <br/> </a> <sub><b>190097043</b></sub> </td> </tr> </table> </center>

## 📌 O Projeto

O trabalho consiste em implementar um compilador, dividido em duas etapas principais:
1. Analisador Léxico (Lexer) – Responsável por ler o código fonte em Python e quebrá-lo em tokens, utilizando Flex.
2. Analisador Sintático (Parser) – Utiliza os tokens gerados para verificar se a estrutura do código está de acordo com a gramática definida, e em seguida traduz o código para a linguagem C, utilizando Bison.

## ⚙️ Compilação e Execução

Para compilar e rodar o projeto, é necessário ter instalado:
- Flex – para geração do analisador léxico
- Bison – para geração do analisador sintático
- GCC – para compilação do código em C
- 
### 1. Compilar arquivos Flex e Bison

```
flex lexer/lexer.l
bison -d parser/parser.y
```

### 2. Compilar código C

```
gcc -o compilador lex.yy.c parser.tab.c -lfl
```

### 3. Executar programa compilado

```
./compilador
```


