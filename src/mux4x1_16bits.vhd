library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity mux4x1_16bits is 
   port (   in0_mux, in1_mux, in2_mux, in3_mux               :  in  unsigned(15 downto 0);
            sel                                              :  in  unsigned(1 downto 0);
            out_mux                                          :  out unsigned(15 downto 0)
   );
end entity;

architecture a_mux4x1_16bits of mux4x1_16bits is
begin
    out_mux <= in0_mux  when sel = "00"  else
               in1_mux  when sel = "01"  else
               in2_mux  when sel = "10"  else
               in3_mux  when sel = "11"  else
               "0000000000000000";
end architecture;
    