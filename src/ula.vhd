library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity ula is
   port (   entr0, entr1                         :  in  unsigned(15 downto 0);
            sel_operacao                         :  in  unsigned (1 downto 0);
            saida                                :  out unsigned(15 downto 0);
            flag_N, flag_C, flag_Z, flag_V       :  out std_logic
    );
end entity;

architecture a_ula of ula is

	
	signal s_mult_32 : unsigned(31 downto 0); --sinal para guardar uma multiplicação(32bits)
    signal s_soma, s_subt, s_mult, s_and       : unsigned(15 downto 0);
    signal s_resultado_final                   : unsigned(15 downto 0);

begin
    s_soma <= entr0 + entr1;
    s_subt <= entr0 - entr1;
    s_mult_32 <= entr0 * entr1;
    s_mult <= s_mult_32(15 downto 0);--slicing para os 15 LSB
    s_and  <= entr0 and entr1; 

    s_resultado_final <= s_soma  when sel_operacao = "00"  else
                         s_subt  when sel_operacao = "01"  else
                         s_mult  when sel_operacao = "10"  else
                         s_and   when sel_operacao = "11"  else
                         "0000000000000000";

    saida <= s_resultado_final;
    
    flag_N <= s_resultado_final(15);

    flag_Z <= '1' when (s_resultado_final = "0000000000000000")
                  else '0';

    flag_V <= '1' when (sel_operacao = "00" and ((entr0(15) = entr1(15)) and ((entr0(15) xor s_resultado_final(15)) = '1')))
                  else '0';

    flag_C <= '1' when (sel_operacao = "00" and ((entr0(15) and entr1(15)) = '1'
                        or (not s_resultado_final(15) and (entr0(15) or entr1(15))) = '1'))
                  else '0';

end architecture;
