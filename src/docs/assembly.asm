# Assembly teste professor Lab05

# 00: Carrega R3 com 5
LD R3, 5;
# 01: Carrega R4 com 8
LD R4, 8;

# PASSO C: Soma R3 com R4 e guarda em R5 (O loop volta para ca)
# 02: 
MOV A, R3;
# 03: CORRIGIDO PARA ADD (Acumulador = Acumulador + R4)
ADD A, R4; 
# 04:
MOV R5, A;

# PASSO D: Subtrai 1 de R5 e armazena o resultado de volta em R5
# 05: (A subtração acontece direto no Acumulador que já tinha o valor)
SUBI A, 1;
# 06:
MOV R5, A;

# PASSO E: Pula para a instrucao do endereco 20 (+13 instrucoes)
# 07: (PC = 8; alvo = 8 - 1 + 13 = 20)
JMP +13;

# PASSO F: Nunca sera executada
# 08: 
LD R5, 0;

# PREENCHIMENTO PARA CHEGAR AO ENDEREÇO 20
# 09 até 19:
NOP; 
NOP; 
NOP; 
NOP; 
NOP; 
NOP; 
NOP; 
NOP; 
NOP; 
NOP; 
NOP; 

# PASSO G: No endereço 20, copia R5 para R3
# 20: 
MOV R3, R5;

# PASSO H: Salta de volta para o passo C (endereço 02)
# 21: (PC = 22; alvo = 22 - 1 - 19 = 2)
JMP -19;

# PASSO I: Nunca sera executada
# 22:
LD R3, 0;