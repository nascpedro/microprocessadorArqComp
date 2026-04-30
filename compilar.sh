#!/bin/bash

# Interrompe o script se ocorrer algum erro
set -e 
# No momento, estamos deixando todos os arquivos na pasta source (/src) 

echo "Limpando arquivos de simulação antigos..."
# Adicionado .ghw na lista de limpeza
rm -f *.cf *.o *.vcd *.ghw 

echo "Analisando componentes (src/)..."
#EX: ghdl -a porta.vhd 
ghdl -a src/ula.vhd
ghdl -a src/reg16bits.vhd
ghdl -a src/bancoRegs16bits.vhd 
ghdl -a src/top_level.vhd
ghdl -a src/top_level_tb.vhd 

echo "Gerando arquivo de simulação..."
#EX:ghdl -r porta_tb --wave=porta_tb.ghw
ghdl -r top_level_tb --wave=top_level_tb.ghw

echo "Arquivo top_level_tb.ghw gerado com sucesso."
