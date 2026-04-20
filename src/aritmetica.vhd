library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity aritmetica is
   port (   in_0,in_1            :  in  unsigned(15 downto 0);
            soma,subt,mult,exp   :  out unsigned(15 downto 0)
   );
end entity;
architecture a_aritmetica of aritmetica is
begin
   soma <=in_0+in_1;
   subt <=in_0-in_1;
   mult <=in_0*in_1;
   exp  <=in_0**in_1;
end architecture;