library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity top_level is
    port( clk       : in std_logic;
          rst       : in std_logic;
          constante_ext : in unsigned(15 downto 0); -- cte que vem de fora

          wr_en_banco        : in std_logic;
          wr_en_acc          : in std_logic;
          sel_operacao       : in unsigned(1 downto 0);
          sel_reg_wr         : in unsigned(2 downto 0);
          sel_reg_r1         : in unsigned(2 downto 0);

          sel_mux_ula        : in std_logic; -- 0: entra do banco, 1: entra a constante
          sel_mux_data: in std_logic -- 0: grava o resultado da ULA, 1: grava a constante
    );
end entity;

architecture a_top_level of top_level is

    component bancoRegs16bits is          
         port( clk       : in std_logic;
               rst       : in std_logic;
               wr_en     : in std_logic;
               data_wr   : in unsigned(15 downto 0);
               reg_wr    : in unsigned(2 downto 0);
               reg_r1    : in unsigned(2 downto 0);
               data_r1   : out unsigned(15 downto 0)
         );
    end component;

    component ula is
        port (   entr0, entr1                    :  in  unsigned(15 downto 0);
                 sel_operacao                    :  in  unsigned (1 downto 0);
                 saida                           :  out unsigned(15 downto 0);
                 flag_N, flag_C, flag_Z, flag_V  :  out std_logic
 
        );
    end component;

    component reg16bits is
        port( clk      : in std_logic;
              rst      : in std_logic;
              wr_en    : in std_logic;
              data_in  : in unsigned(15 downto 0);
              data_out : out unsigned(15 downto 0)
        );
    end component;

    -- Fios que saem dos componentes
    signal s_saida_banco   : unsigned(15 downto 0);
    signal s_saida_acc     : unsigned(15 downto 0);
    signal s_saida_ula     : unsigned(15 downto 0);
    
    -- Fios que saem dos MUX
    signal s_entr1_ula     : unsigned(15 downto 0);
    signal s_dado_escrita  : unsigned(15 downto 0);

    -- Fios para as flags da ula:
    signal s_flag_N, s_flag_C, s_flag_Z, s_flag_V : std_logic;

begin
    -- MUX 1: O que entra na porta 1 da ULA?
    s_entr1_ula <= constante_ext when sel_mux_ula = '1' else s_saida_banco;

    -- MUX 2: O que vai ser gravado nos registradores/acumulador? 
    s_dado_escrita <= constante_ext when sel_mux_data = '1' else s_saida_ula;

    -- Banco de Registradores
    banco: bancoRegs16bits port map (
        clk => clk, rst => rst, wr_en => wr_en_banco, 
        data_wr => s_dado_escrita, reg_wr => sel_reg_wr, reg_r1 => sel_reg_r1, 
        data_r1 => s_saida_banco
    );  

    -- ACUMULADOR
    acumulador: reg16bits port map (
        clk => clk, rst => rst, wr_en => wr_en_acc, 
        data_in => s_dado_escrita, 
        data_out => s_saida_acc
    );

    --ULA
    ula_inst: ula port map (
        entr0 => s_saida_acc, 
        entr1 => s_entr1_ula, 
        sel_operacao => sel_operacao, 
        saida => s_saida_ula,
        flag_N => s_flag_N, flag_C => s_flag_C, flag_Z => s_flag_Z, flag_V => s_flag_V
    );

end architecture;