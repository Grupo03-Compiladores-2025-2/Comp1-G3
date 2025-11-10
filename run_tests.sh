#!/bin/bash
echo "Executando testes de análise semântica..."
make > /dev/null 2>&1
for file in testes/*.c; do
    echo "=========================="
    echo "Arquivo: $file"
    echo "--------------------------"
    ./compilador < "$file"
    echo ""
done