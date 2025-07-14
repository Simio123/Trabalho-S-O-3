# Simulador de Memória Virtual (virtmem_sim)

Este projeto consiste num simulador, desenvolvido em linguagem C, para estudar e analisar o desempenho de diferentes algoritmos de substituição de páginas utilizados em sistemas de memória virtual.

O simulador foi estendido para implementar e comparar seis algoritmos distintos:
-   **Random** (Aleatório)
-   **FIFO** (First-In, First-Out)
-   **SC** (Second Chance)
-   **LRU** (Least Recently Used)
-   **LFU** (Least Frequently Used)
-   **MFU** (Most Frequently Used)

O projeto utiliza um `Makefile` para automatizar completamente o processo de compilação, execução das simulações e geração de gráficos comparativos de desempenho em formato PDF.

## Estrutura do Projeto

Ao executar os comandos do `Makefile`, a seguinte estrutura de diretórios será criada:

-   `resultados/`: Contém os dados brutos das simulações.
    -   `[algoritmo]/`: Um subdiretório para cada algoritmo (ex: `fifo`, `lru`).
        -   `frames_[N].csv`: Ficheiros CSV com os resultados (número de page faults) para cada simulação com `N` frames de memória.
-   `graficos/`: Contém os gráficos de desempenho gerados em formato PDF.
    -   `trace[X].pdf`: Um gráfico para cada ficheiro de trace, comparando o desempenho de todos os algoritmos.
-   `traces/`: Deve conter os ficheiros de trace de acesso à memória (ex: `trace1.trace`).

## Como Usar (via `Makefile`)

Para utilizar o simulador, abra um terminal no diretório raiz do projeto e use os seguintes comandos:

### Compilação
Para compilar o código fonte e gerar o executável `simulador`:
```bash
make compile
```
### Execução das Simulações

Para executar as simulações para todas as combinações de algoritmos, frames e ficheiros de trace. Este comando irá preencher o diretório resultados/ com os ficheiros .csv.
```bash
make execute
```

### Geração dos Gráficos

Para gerar os gráficos comparativos em PDF a partir dos dados das simulações. Os gráficos serão salvos no diretório graficos/. Este comando requer que make execute tenha sido executado previamente.
```bash

make graphs
```

### Execução Completa

Para executar todo o processo em sequência (compilar, executar e gerar os gráficos):
```bash
make all
```
### Limpeza

Para remover todos os ficheiros e diretórios gerados (simulador, resultados/, graficos/):
```bash
make clean
```
