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

    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

begin
    -- Instancia o processador completo
    uut: processador port map (
        clk => clk, 
        rst => rst
    );

    -- Processo gerador de Clock (Período de 20 ns)
    process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- Processo gerador de Reset
    process
    begin
        rst <= '1';
        wait for 25 ns; -- Segura o reset em 1 no início 
        rst <= '0';
        wait; -- Fica em zero para sempre 
    end process;

end architecture;