library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 


entity ula_tb is
end entity;

architecture a_ula_tb of ula_tb is

    
    component ula is
       port (   entr0, entr1                         :  in  unsigned(15 downto 0);
                sel_operacao                         :  in  unsigned (1 downto 0);
                saida                                :  out unsigned(15 downto 0);
                flag_N, flag_C, flag_Z, flag_V       :  out std_logic
        );
    end component;

   
    signal t_entr0, t_entr1, t_saida : unsigned(15 downto 0);
    signal t_sel_operacao            : unsigned(1 downto 0);
    signal t_flag_N, t_flag_C, t_flag_Z, t_flag_V : std_logic;

begin

    uut: ula port map (
        entr0        => t_entr0,
        entr1        => t_entr1,
        sel_operacao => t_sel_operacao,
        saida        => t_saida,
        flag_N       => t_flag_N,
        flag_C       => t_flag_C,
        flag_Z       => t_flag_Z,
        flag_V       => t_flag_V
    );

   
    process
    begin
        -- TESTE 1: Soma 
        t_sel_operacao <= "00";
        t_entr0 <= "0000000000001010"; -- 10
        t_entr1 <= "0000000000000101"; -- 5 
        wait for 50 ns;

        -- TESTE 2: Subtracao dando em zero
        t_sel_operacao <= "01";
        t_entr0 <= "0000000000010100"; -- 20
        t_entr1 <= "0000000000010100"; -- 20
        wait for 50 ns;

        -- TESTE 3: Subtracao dando em negativo
        -- 5 - 10 = -5
        t_sel_operacao <= "01";
        t_entr0 <= "0000000000000101"; -- 5
        t_entr1 <= "0000000000001010"; -- 10
        wait for 50 ns;

        -- TESTE 4: Soma com numeros negativos 
        t_sel_operacao <= "00";
        t_entr0 <= "1111111111111101"; -- -3 em complemento de 2
        t_entr1 <= "1111111111111011"; -- -5 em complemento de 2
        wait for 50 ns;

        -- TESTE 5: Multiplicacao 
        t_sel_operacao <= "10";
        t_entr0 <= "0000000000000011"; -- 3
        t_entr1 <= "0000000000000100"; -- 4
        wait for 50 ns;

        -- TESTE 6: Porta  AND
        t_sel_operacao <= "11";
        t_entr0 <= "1111111100000000"; 
        t_entr1 <= "0000111111110000"; 
        wait for 50 ns;

       
        wait;
    end process;

end architecture;
