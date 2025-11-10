# Comp.TXT
**Compiladores**<br>
**Código da Disciplina**: FGA0003<br>
**Número do Grupo**: G03<br>

Este repositório é para o projeto desenvolvido pelo grupo 03 na disciplina de Compiladores.
O trabalho é aplicar os conceitos de Compiladores estudados em sala, implementando um compilador que traduz programas escritos em C para programas equivalentes em Python.

<table><center><thead>
  <tr>
    <th colspan="4">👥 Membros do grupo</th>
  </tr></thead>
<tbody>
  <tr>
    <td></td>
    <td>Nome</td>
    <td>Matrícula</td>
    <td>Etapas de Desenvolvimento</td>
  </tr>
  <tr>
    <td rowspan="3"><img src="https://avatars.githubusercontent.com/u/58157127?v=4" width="100" height="100"></td>
    <td rowspan="3"><a href="https://github.com/CarlosEduardoMendesdeMesquita" target="_blank" rel="noopener noreferrer">Carlos Eduardo</a><br><a href="https://github.com/CarlosEduardoMendesdeMesquita" target="_blank" rel="noopener noreferrer">Mendes de Mesquita</a></td>
    <td rowspan="3">190085584</td>
    <td>Desenvolvimento da Análise Léxica;</td>
  </tr>
  <tr>
    <td>Desenvolvimento da Análise Sintática;</td>
  </tr>
  <tr>
    <td>Desenvolvimento da Tabela de Símbolos.</td>
  </tr>
  <tr>
    <td rowspan="2"><img src="https://avatars.githubusercontent.com/u/56442048?v=4" width="100" height="100"></td>
    <td rowspan="2"><a href="https://github.com/eric-kingu" target="_blank" rel="noopener noreferrer">Eric Akio</a><br><a href="https://github.com/eric-kingu" target="_blank" rel="noopener noreferrer">Lages Nishimura</a></td>
    <td rowspan="2">190105895</td>
    <td>Definição de Escopo do projeto;</td>
  </tr>
  <tr>
    <td>Desenvolvimento da Análise Léxica</td>
  </tr>
  <tr>
    <td rowspan="3"><img src="https://avatars.githubusercontent.com/u/91230616?v=4" width="100" height="100"></td>
    <td rowspan="3"><a href="https://github.com/EstherSousa" target="_blank" rel="noopener noreferrer">Esther Silva</a><br><a href="https://github.com/EstherSousa" target="_blank" rel="noopener noreferrer">Cardoso de Sousa</a></td>
    <td rowspan="3">190106034</td>
    <td>Desenvolvimento de Testes Positivos;</td>
  </tr>
  <tr>
    <td>Desenvolvimento de Testes Negativos;</td>
  </tr>
  <tr>
    <td>Ajustes de Testes.</td>
  </tr>
  <tr>
    <td rowspan="3"><img src="https://avatars.githubusercontent.com/u/92321749?v=4" width="100" height="100"><br></td>
    <td rowspan="3"><a href="https://github.com/Laisczt" target="_blank" rel="noopener noreferrer">Laís Cecília</a><br><a href="https://github.com/Laisczt" target="_blank" rel="noopener noreferrer">Soares Paes</a><br></td>
    <td rowspan="3">211029512<br></td>
    <td>Definição de Escopo do projeto;</td>
  </tr>
  <tr>
    <td>Ajustes de Testes;</td>
  </tr>
  <tr>
    <td>Desenvolvimento da Análise Semântica.</td>
  </tr>
  <tr>
    <td rowspan="3"><img src="https://avatars.githubusercontent.com/u/73966483?s=400&u=9370a079379c5c5891f9be5b51840a5f1ec50634&v=4" width="100" height="100"></td>
    <td rowspan="3"><a href="https://github.com/Yvestxt" target="_blank" rel="noopener noreferrer">Yves Gustavo</a><br><a href="https://github.com/Yvestxt" target="_blank" rel="noopener noreferrer">Ribeiro Pimenta</a></td>
    <td rowspan="3">190097043</td>
    <td>Desenvolvimento de Análise Sintática;</td>
  </tr>
  <tr>
    <td>Desenvolvimento da Análise Semântica;</td>
  </tr>
  <tr>
    <td>Geração de Código Intermediário</td>
  </tr>
</tbody></center></table>

## 📌 O Projeto

O trabalho consiste em implementar um compilador, dividido em duas etapas principais:
 1. Análise: 
	 - Léxica;
	 - Sintática;
	 - Semântica;
2. Síntese:
	- Código Intermediário;
	- Otimização de Código
	- Geração de Código
## ⚙️ Compilação e Execução

Para compilar e rodar o projeto, é necessário ter instalado:
- Flex – para geração do analisador léxico
- Bison – para geração do analisador sintático
- GCC – para compilação do código em C
  
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


