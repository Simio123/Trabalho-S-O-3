# --- Configurações do Projeto ---
CC = gcc
CFLAGS = -Wall -O2
EXEC = simulador
SRC = simulador.c

# --- Diretórios ---
RESULTS_DIR = resultados
GRAPHS_DIR = graficos

# --- Parâmetros da Simulação ---
TRACES = $(wildcard traces/*.trace)
ALGORITHMS = random fifo sc lru lfu mfu
FRAMES = 2 4 8 16 32 64

# --- Regras Principais (Phony) ---
.PHONY: all compile execute graphs clean

# Regra padrão: executa todo o processo
all: compile execute graphs

# Regra 1: Compila o código fonte
compile: $(EXEC)
	@echo "Simulador compilado com sucesso."

# Regra 2: Executa todas as simulações
execute: $(EXEC) | $(RESULTS_DIR)
	@echo "\n========================================================"
	@echo "MODO DE EXECUÇÃO EM LOTE INICIADO"
	@$(call run_simulations)
	@echo "========================================================"
	@echo "TODAS AS SIMULAÇÕES FORAM CONCLUÍDAS!"
	@echo "Resultados salvos em: $(RESULTS_DIR)/"
	@echo "========================================================"

# Regra 3: Gera os gráficos a partir dos dados (LÓGICA CORRIGIDA)
graphs: | $(GRAPHS_DIR)
	@echo "\n>>> Gerando gráficos para Page Faults e Page Writes..."
	@if [ ! -d "$(RESULTS_DIR)" ]; then \
		echo "Diretório '$(RESULTS_DIR)' não encontrado. Execute 'make execute' primeiro."; \
		exit 1; \
	fi
	rm -rf $(GRAPHS_DIR)
	mkdir -p $(GRAPHS_DIR)
	@$(call generate_graphs_script)
	@echo "Gráficos em PDF gerados com sucesso em '$(GRAPHS_DIR)'."

# Regra 4: Limpa todos os ficheiros e diretórios gerados
clean:
	@echo "Limpando arquivos gerados..."
	@rm -f $(EXEC)
	@rm -rf $(RESULTS_DIR) $(GRAPHS_DIR)
	@echo "Limpeza concluída."


# --- Bloco de Script para Execução ---
define run_simulations
    echo "Limpando resultados antigos...";
    rm -rf $(RESULTS_DIR);
    mkdir -p $(RESULTS_DIR);
    for algo in $(ALGORITHMS); do \
        echo ""; \
        echo ">>> Processando algoritmo: $$algo <<<"; \
        OUT_DIR=$(RESULTS_DIR)/$$algo; \
        mkdir -p $${OUT_DIR}; \
        for frame_num in $(FRAMES); do \
            echo "  - Testando com $${frame_num} frames..."; \
            CSV_FILE=$${OUT_DIR}/frames_$${frame_num}.csv; \
            echo "Trace,PageFaults,PagesWritten" > $${CSV_FILE}; \
            for trace_file in $(TRACES); do \
                output=$$("./$(EXEC)" "$$trace_file" "$$frame_num" "$$algo"); \
                faults=$$(echo "$$output" | grep "page faults" | awk '{print $$6}'); \
                written=$$(echo "$$output" | grep "pages written" | awk '{print $$8}'); \
                echo "$$trace_file,$$faults,$$written" >> $${CSV_FILE}; \
            done; \
        done; \
    done
endef

# --- Bloco de Script para Geração de Gráficos ---
define generate_graphs_script
    for trace_file in $(TRACES); do \
        base_name=$$(basename $$trace_file .trace); \
        \
        data_file_faults=$(GRAPHS_DIR)/$${base_name}_faults.dat; \
        output_plot_faults=$(GRAPHS_DIR)/$${base_name}_faults.pdf; \
        echo "Gerando gráfico de Page Faults: $${output_plot_faults}"; \
        for frame_num in $(FRAMES); do \
            line="$${frame_num}"; \
            for algo in $(ALGORITHMS); do \
                faults=$$(grep $$trace_file $(RESULTS_DIR)/$$algo/frames_$$frame_num.csv | cut -d, -f2); \
                line="$$line $$faults"; \
            done; \
            echo $$line >> $$data_file_faults; \
        done; \
        gnuplot -e "data_file='$$data_file_faults'" \
                -e "trace_name='$$trace_file'" \
                -e "output_file='$$output_plot_faults'" \
                -e "plot_title='Comparativo de Page Faults'" \
                -e "ylabel='Total de Page Faults'" \
                plot_script.gp; \
        rm $$data_file_faults; \
        \
        data_file_writes=$(GRAPHS_DIR)/$${base_name}_writes.dat; \
        output_plot_writes=$(GRAPHS_DIR)/$${base_name}_writes.pdf; \
        echo "Gerando gráfico de Page Writes: $${output_plot_writes}"; \
        for frame_num in $(FRAMES); do \
            line="$${frame_num}"; \
            for algo in $(ALGORITHMS); do \
                writes=$$(grep $$trace_file $(RESULTS_DIR)/$$algo/frames_$$frame_num.csv | cut -d, -f3); \
                line="$$line $$writes"; \
            done; \
            echo $$line >> $$data_file_writes; \
        done; \
        gnuplot -e "data_file='$$data_file_writes'" \
                -e "trace_name='$$trace_file'" \
                -e "output_file='$$output_plot_writes'" \
                -e "plot_title='Comparativo de Páginas Escritas (Page Writes)'" \
                -e "ylabel='Total de Páginas Escritas'" \
                plot_script.gp; \
        rm $$data_file_writes; \
    done
endef


# --- Regras de Construção ---
$(EXEC): $(SRC)
	@$(CC) $(CFLAGS) $< -o $@

$(RESULTS_DIR) $(GRAPHS_DIR):
	@mkdir -p $@