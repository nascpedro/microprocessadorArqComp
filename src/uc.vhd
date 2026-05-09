library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;   

entity uc is
   port( clk       : in std_logic;
         rst       : in std_logic;
         pc_out    : out unsigned(15 downto 0);
         saida_rom : out unsigned(14 downto 0)
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
              estado   : out std_logic
        );
    end component;

    -- Sinais internos
    signal s_pc_out       : unsigned(15 downto 0);
    signal s_pc_in        : unsigned(15 downto 0);
    signal s_pc_wr_en     : std_logic;
    signal s_estado       : std_logic;
    signal s_saida_rom    : unsigned(14 downto 0);
    signal opcode         : unsigned(3 downto 0);
    signal extensao_sinal : unsigned(15 downto 0);
    signal s_ir           : unsigned(14 downto 0);

begin

    -- ir: registrador de instrução. Atualiza no estado 1, lendo direto da ROM (pois o PC ainda não atualizou)
    -- Conforme sorteio: wr_en no segundo estado (s_estado = '1')
    process(clk, rst)
    begin
        if rst = '1' then
            s_ir <= (others => '0');
        elsif rising_edge(clk) then
            if s_estado = '1' then
                s_ir <= s_saida_rom;
            end if;
        end if;
    end process;

    -- Durante o estado 1, lemos direto da ROM pois o IR ainda não atualizou
    opcode <= s_saida_rom(14 downto 11) when s_estado = '1' else s_ir(14 downto 11);
    
    -- Extensão de sinal 
    extensao_sinal <= s_saida_rom(10) & s_saida_rom(10) & s_saida_rom(10) 
                    & s_saida_rom(10) & s_saida_rom(10) & s_saida_rom(10 downto 0)
                    when s_estado = '1' else
                    s_ir(10) & s_ir(10) & s_ir(10) 
                    & s_ir(10) & s_ir(10) & s_ir(10 downto 0);

    -- Entrada do PC: Se for JMP no estado 1, faz o salto relativo compensando o +1 anterior pq
    -- de PC(2) pula +4 mas como no estado 0 vai para PC 3, entao vlta 1(-1) e pula o +4
    -- Caso contrário, prepara o PC + 1. ( pela logica do PC+1 gravado entre o primeiro e segundo estado)
    s_pc_in <= (s_pc_out - 1 + extensao_sinal) when (opcode = "1111" and s_estado = '1') else 
               (s_pc_out + 1);

    -- Habilitação de escrita: Grava PC+1 no fim do estado 0 OU o JMP no fim do estado 1
    s_pc_wr_en <= '1' when (s_estado = '0') else
                  '1' when (s_estado = '1' and opcode = "1111") else
                  '0';

    
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