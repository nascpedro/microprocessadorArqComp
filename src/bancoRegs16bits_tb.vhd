library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity bancoRegs16bits_tb is
end entity;

architecture a_bancoRegs16bits_tb of bancoRegs16bits_tb is
    component bancoRegs16bits is          
         port( clk      : in std_logic;
               rst      : in std_logic;
               wr_en    : in std_logic;
               data_wr  : in unsigned(15 downto 0);
               reg_wr   : in unsigned(2 downto 0);
               reg_r1   : in unsigned(2 downto 0);
               data_r1  : out unsigned(15 downto 0)
         );
    end component;

                            -- 100 ns é o período que escolhi para o clock
    constant period_time : time      := 100 ns;
    signal   finished    : std_logic := '0';
    signal   clk, reset  : std_logic;
    signal   wr_en       : std_logic := '0';
    signal   data_in     : unsigned(15 downto 0) := (others => '0');
    signal   data_out    : unsigned(15 downto 0);
    signal   reg_wr      : unsigned(2 downto 0) := (others => '0');
    signal   reg_r1      : unsigned(2 downto 0) := (others => '0');

begin

    uut: bancoRegs16bits port map (clk => clk, 
                                  rst => reset, 
                                  wr_en => wr_en, 
                                  data_wr => data_in, 
                                  reg_wr => reg_wr, 
                                  reg_r1 => reg_r1, 
                                  data_r1   => data_out);  -- aqui vai a instância do seu componente
    
    reset_global: process
    begin
        reset <= '1';
        wait for period_time*2; -- espera 2 clocks, pra garantir
        reset <= '0';
        wait;
    end process;
    
    sim_time_proc: process
    begin
        wait for 30 us;         
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

   process                      
   begin
      wait for 200 ns; 
      
      wr_en <= '1'; 
      
      reg_wr <= "000";
      data_in <= "1111111111111111";
      wait for 100 ns;
      
      reg_wr <= "001";
      data_in <= "1000110100001101";
      wait for 100 ns;
      
      reg_wr <= "010";
      data_in <= "1010101010101010";
      wait for 100 ns;
      
      reg_wr <= "110";
      data_in <= "0110011001100110";
      wait for 100 ns; 

      wr_en <= '0'; 
      wait for 100 ns;

      reg_r1 <= "000";
      wait for 100 ns;
      
      reg_r1 <= "010";
      wait for 100 ns;

      reg_r1 <= "110";
      wait for 100 ns;
      
      wait;                     
   end process;
end architecture; 