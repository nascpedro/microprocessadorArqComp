#!/bin/bash

# Interrompe o script se ocorrer algum erro
set -e 

echo "Limpando arquivos de simulação antigos..."
rm -f *.cf *.o *.vcd *.ghw 

echo "Analisando componentes base (src/)..."
ghdl -a src/ula.vhd
ghdl -a src/reg16bits.vhd
ghdl -a src/maquinaEstados.vhd
ghdl -a src/pc.vhd
ghdl -a src/rom.vhd

echo "Analisando blocos intermediários..."
ghdl -a src/bancoRegs16bits.vhd 

echo "Analisando Datapath e Controle..."
ghdl -a src/top_level.vhd
ghdl -a src/uc.vhd

echo "Analisando Entidade Principal (Processador)..."
ghdl -a src/processador.vhd

echo "Analisando Testbenches..."
ghdl -a src/top_level_tb.vhd 
ghdl -a src/uc_tb.vhd
ghdl -a src/processador_tb.vhd

echo "Gerando arquivo de simulação do Processador Completo..."
# Executa o testbench do processador e gera a onda
ghdl -r processador_tb --wave=processador_tb.ghw

echo "========================================================="
echo "Sucesso! Arquivo processador_tb.ghw gerado."
echo "Para visualizar as ondas, digite: gtkwave processador_tb.ghw"
echo "========================================================="


gtkwave processador_tb.ghw ondas_lab5.gtkw 