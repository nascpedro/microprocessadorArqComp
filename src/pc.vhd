library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc is
   port( clk      : in std_logic;
         rst      : in std_logic;
         wr_en    : in std_logic;
         data_in  : in unsigned(15 downto 0);
         data_out : out unsigned(15 downto 0)
   );
end entity;

architecture a_pc of pc is
   signal pc_s: unsigned(15 downto 0);
begin
   process(clk,rst,wr_en)  
   begin
      if rst='1' then
         pc_s <= "0000000000000000";
      elsif wr_en='1' then
         if rising_edge(clk) then
            pc_s <= data_in;
         end if;
      end if;
   end process;
   data_out <= pc_s;   
end architecture; 