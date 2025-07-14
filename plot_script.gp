# --- Configurações do Gráfico para PDF ---
set terminal pdfcairo enhanced color font "Arial,10" size 8,6
set output output_file # Nome do arquivo é passado pelo Makefile

# --- Títulos e Legendas ---
set title "Comparativo de Page Faults\nTrace: " . trace_name font ",14"
set xlabel "Número de Frames"
set ylabel "Total de Page Faults"

# --- Estilo do Gráfico ---
set key top right
set grid
# Apenas para garantir que o estilo de plotagem padrão não interfira
set style data lines

# --- Comando de Plotagem (MODIFICADO) ---
# A alteração está aqui: "with lines" desenha apenas as linhas.
plot data_file using 1:2 with lines title "random", \
     '' using 1:3 with lines title "fifo", \
     '' using 1:4 with lines title "sc", \
     '' using 1:5 with lines title "lru", \
     '' using 1:6 with lines title "lfu", \
     '' using 1:7 with lines title "mfu"