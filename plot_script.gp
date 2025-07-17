# --- Configurações do Gráfico para PDF ---
# Usa as variáveis passadas pelo Makefile
set terminal pdfcairo enhanced color font "Arial,10" size 8,6
set output output_file

# --- Títulos e Legendas (Genéricos) ---
set title plot_title . "\nTrace: " . trace_name font ",14"
set xlabel "Número de Frames"
set ylabel ylabel

# --- Estilo do Gráfico ---
set key top right
set grid
set style data lines

# --- Comando de Plotagem ---
# Este comando é agora universal, pois lê o ficheiro de dados pré-processado
plot data_file using 1:2 with lines title "random", \
     '' using 1:3 with lines title "fifo", \
     '' using 1:4 with lines title "sc", \
     '' using 1:5 with lines title "lru", \
     '' using 1:6 with lines title "lfu", \
     '' using 1:7 with lines title "mfu"