# Variaveis de Configuracao
CC = gcc
FLEX = flex
BISON = bison
SRC_DIR = src
TEST_DIR = testes
GEN_DIR = generated
COMPILER_NAME = c2py_compiler
LIBS =
INCLUDES = -I$(GEN_DIR) -I$(SRC_DIR)

# Arquivos fonte C (agora inclui ast.c!)
C_SOURCES = $(SRC_DIR)/compiler.c $(SRC_DIR)/symtab.c $(SRC_DIR)/ast.c

FLEX_SOURCE = $(SRC_DIR)/scanner.l
BISON_SOURCE = $(SRC_DIR)/parser.y

# Arquivos gerados
PARSER_C = $(GEN_DIR)/parser.tab.c
PARSER_H = $(GEN_DIR)/parser.tab.h
LEXER_C = $(GEN_DIR)/lex.yy.c

OBJECTS = $(C_SOURCES:.c=.o) $(GEN_DIR)/parser.tab.o $(GEN_DIR)/lex.yy.o

.PHONY: all clean test

# ----------------- REGRAS PRINCIPAIS -----------------

all: directories $(COMPILER_NAME)

directories:
	@mkdir -p $(GEN_DIR)
	@mkdir -p bin

$(COMPILER_NAME): $(OBJECTS)
	$(CC) $(INCLUDES) $^ -o $(COMPILER_NAME) $(LIBS)
	@mv $(COMPILER_NAME) bin/
	@echo "Compilador criado com sucesso em bin/$(COMPILER_NAME)"

# ----------------- COMPILAÇÃO C -----------------

$(SRC_DIR)/%.o: $(SRC_DIR)/%.c $(SRC_DIR)/ast.h $(SRC_DIR)/symtab.h $(PARSER_H)
	$(CC) $(INCLUDES) -c $< -o $@

$(GEN_DIR)/parser.tab.o: $(PARSER_C) $(PARSER_H)
	$(CC) $(INCLUDES) -c $< -o $@

$(GEN_DIR)/lex.yy.o: $(LEXER_C) $(PARSER_H)
	$(CC) $(INCLUDES) -c $< -o $@

# ----------------- GERAÇÃO FLEX/BISON -----------------

$(PARSER_C) $(PARSER_H): $(BISON_SOURCE) $(SRC_DIR)/ast.h
	$(BISON) -d -o parser.tab.c $<
	@mv parser.tab.c $(GEN_DIR)/
	@mv parser.tab.h $(GEN_DIR)/

$(LEXER_C): $(FLEX_SOURCE) $(PARSER_H)
	$(FLEX) -o $(LEXER_C) $<

# ----------------- TESTES -----------------

test: all
	@echo "\n========================================"
	@echo "INICIANDO COMPILACAO DOS TESTES"
	@echo "========================================\n"
	
	@for test_file in $(TEST_DIR)/*.c; do \
		OUTPUT_FILE="$${test_file/.c/.py}"; \
		echo "--- Compilando $$test_file para $$OUTPUT_FILE ---"; \
		./bin/$(COMPILER_NAME) $$test_file > $$OUTPUT_FILE; \
		if [ $$? -eq 0 ]; then \
			echo "COMPILACAO BEM-SUCEDIDA. Arquivo Python salvo."; \
		else \
			echo "ERRO DURANTE A COMPILACAO."; \
		fi; \
		echo ""; \
	done
	
	@echo "\n========================================"
	@echo "TESTES CONCLUIDOS. Revisar manualmente os arquivos .py em $(TEST_DIR)/"
	@echo "========================================\n"

clean:
	@rm -rf $(GEN_DIR) $(SRC_DIR)/*.o bin
	@rm -f $(TEST_DIR)/*.py
