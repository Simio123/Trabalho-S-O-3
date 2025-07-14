CC = gcc
CFLAGS = -Wall -O2
EXEC = simulador
SRC = simulador.c

RESULTS_DIR = resultados
GRAPHS_DIR = graficos

TRACES = $(wildcard traces/*.trace)
ALGORITHMS = random fifo sc lru lfu mfu
FRAMES = 2 4 8 16 32 64

.PHONY: all compile execute graphs clean

all: compile execute graphs

compile: $(EXEC)
	@echo "Simulador compilado com sucesso."

execute: $(EXEC) | $(RESULTS_DIR)
	@echo "\n========================================================"
	@echo "MODO DE EXECUÇÃO EM LOTE INICIADO"
	@echo "========================================================"
	@$(call run_simulations)
	@echo "========================================================"
	@echo "TODAS AS SIMULAÇÕES FORAM CONCLUÍDAS!"
	@echo "Resultados salvos em: $(RESULTS_DIR)/"
	@echo "========================================================"

graphs: | $(GRAPHS_DIR)
	@echo "\n>>> Gerando gráficos para cada ficheiro de trace..."
	@if [ ! -d "$(RESULTS_DIR)" ]; then \
		echo "Diretório '$(RESULTS_DIR)' não encontrado. Execute 'make execute' primeiro."; \
		exit 1; \
	fi
	rm -rf $(GRAPHS_DIR)
	mkdir -p $(GRAPHS_DIR)
	@for trace_file in $(TRACES); do \
		data_file=$(GRAPHS_DIR)/$$(basename $$trace_file .trace).dat; \
		output_plot=$(GRAPHS_DIR)/$$(basename $$trace_file .trace).pdf; \
		echo "Gerando gráfico: $$output_plot"; \
		echo "# Frames $(ALGORITHMS)" > $$data_file; \
		for frame_num in $(FRAMES); do \
			line=$$frame_num; \
			for algo in $(ALGORITHMS); do \
				faults=$$(grep $$trace_file $(RESULTS_DIR)/$$algo/frames_$$frame_num.csv | cut -d, -f2); \
				line="$$line $$faults"; \
			done; \
			echo $$line >> $$data_file; \
		done; \
		gnuplot -e "data_file='$$data_file'" \
		        -e "trace_name='$$trace_file'" \
		        -e "output_file='$$output_plot'" \
		        plot_script.gp; \
		rm $$data_file; \
	done
	@echo "Gráficos em PDF gerados com sucesso em '$(GRAPHS_DIR)'."

clean:
	@echo "Limpando arquivos gerados..."
	@rm -f $(EXEC)
	@rm -rf $(RESULTS_DIR) $(GRAPHS_DIR)
	@echo "Limpeza concluída."

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

$(EXEC): $(SRC)
	@$(CC) $(CFLAGS) $< -o $@

$(RESULTS_DIR) $(GRAPHS_DIR):
	@mkdir -p $@