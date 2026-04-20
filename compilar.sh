#!/bin/bash

# Interrompe o script se ocorrer algum erro
set -e 

echo "Limpando arquivos de simulação antigos..."
rm -f *.cf *.o *.vcd

echo "1. Analisando componentes de design (src/)..."
ghdl -a src/ula.vhd
# Adicione outros arquivos do src/ aqui no futuro (ex: ghdl -a src/somador.vhd)

echo "2. Analisando testbenches (sim/)..."
ghdl -a sim/ula_tb.vhd

echo "3. Elaborando o Testbench..."
ghdl -e ula_tb

echo "4. Executando a simulação..."
ghdl -r ula_tb --vcd=simulacao_ula.vcd

echo "Arquivo simulacao_ula.vcd gerado."
