library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level_tb is
end entity;

architecture a_top_level_tb of top_level_tb is
    component top_level is
        port( clk           : in std_logic;
              rst           : in std_logic;
              constante_ext : in unsigned(15 downto 0);
              wr_en_banco   : in std_logic;
              wr_en_acc     : in std_logic;
              sel_operacao  : in unsigned(1 downto 0);
              sel_reg_wr    : in unsigned(2 downto 0);
              sel_reg_r1    : in unsigned(2 downto 0);
              sel_mux_ula   : in std_logic;
              sel_mux_data  : in std_logic
        );
    end component;

    
    constant period_time : time := 100 ns; 
    signal finished      : std_logic := '0';
    signal clk, rst      : std_logic;

    
    signal constante_ext : unsigned(15 downto 0) := "0000000000000000";
    signal wr_en_banco   : std_logic := '0';
    signal wr_en_acc     : std_logic := '0';
    signal sel_operacao  : unsigned(1 downto 0) := "00"; 
    signal sel_reg_wr    : unsigned(2 downto 0) := "000";
    signal sel_reg_r1    : unsigned(2 downto 0) := "000";
    signal sel_mux_ula   : std_logic := '0';
    signal sel_mux_data  : std_logic := '0';

begin
    uut: top_level port map (
        clk => clk,
        rst => rst,
        constante_ext => constante_ext,
        wr_en_banco => wr_en_banco,
        wr_en_acc => wr_en_acc,
        sel_operacao => sel_operacao,
        sel_reg_wr => sel_reg_wr,
        sel_reg_r1 => sel_reg_r1,
        sel_mux_ula => sel_mux_ula,
        sel_mux_data => sel_mux_data
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
        wait for 20 us;         
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


    process                      
    begin
        wait for 200 ns; 
        -- Caso 1: LD A, 5 (Carregamento direto da constante 5 no acumulador)
        constante_ext <= "0000000000000101"; -- carregando constante com valor decimal 5
        sel_operacao  <= "00";               -- supondo "00" como sendo a soma
        sel_reg_r1    <= "000";              
        sel_reg_wr    <= "000";              
        sel_mux_ula   <= '0';                
        sel_mux_data  <= '1';                -- mux seleciona constante externa
        wr_en_banco   <= '0';                -- sem gravação no banco
        wr_en_acc     <= '1';                -- habilita gravação no acumulador
        wait for period_time;            

        -- Caso 2: LD R2, 10 (Carregamento direto da constante 10 no registrador R2)
        constante_ext <= "0000000000001010"; -- valor 10
        sel_operacao  <= "00";               
        sel_reg_r1    <= "000";              
        sel_reg_wr    <= "010";              -- endereço de gravação R2
        sel_mux_ula   <= '0';                
        sel_mux_data  <= '1';                -- mux seleciona constante externa
        wr_en_banco   <= '1';                -- habilita gravação no banco
        wr_en_acc     <= '0';                -- sem gravação no acumulador
        wait for period_time;

        -- Caso 3: ADD A, R2 (Soma R2 ao acumulador e grava no próprio acumulador)
        constante_ext <= "0000000000000000"; 
        sel_operacao  <= "00";               -- operação da ula "00" (soma)
        sel_reg_r1    <= "010";              -- lê o R2 no banco
        sel_reg_wr    <= "000";             
        sel_mux_ula   <= '0';                -- mux da ula recebe do banco dados de R2
        sel_mux_data  <= '0';                -- mux de dados recebe da ula
        wr_en_banco   <= '0';                -- sem gravação no banco
        wr_en_acc     <= '1';                -- com gravação no acumulador
        wait for period_time;

        -- Caso 4: ADDI A, 20 (Soma o acumulador com a constante 20)
        constante_ext <= "0000000000010100"; -- carregando constante com valor decimal 20
        sel_operacao  <= "00";               -- operação da ula "00" (soma)
        sel_reg_r1    <= "000";              
        sel_reg_wr    <= "000";              
        sel_mux_ula   <= '1';                -- mux da ULA recebe Constante Externa
        sel_mux_data  <= '0';                -- mux de dados recebe da ULA
        wr_en_banco   <= '0';                -- sem gravação no banco
        wr_en_acc     <= '1';                -- com gravação no Acumulador
        wait for period_time;
    
        -- Caso 5: SUB A, R2 (Subtrai R2 do Acumulador)
        constante_ext <= "0000000000000000"; 
        sel_operacao  <= "01";               -- operação da ula "01" (subtração)
        sel_reg_r1    <= "010";              -- lê o R2 no banco
        sel_reg_wr    <= "000";              
        sel_mux_ula   <= '0';                -- mux da ula recebe do banco dados de R2
        sel_mux_data  <= '0';                -- mux de dados recebe da ula
        wr_en_banco   <= '0';                -- sem gravação no banco
        wr_en_acc     <= '1';                -- com gravação no acumulador
        wait for period_time;

        -- Caso 6: CMPI A, 50 (Compara acumulador com a constante 50)
        constante_ext <= "0000000000110010"; -- carregando constante com valor decimal 50
        sel_operacao  <= "01";               -- operação da ula "01" (subtração, para comparar)
        sel_reg_r1    <= "000";              
        sel_reg_wr    <= "000";              
        sel_mux_ula   <= '1';                -- mux da ula recebe constante externa
        sel_mux_data  <= '0';                
        wr_en_banco   <= '0';                -- sem gravação no banco
        wr_en_acc     <= '0';                -- sem gravação no acumulador 
        wait for period_time;

        -- Caso 7: CMPR A, R2 (Compara acumulador com R2)
        constante_ext <= "0000000000000000"; 
        sel_operacao  <= "01";               -- operação da ula "01" (subtração, para comparar)
        sel_reg_r1    <= "010";              -- lê o R2 no banco
        sel_reg_wr    <= "000";              
        sel_mux_ula   <= '0';                -- mux da ula recebe do banco dados de R2
        sel_mux_data  <= '0';                
        wr_en_banco   <= '0';                -- sem gravação no banco
        wr_en_acc     <= '0';                -- sem gravação no acumulador
        wait for period_time;    
        wait;                     
    end process;

end architecture;