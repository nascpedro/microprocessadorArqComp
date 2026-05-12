library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador_tb is
end entity;

architecture a_processador_tb of processador_tb is
    
    component processador is
        port( clk : in std_logic;
              rst : in std_logic
        );
    end component;

    constant period_time : time      := 100 ns;
    signal   finished    : std_logic := '0';
    signal   clk, rst    : std_logic := '0';

begin 

    uut: processador port map (
        clk => clk, 
        rst => rst
    );  
    
    reset_global: process
    begin
        rst <= '1';
        wait for period_time*2; -- espera 2 clocks, pra garantir
        rst <= '0';
        wait;
    end process;
    
    sim_time_proc: process
    begin
        -- Estimativa de clocks: 
        -- Setup inicial (carregar R3 e R4): 2 instrucoes = 4 clocks
        -- Cada volta completa no loop gasta 9 instrucoes = 18 clocks
        -- Para ver a sequencia pedida (12, 19, 26, 33, 40) precisaremos de 5 voltas.
        -- Total estimado: 4 + (5 * 18) = 94 clocks.
        -- Usando 150 clocks por seguranca.
        wait for period_time * 150;         
        finished <= '1';
        wait;
    end process sim_time_proc;
    
    clk_proc: process
    begin                       -- gera clock ata que sim_time_proc termine
        while finished /= '1' loop
            clk <= '0';
            wait for period_time/2;
            clk <= '1';
            wait for period_time/2;
        end loop;
        wait;
    end process clk_proc;

end architecture;