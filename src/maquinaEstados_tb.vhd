library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity maquinaEstados_tb is
end entity;

architecture a_maquinaEstados_tb of maquinaEstados_tb is
    component maquinaEstados is
        port( clk      : in std_logic;
              rst      : in std_logic;
              estado   : out std_logic
        );
    end component;  
    
    constant period_time : time := 100 ns; 
    signal finished      : std_logic := '0';
    signal clk           : std_logic;
    signal rst           : std_logic := '0';
    signal estado        : std_logic := '0';

    begin   
    uut: maquinaEstados port map (
        clk => clk,
        rst => rst,
        estado => estado
    );  

    reset_global: process
    begin
        rst <= '1';
        wait for period_time*2;
        rst <= '0';
        wait;
    end process;
    
    sim_time_proc: process
    begin
        wait for 30 us;       
        finished <= '1';
        wait;
    end process sim_time_proc;
    
    clk_proc: process
    begin                      
        while finished /= '1' loop
            clk <= '0';
            wait for period_time/2;
            clk <= '1';
            wait for period_time/2;
        end loop;
        wait;
    end process clk_proc;

end architecture;