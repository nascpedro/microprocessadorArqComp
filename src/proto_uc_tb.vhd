library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;   

entity proto_uc_tb is
end entity;

architecture a_proto_uc_tb of proto_uc_tb is
    component proto_uc is
       port( clk      : in std_logic;
             rst      : in std_logic;
             pc_out   : out unsigned(15 downto 0);
             saida_rom : out unsigned(14 downto 0)
       );
    end component;

    constant period_time : time := 100 ns;
    signal finished      : std_logic := '0';
    signal clk           : std_logic;
    signal rst           : std_logic := '0';
    signal pc_out        : unsigned(15 downto 0) := (others => '0');
    signal saida_rom      : unsigned(14 downto 0);    

begin
    uut: proto_uc port map (
        clk => clk,
        rst => rst,
        pc_out => pc_out,
        saida_rom => saida_rom
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
