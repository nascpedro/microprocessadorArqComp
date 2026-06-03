library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity rom is
   port( clk      : in std_logic;
         endereco : in unsigned(5 downto 0);
         dado     : out unsigned(14 downto 0) 
   );
end entity;
architecture a_rom of rom is
   type mem is array (0 to 127) of unsigned(14 downto 0);
    constant conteudo_rom : mem := (
        -- PASSO 1: Ponteiros de endereco
        0  => "000100000001010", -- LD R0, 10
        1  => "000100100010100", -- LD R1, 20
        2  => "000101000011110", -- LD R2, 30

        -- PASSO 2: Escritas na RAM
        3  => "000101100000101", -- LD R3, 5
        4  => "001100001100000", -- MOV A, R3
        5  => "110000000000000", -- SW A, (R0) -> Grava 5 na RAM[10]

        6  => "000110000001111", -- LD R4, 15
        7  => "001100010000000", -- MOV A, R4
        8  => "110000000100000", -- SW A, (R1) -> Grava 15 na RAM[20]

        9  => "000110100011001", -- LD R5, 25
        10 => "001100010100000", -- MOV A, R5
        11 => "110000001000000", -- SW A, (R2) -> Grava 25 na RAM[30]

        -- PASSO 3: Flush Absoluto (Zerar os registos R3, R4 e R5)
        12 => "000101100000000", -- LD R3, 0   -> Agora R3 = 0
        13 => "001100001100000", -- MOV A, R3  -> Acumulador = 0
        14 => "010010000000000", -- MOV R4, A  -> R4 = 0
        15 => "010010100000000", -- MOV R5, A  -> R5 = 0

        -- PASSO 4: Leituras (Se a RAM falhar, eles continuam a zero)
        16 => "101101100000000", -- LW R3, (R0) -> Tem de ler 5
        17 => "101110000100000", -- LW R4, (R1) -> Tem de ler 15
        18 => "101110101000000", -- LW R5, (R2) -> Tem de ler 25

        -- PASSO 5: Prova de Vida (Matematica)
        19 => "001100001100000", -- MOV A, R3   (A = 5)
        20 => "010100010000000", -- ADD A, R4   (A = 5 + 15 = 20)
        21 => "010100010100000", -- ADD A, R5   (A = 20 + 25 = 45)

        -- PASSO 6: Travar PC
        22 => "111100000000000", -- JMP 0 (Fica preso no 24)
        
        others => (others => '0')
    );
begin
   process(clk)
   begin
      if(rising_edge(clk)) then
         dado <= conteudo_rom(to_integer(endereco));
      end if;
   end process;
end architecture;
