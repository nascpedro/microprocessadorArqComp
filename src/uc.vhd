library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;   

entity uc is
   port( clk       : in std_logic;
         rst       : in std_logic;
         pc_out    : out unsigned(15 downto 0);
         saida_rom : out unsigned(14 downto 0);
         estado    : out unsigned(1 downto 0);   
         wr_en_banco    : out std_logic;
         wr_en_acc      : out std_logic;
         sel_operacao   : out unsigned(2 downto 0);
         sel_mux_ula    : out std_logic;
         sel_mux_data   : out std_logic;
         endereco_rd    : out unsigned(2 downto 0);
         endereco_rs    : out unsigned(2 downto 0);
         constante_ext  : out unsigned(15 downto 0)     
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
              estado    : out unsigned(1 downto 0)
        );
    end component;

    -- Sinais internos
    signal s_pc_out       : unsigned(15 downto 0);
    signal s_pc_in        : unsigned(15 downto 0);
    signal s_pc_wr_en     : std_logic;
    signal s_estado       : unsigned(1 downto 0);
    signal s_saida_rom    : unsigned(14 downto 0);
    signal opcode         : unsigned(3 downto 0);
    signal extensao_jmp   : unsigned(15 downto 0);
    signal s_cte_ext      : unsigned(15 downto 0);

begin

    -- ir: registrador de instrução. Atualiza no estado 1, lendo direto da ROM (pois o PC ainda não atualizou)
    -- Conforme sorteio: wr_en no segundo estado (s_estado = '1')
    process(clk, rst)
    begin
        if rst = '1' then
            s_ir <= (others => '0');
        elsif rising_edge(clk) then
            if s_estado = "00" then
                s_ir <= s_saida_rom;
            end if;
        end if;
    end process;

    opcode <= s_ir(14 downto 11); 
    endereco_rd <= s_ir(10 downto 8);
    endereco_rs <= s_ir(7 downto 5);
    
    -- Extensão de sinal 
    extensao_jmp <= s_ir(10) & s_ir(10) & s_ir(10) & s_ir(10) & s_ir(10) & s_ir(10 downto 0);
    -- Extensão de 5 bits para a Constante do LD e SUBI
    s_cte_ext <= s_ir(4) & s_ir(4) & s_ir(4) & s_ir(4) & s_ir(4) & s_ir(4) & s_ir(4) & 
                 s_ir(4) & s_ir(4) & s_ir(4) & s_ir(4) & s_ir(4 downto 0);

    constante_ext <= s_cte_ext;
    
    -- Entrada do PC: Se for JMP no estado 1, faz o salto relativo compensando o +1 anterior pois
    -- de PC(2) pula +4 mas como no estado 0 vai para PC 3, entao volta 1(-1) e pula o +4
    -- Caso contrário, prepara o PC + 1. ( pela logica do PC+1 gravado entre o primeiro e segundo estado)
    s_pc_in <= (s_pc_out - 1 + extensao_jmp) when (opcode = "1111" and s_estado = "01") else 
               (s_pc_out + 1);

    -- Habilitação de escrita: Grava PC+1 no fim do estado 0 OU o JMP no fim do estado 1
    s_pc_wr_en <= '1' when (s_estado = "00") else
                  '1' when (s_estado = "01" and opcode = "1111") else
                  '0';

    -- 0001 = LD, 0100 = MOV Rd, A
    wr_en_banco <= '1' when (s_estado = "10" and (opcode = "0001" or opcode = "0100")) else '0';
    
    -- 0011 = MOV A, Rs ; 0101 = ADD ; 0110 = SUBI
    wr_en_acc   <= '1' when (s_estado = "10" and (opcode = "0011" or opcode = "0101" or opcode = "0110")) else '0';

    -- sel_mux_ula = '1' joga a constante na ULA para a instrução SUBI (0110).
    sel_mux_ula  <= '1' when opcode = "0110" else '0';
    
    -- sel_mux_data = '1' joga a constante no Banco. LD (0001) faz isso.
    sel_mux_data <= '1' when opcode = "0001" else '0';

    -- Seleção da Operação da ULA (Você precisa alinhar isso com os códigos da sua ULA real!)
    -- Exemplo assumindo: "00" = Soma, "01" = Subtração, "10" = Identidade (Pass-through)
    sel_operacao <= "00" when opcode = "0101" else -- O opcode 0101 aciona a Soma na ULA
                    "01" when opcode = "0110" else -- O opcode 0110 aciona a Subtração na ULA
                    "10" when opcode =                          -- MOV
                    

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