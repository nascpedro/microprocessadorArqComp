library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;   

entity uc_tb is
end entity;

architecture a_uc_tb of uc_tb is
    component uc is
       port( clk       : in std_logic;
             rst       : in std_logic;
             pc_out    : out unsigned(15 downto 0);
             saida_rom : out unsigned(14 downto 0)
       );
    end component;

    constant period_time : time      := 100 ns;
    signal   finished    : std_logic := '0';
    signal   clk, reset  : std_logic := '0';
    signal   pc_out      : unsigned(15 downto 0);
    signal   saida_rom   : unsigned(14 downto 0);

begin 

    uut: uc port map (clk => clk, 
                      rst => reset, 
                      pc_out => pc_out, 
                      saida_rom => saida_rom);  
    
    reset_global: process
    begin
        reset <= '1';
        wait for period_time*2; -- espera 2 clocks, pra garantir
        reset <= '0';
        wait;
    end process;
    
    sim_time_proc: process
    begin

        -- Estimativa de clocks: Cada instrucao leva 2 clocks (estado 0 =fetch, estado 1 =execute)
        -- fora do loop: end. 0,1 = 4 clks, end. 2(JMP +4) = 2 clks ,end. 6 = 2 clks, end.7(JMP +3) = 2 clks
        -- total fora do loop: 10 clks
        -- dentro do loop: end. 10 = 2 clks, end. 11 = 2 clks, end. 12(JMP -2) = 2 clks
        -- total dentro do loop: 6 clks por volta, e o loop roda 3 vezes => 18 clks
        -- total geral: 10 + 18 = 28 clks
        -- usando 40 clks por seguranca
        wait for period_time*40;         
        finished <= '1';
        wait;
    end process sim_time_proc;
    
    clk_proc: process
    begin                       -- gera clock até que sim_time_proc termine
        while finished /= '1' loop
            clk <= '0';
            wait for period_time/2;
            clk <= '1';
            wait for period_time/2;
        end loop;
        wait;
    end process clk_proc;

end architecture;