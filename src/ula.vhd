library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity ula is
   port (   entr0, entr1                         :  in  unsigned(15 downto 0);
            sel_operacao                         :  in unsigned (1 downto 0);
            saida                                :  out unsigned(15 downto 0);
            flag_N, flag_C, flag_Z, flag_V       :  out std_logic
    );
end entity;

architecture a_ula of ula is
    component aritmetica is
        port (in_0, in_1          :  in  unsigned(15 downto 0);
              soma,subt,mult,exp  :  out unsigned(15 downto 0)
        );
    end component;
    component mux4x1_16bits is
        port (   in0_mux, in1_mux, in2_mux, in3_mux          :  in  unsigned(15 downto 0);
                 sel                                         :  in  unsigned(1 downto 0);
                 out_mux                                     :  out unsigned(15 downto 0)
        );
    end component;

    signal s_soma, s_subt, s_mult, s_exp       : unsigned(15 downto 0);
    signal s_resultado_final                   : unsigned(15 downto 0);
begin
    aritmetica1 : aritmetica port map ( in_0 => entr0, in_1 => entr1, soma => s_soma, subt => s_subt, mult => s_mult,
                                        exp  => s_exp
                                      );

    mux1 : mux port map ( in0_mux => s_soma, in1_mux => s_subt, in2_mux => s_mult, in3_mux => s_exp, sel => sel_operacao,
                          out_mux => s_resultado_final 
                        );

    saida <= s_resultado_final;
    
    flag_Z <= '1' when (s_resultado_final = "0000000000000000")
                  else '0';

    flag_V <= '1' when (sel_operacao = "00" and ((entr0(15) = entr1(15)) and ((entr0(15) xor s_resultado_final(15)) = '1')))
                  else '0';

    flag_C <= '1' when (sel_operacao = "00" and ((entr0(15) and entr1(15)) = '1'
                        or (not s_resultado_final(15) and (entr0(15) or entr1(15))) = '1'))
                  else '0';

end architecture;