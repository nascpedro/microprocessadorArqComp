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
      -- Codigos de opcode em ./src/docs/ISA_Lab05.txt

      0  => "000101100000101", -- LD R3, 5   => [Opcode: 0001] [Destino: 011] [Origem: 000] [Constante: 00101]
      1  => "000110000001000", -- LD R4, 8   => [Opcode: 0001] [Destino: 100] [Origem: 000] [Constante: 01000]
      2  => "001100001100000", -- MOV A, R3  => [Opcode: 0011] [Destino: 000] [Origem: 011] [Constante: 00000]
      3  => "010100010000000", -- ADD A, R4  => [Opcode: 0101] [Destino: 000] [Origem: 100] [Constante: 00000]
      4  => "000000000000000", -- NOP
      5  => "011000000000001", -- SUBI A, 1  => [Opcode: 0110] [Destino: 000] [Origem: 000] [Constante: 00001]
      6  => "010010100000000", -- MOV R5, A  => [Opcode: 0100] [Destino: 101] [Origem: 000] [Constante: 00000]
      7  => "111100000001101", -- JMP +13    => [Opcode: 1111] [Destino: 000] [Origem: 000] [Constante: 01101]
      8  => "000110100000000", -- LD R5, 0   => [Opcode: 0001] [Destino: 101] [Origem: 000] [Constante: 00000]
      9  => "000000000000000", -- NOP        => [Opcode: 0000] [Destino: 000] [Origem: 000] [Constante: 00000]
      10 => "000000000000000", -- NOP
      11 => "000000000000000", -- NOP
      12 => "000000000000000", -- NOP
      13 => "000000000000000", -- NOP
      14 => "000000000000000", -- NOP
      15 => "000000000000000", -- NOP
      16 => "000000000000000", -- NOP
      17 => "000000000000000", -- NOP
      18 => "000000000000000", -- NOP
      19 => "000000000000000", -- NOP
      20 => "001100010100000", -- MOV A, R5 => [Opcode: 0011] [Destino: 000] [Origem: 101] [Constante: 00000]
      21 => "010001100000000", -- MOV R3, A => [Opcode: 0100] [Destino: 011] [Origem: 000] [Constante: 00000]
      22 => "111111111101100", -- JMP -20   => [Opcode: 1111] [Destino: 000] [Origem: 000] [Constante: 10100 (-20 em complemento de 2)]
      others => (others=>'0')--NOP
   );
begin
   process(clk)
   begin
      if(rising_edge(clk)) then
         dado <= conteudo_rom(to_integer(endereco));
      end if;
   end process;
end architecture;