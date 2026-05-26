library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity rom is
   port( clk      : in std_logic;
         endereco : in unsigned(6 downto 0);
         dado     : out unsigned(14 downto 0) 
   );
end entity;
architecture a_rom of rom is
   type mem is array (0 to 127) of unsigned(14 downto 0);
   constant conteudo_rom : mem := (
      
      -- caso endereco => conteudo
      -- [Opcode: 4 bits] [Destino: 3 bits] [Origem: 3 bits] [Constante: 5 bits]
      -- Codigos de opcode em ./src/docs/ISA.txt

      -- Passos A e B: Carrega R3 e R4 com 0
      0  => "000101100000000", -- LD R3, 0   (Opcode: 0001 | Dest: 011 | Orig: 000 | Cte: 00000)
      1  => "000110000000000", -- LD R4, 0   (Opcode: 0001 | Dest: 100 | Orig: 000 | Cte: 00000)
  
      -- Passo C (INÍCIO DO LOOP - Endereço 2)
      2  => "001100010000000", -- MOV A, R4  (Opcode: 0011 | Dest: 000 | Orig: 100 | Cte: 00000)
      3  => "010100001100000", -- ADD A, R3  (Opcode: 0101 | Dest: 000 | Orig: 011 | Cte: 00000)
      4  => "010010000000000", -- MOV R4, A  (Opcode: 0100 | Dest: 100 | Orig: 000 | Cte: 00000)
      
      -- Passo D (Soma 1 em R3 usando ADDI)
      5  => "001100001100000", -- MOV A, R3  (Opcode: 0011 | Dest: 000 | Orig: 011 | Cte: 00000)
      6  => "011100000000001", -- ADDI A, 1  (Opcode: 0111 | Dest: 000 | Orig: 000 | Cte: 00001)
      7  => "010001100000000", -- MOV R3, A  (Opcode: 0100 | Dest: 011 | Orig: 000 | Cte: 00000)

      -- Passo E (Comparacao e Desvio)
      8  => "001100001100000", -- MOV A, R3  (Opcode: 0011 | Dest: 000 | Orig: 011 | Cte: 00000)
      9  => "011000000011110", -- SUBI A, 30 (Opcode: 0110 | Dest: 000 | Orig: 000 | Cte: 11110)
      10 => "101011111111000", -- BLT -8     (Opcode: 1010 | Dest: 111 | Orig: 111 | Cte: 11000) (-8 em comp. de 2)

      -- Passo F (Saida do Loop - Copia R4 para R5)
      11 => "001100010000000", -- MOV A, R4  (Opcode: 0011 | Dest: 000 | Orig: 100 | Cte: 00000)
      12 => "010010100000000", -- MOV R5, A  (Opcode: 0100 | Dest: 101 | Orig: 000 | Cte: 00000) 
      others => (others=>'0') -- NOP
   );
begin
   process(clk)
   begin
      if(rising_edge(clk)) then
         dado <= conteudo_rom(to_integer(endereco));
      end if;
   end process;
end architecture;