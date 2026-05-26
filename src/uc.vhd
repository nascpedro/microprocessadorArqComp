library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;   

entity uc is
   port( clk           : in std_logic;
         rst           : in std_logic;

         pc_out        : out unsigned(15 downto 0);
         saida_rom     : out unsigned(14 downto 0);

         constante_out : out unsigned(15 downto 0); -- para passar a constante estendida para o top_level
         wr_en_banco   : out std_logic; -- para controlar a escrita no banco de registradores
         wr_en_acc     : out std_logic; -- para controlar a escrita no acumulador
         sel_operacao  : out unsigned(2 downto 0); -- para controlar a operação da ULA
         sel_reg_wr    : out unsigned(2 downto 0); -- para selecionar o registrador de escrita no banco
         sel_reg_r1    : out unsigned(2 downto 0); -- para selecionar o registrador de leitura 1 no banco
         sel_mux_ula   : out std_logic; -- para selecionar a entrada da ULA (0: banco, 1: constante)
         sel_mux_data  : out std_logic -- para selecionar o dado a ser escrito (0: resultado da ULA, 1: constante)
        
         N_in : in std_logic; -- para receber a flag N da ULA    
         C_in : in std_logic; -- para receber a flag C da ULA
         Z_in : in std_logic; -- para receber a flag Z da ULA
         V_in : in std_logic -- para receber a flag V da ULA        
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
              endereco : in unsigned(6 downto 0);
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
    signal ext_jmp : unsigned(15 downto 0);
    signal ext_cte : unsigned(15 downto 0);
    
    -- Sinais flip-flop para as flags da ULA
    signal s_flag_N : std_logic;
    signal s_flag_C : std_logic;
    signal s_flag_Z : std_logic;    
    signal s_flag_V : std_logic;

begin

    -- ir: registrador de instrução. Atualiza no estado 1, lendo direto da ROM (pois o PC ainda não atualizou)
    -- Conforme sorteio: wr_en no segundo estado (s_estado = '1')
    process(clk, rst)
    begin
        if rst = '1' then
            s_ir <= (others => '0');
        elsif rising_edge(clk) then
            if s_estado = "01" then -- No estado de Decode, salva a instrucao
                s_ir <= s_saida_rom;
            end if;
        end if;
    end process;
    
   process(clk,rst,wr_en)  
   begin
      if rst='1' then
         s_flag_N <= '0';
      elsif wr_en='1' then
         if rising_edge(clk) then
            s_flag_N <= N_in;
         end if;
      end if;
   end process;

   process(clk,rst,wr_en)  
   begin
      if rst='1' then
         s_flag_C <= '0';
      elsif wr_en='1' then
         if rising_edge(clk) then
            s_flag_C <= C_in;
         end if;
      end if;
   end process;

   process(clk,rst,wr_en)  
   begin
      if rst='1' then
         s_flag_Z <= '0';
      elsif wr_en='1' then
         if rising_edge(clk) then
            s_flag_Z <= Z_in;
         end if;
      end if;
   end process;
   
   process(clk,rst,wr_en)  
   begin
      if rst='1' then
         s_flag_V <= '0';
      elsif wr_en='1' then
         if rising_edge(clk) then
            s_flag_V <= V_in;
         end if;
      end if;
   end process;


    s_instrucao <= s_saida_rom when s_estado = "01" else s_ir; -- durante o estado 1, a instrucao é a que vem da ROM, depois é a que tá no IR


    -- Fatiamento da instrucao para obter opcode e campos de registradores
    opcode     <= s_instrucao(14 downto 11);
    sel_reg_wr <= s_instrucao(10 downto 8);
    sel_reg_r1 <= s_instrucao(7 downto 5);
    
    -- Extensão para o JMP (11 bits: copia o bit 10 seis vezes)
    ext_jmp <= s_instrucao(10) & s_instrucao(10) & s_instrucao(10) & s_instrucao(10) & 
               s_instrucao(10) & s_instrucao(10 downto 0);

    -- Extensão para Matemática/Cargas (5 bits: copia o bit 4 doze vezes)
    ext_cte <= s_instrucao(4) & s_instrucao(4) & s_instrucao(4) & s_instrucao(4) & s_instrucao(4) & 
               s_instrucao(4) & s_instrucao(4) & s_instrucao(4) & s_instrucao(4) & s_instrucao(4) & 
               s_instrucao(4) & s_instrucao(4 downto 0);

    constante_out <= ext_cte; -- para passar a constante estendida para o top_level

    -- Entrada do PC: Se for JMP no estado 2, faz o salto relativo compensando o +1 anterior pq
    -- de PC(2) pula +4 mas como no estado 0 vai para PC 3, entao vlta 1(-1) e pula o +4
    -- Caso contrário, prepara o PC + 1. ( pela logica do PC+1 gravado entre o primeiro e segundo estado)
    s_pc_in <= (s_pc_out - 1 + ext_jmp) when (opcode = "1111" and s_estado = "10") else 
               (s_pc_out + 1);

    -- Habilitação de escrita: Grava PC+1 no fim do estado 0 OU o JMP no fim do estado 2
    s_pc_wr_en <= '1' when (s_estado = "00") else
                  '1' when (s_estado = "10" and opcode = "1111") else
                  '0';

    -- Habilitação de escrita no banco: LD e MOV Rd,A
    wr_en_banco <= '1' when (s_estado = "10") and (opcode = "0001" or opcode = "0100") else '0';

    -- Habilitação de escrita no acumulador: MOV A, Rs; ADD A, Rs; SUBI A, cte
    wr_en_acc <= '1' when (s_estado = "10") and (opcode = "0011" or opcode = "0101" or opcode = "0110") else '0';

    -- Selecao ULA
    sel_operacao <= "001" when opcode = "0110" else -- SUBI (Subtracao)
                    "100" when opcode = "0011" else -- MOV A, Rs (Usa o "byPass" da entr1)
                    "000"; -- Padrao (ADD). O MOV Rd, A (0100) vai cair aqui pra somar com 0.  
                    
    -- MUX Data
    sel_mux_data <= '1' when opcode = "0001" else '0'; 

    -- MUX ULA
    sel_mux_ula <= '1' when (opcode = "0110" or opcode = "0100") else '0';

    
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
        endereco => s_pc_out(6 downto 0), 
        dado     => s_saida_rom
    );

    
    pc_out    <= s_pc_out;
    saida_rom <= s_saida_rom; 

end architecture;