library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;   

entity uc is
   port( clk           : in std_logic;
         rst           : in std_logic;

         pc_out        : out unsigned(15 downto 0);
         saida_rom     : out unsigned(14 downto 0);

         constante_out : out unsigned(15 downto 0); 
         wr_en_banco   : out std_logic; 
         wr_en_acc     : out std_logic; 
         sel_operacao  : out unsigned(2 downto 0); 
         sel_reg_wr    : out unsigned(2 downto 0); 
         sel_reg_r1    : out unsigned(2 downto 0); 
         sel_mux_ula   : out std_logic; 
         sel_mux_data  : out unsigned(1 downto 0); 
        
         wr_en_ram     : out std_logic; 

         N_in          : in std_logic;    
         C_in          : in std_logic;
         Z_in          : in std_logic;
         V_in          : in std_logic;
         
         exc_ram_in    : in std_logic  
   );
end entity;

architecture a_uc of uc is
    component pc is
       port( clk      : in std_logic;
             rst      : in std_logic;
             wr_en    : in std_logic;
             data_in  : in unsigned(15 downto 0);
             data_out : out unsigned(15 downto 0)
       );
    end component;

    component rom is
        port( clk      : in std_logic;
              endereco : in unsigned(5 downto 0);
              dado     : out unsigned(14 downto 0) 
        );
    end component;

    component maquinaEstados is
        port( clk      : in std_logic;
              rst      : in std_logic;
              estado   : out unsigned(1 downto 0)
        );
    end component;

    -- Sinais internos (PC e Estado)
    signal s_pc_in        : unsigned(15 downto 0);
    signal s_pc_out       : unsigned(15 downto 0);
    signal s_pc_wr_en     : std_logic;
    signal s_estado       : unsigned(1 downto 0);

    -- Sinais internos (PInstrucao)
    signal s_saida_rom    : unsigned(14 downto 0);
    signal s_ir           : unsigned(14 downto 0);
    signal s_instrucao    : unsigned(14 downto 0); 
    
    -- Fatias da intrucao
    signal opcode         : unsigned(3 downto 0);
    signal ext_jmp        : unsigned(15 downto 0);
    signal ext_cte        : unsigned(15 downto 0);
    
    -- Sinais flip-flop para as flags da ULA
    signal s_flag_N : std_logic;
    signal s_flag_C : std_logic;
    signal s_flag_Z : std_logic;    
    signal s_flag_V : std_logic;
    signal s_wr_flags : std_logic;
    signal s_condicao_atendida : std_logic;

begin
    -- ir: registrador de instrução. Atualiza no estado 1, lendo direto da ROM (pois o PC ainda não atualizou)
    process(clk, rst)
    begin
        if rst = '1' then
            s_ir <= (others => '0');
        elsif rising_edge(clk) then
            if s_estado = "01" then 
                s_ir <= s_saida_rom;
            end if;
        end if;
    end process;
    
   process(clk,rst)  
   begin
      if rst='1' then
         s_flag_N <= '0';
      elsif rising_edge(clk) then
         if s_wr_flags='1' then
            s_flag_N <= N_in;
         end if;
      end if;
   end process;

   process(clk,rst)  
   begin
      if rst='1' then
         s_flag_C <= '0';
      elsif rising_edge(clk) then
         if s_wr_flags='1' then
            s_flag_C <= C_in;
         end if;
      end if;
   end process;

   process(clk,rst)  
   begin
      if rst='1' then
         s_flag_Z <= '0';
      elsif rising_edge(clk) then
         if s_wr_flags='1' then
            s_flag_Z <= Z_in;
         end if;
      end if;
   end process;
   
   process(clk,rst)  
   begin
      if rst='1' then
         s_flag_V <= '0';
      elsif rising_edge(clk) then
         if s_wr_flags='1' then
            s_flag_V <= V_in;
         end if;
      end if;
   end process;

    
    -- Logica de desvios condicionais (para BLT e BHI)
    s_condicao_atendida <= '1' when (opcode = "1111") else
                           '1' when (opcode = "1010" and (s_flag_N xor s_flag_V) = '1') else 
                           '1' when (opcode = "1001" and s_flag_Z = '0' and s_flag_C = '0') else 
                           '0';

    s_instrucao <= s_saida_rom when s_estado = "01" else s_ir; 


    -- Fatiamento da instrucao para obter opcode e campos de registradores
    opcode     <= s_instrucao(14 downto 11);
    sel_reg_wr <= s_instrucao(10 downto 8);
    sel_reg_r1 <= s_instrucao(7 downto 5);
    
    -- Extensão para o JMP
    ext_jmp <= s_instrucao(10) & s_instrucao(10) & s_instrucao(10) & s_instrucao(10) & 
               s_instrucao(10) & s_instrucao(10 downto 0);

    -- Extensão para Matemática/Cargas com ZEROS
    ext_cte <= "00000000000" & s_instrucao(4 downto 0);

    constante_out <= ext_cte;

    -- Entrada do PC
    s_pc_in <= (s_pc_out - 1 + ext_jmp) when (opcode = "1111" and s_estado = "10") else
               ("00000" & s_instrucao(10 downto 0)) when ((opcode = "1001" or opcode = "1010") and s_estado = "10") else 
               (s_pc_out + 1);

    -- O PC só atualiza se não houver exceção
    s_pc_wr_en <= '1' when (s_estado = "00" and exc_ram_in = '0') else
                  '1' when (s_estado = "10" and s_condicao_atendida = '1' and exc_ram_in = '0') else
                  '0';

    
    --Só grava se exc_ram_in = '0'
    wr_en_banco <= '1' when (s_estado = "10" and exc_ram_in = '0') and (opcode = "0001" or opcode = "0100" or opcode = "1011") else '0';

    wr_en_acc <= '1' when (s_estado = "10" and exc_ram_in = '0') and (opcode = "0011" or opcode = "0101" or opcode = "0110" or opcode = "1000" or opcode = "0111" or opcode = "1110") else '0';
   
    wr_en_ram <= '1' when (s_estado = "10" and opcode = "1100" and exc_ram_in = '0') else '0';

    -- Selecao ULA
    sel_operacao <= "101" when opcode = "1110" else -- SLR   
                    "001" when (opcode = "1000" or opcode = "0110" or opcode = "0010" or opcode = "1101" or opcode = "1001" or opcode = "1010") else 
                    "100" when opcode = "0011" else 
                    "000"; 
                    
    -- MUX Data
    sel_mux_data <= "10" when opcode = "1011" else 
                    "01" when opcode = "0001" else 
                    "00";                          

    -- MUX ULA
    sel_mux_ula  <= '1' when (opcode = "0110" or opcode = "0111" or opcode = "1101" or opcode = "0100") else '0'; 

    s_wr_flags  <= '1' when (s_estado = "10" and exc_ram_in = '0') and (opcode = "0101" or opcode = "0111" or opcode = "0110" or opcode = "1000" or opcode = "0010" or opcode = "1101" or opcode = "1110") else '0';
    
    maquinaEstados1 : maquinaEstados port map (
        clk    => clk,
        rst    => rst,
        estado => s_estado
    );

    pc1 : pc port map (
        clk      => clk,
        rst      => rst,
        wr_en    => s_pc_wr_en, 
        data_in  => s_pc_in,   
        data_out => s_pc_out   
    );

    rom1: rom port map (
        clk      => clk,
        endereco => s_pc_out(5 downto 0), 
        dado     => s_saida_rom
    );

    
    pc_out    <= s_pc_out;
    saida_rom <= s_saida_rom; 

end architecture;