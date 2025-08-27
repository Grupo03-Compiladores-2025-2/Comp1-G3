# Compilação do projeto

## Compilar arquivos Flex e Bison

```
flex lexer/lexer.l
bison -d parser/parser.y
```

## Compilar código C

```
gcc -o compilador lex.yy.c parser.tab.c -lfl
```

## Executar programa compilado

```
./compilador
```


