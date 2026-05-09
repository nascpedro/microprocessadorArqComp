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
      -- formato: [ opcode 4 bits | offset 11 bits ]
      -- JMP = opcode "1111"

      0  => "000000000000000",  -- NOP
      1  => "000000000000000",  -- NOP
      2  => "111100000000100",  -- JMP +4  (vai para endereco 6)
      3  => "000000000000000",  -- NOP     (nunca executado)
      4  => "000000000000000",  -- NOP     (nunca executado)
      5  => "000000000000000",  -- NOP     (nunca executado)
      6  => "000000000000000",  -- NOP
      7  => "111100000000011",  -- JMP +3  (vai para endereco 10)
      8  => "111100000000011",  -- JMP +3  (nunca executado)
      9  => "000000000000000",  -- NOP     (nunca executado)
      10 => "000000000000000",  -- NOP     (inicio do loop)
      11 => "000000000000000",  -- NOP
      12 => "111111111111110",  -- JMP -2  (loop pro endereco 10)
      -- abaixo: casos omissos => (zero em todos os bits) --NOP
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