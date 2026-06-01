library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processador is
    port( clk : in std_logic;
          rst : in std_logic
    );
end entity;

architecture a_processador of processador is
    component uc is
       port( clk           : in std_logic; 
             rst           : in std_logic;
             pc_out        : out unsigned(15 downto 0); 
             saida_rom     : out unsigned(14 downto 0);
             constante_out : out unsigned(15 downto 0);
             wr_en_banco   : out std_logic; 
             wr_en_acc     : out std_logic;
             wr_en_ram     : out std_logic;               -- controle de escrita da RAM
             sel_operacao  : out unsigned(2 downto 0);
             sel_reg_wr    : out unsigned(2 downto 0);
             sel_reg_r1    : out unsigned(2 downto 0);
             sel_mux_ula   : out std_logic;
             sel_mux_data  : out unsigned(1 downto 0);    -- seleção de dado a ser escrito (ULA, constante ou RAM)
             N_in          : in std_logic;
             C_in          : in std_logic;
             Z_in          : in std_logic;
             V_in          : in std_logic
       );
    end component;

    component top_level is
       port( clk              : in std_logic;
             rst              : in std_logic;
             constante_ext    : in unsigned(15 downto 0);
             dado_ram_in      : in unsigned(15 downto 0); -- leitura da RAM para o top_level
             wr_en_banco      : in std_logic;
             wr_en_acc        : in std_logic;
             sel_operacao     : in unsigned(2 downto 0);
             sel_reg_wr       : in unsigned(2 downto 0);
             sel_reg_r1       : in unsigned(2 downto 0);
             sel_mux_ula      : in std_logic;
             sel_mux_data     : in unsigned(1 downto 0);  -- seleção de dado a ser escrito (ULA, constante ou RAM)
             saida_banco      : out unsigned(15 downto 0);-- saída assíncrona do banco de registradores para ser a entrada da RAM
             saida_acumulador : out unsigned(15 downto 0);-- saída do acumulador para ser a entrada da RAM
             N_out            : out std_logic;
             C_out            : out std_logic;
             Z_out            : out std_logic;
             V_out            : out std_logic  
       );
    end component;

    component ram is
        port( clk      : in std_logic;
              endereco : in unsigned(6 downto 0);
              wr_en    : in std_logic;
              dado_in  : in unsigned(15 downto 0);
              dado_out : out unsigned(15 downto 0)
        );
    end component;
    
    -- Sinais de ligação entre a UC e o top_level
    signal w_const  : unsigned(15 downto 0);
    signal w_wr_b   : std_logic;
    signal w_wr_a   : std_logic;
    signal w_m_ula  : std_logic;
    signal w_m_data : unsigned(1 downto 0); -- Ajustado para 2 bits
    signal w_sel_op : unsigned(2 downto 0);
    signal w_sel_w  : unsigned(2 downto 0);
    signal w_sel_r  : unsigned(2 downto 0);
        
    signal s_flag_N : std_logic;
    signal s_flag_C : std_logic;
    signal s_flag_Z : std_logic;
    signal s_flag_V : std_logic;

    -- Sinais exclusivos da RAM
    signal s_endereco_ram : unsigned(15 downto 0); -- Expandido para 16 bits para receber do banco
    signal s_dado_in_ram  : unsigned(15 downto 0);  
    signal s_dado_out_ram : unsigned(15 downto 0); -- Saída do RAM 
    signal s_wr_en_ram    : std_logic := '0';      -- Controle de escrita da RAM

begin
    inst_uc: uc port map (
        clk           => clk, 
        rst           => rst, 
        constante_out => w_const, 
        wr_en_banco   => w_wr_b, 
        wr_en_acc     => w_wr_a,
        wr_en_ram     => s_wr_en_ram, -- Ligando o controle de escrita da RAM à UC
        sel_operacao  => w_sel_op, 
        sel_reg_wr    => w_sel_w, 
        sel_reg_r1    => w_sel_r,
        sel_mux_ula   => w_m_ula, 
        sel_mux_data  => w_m_data,
        N_in          => s_flag_N,
        C_in          => s_flag_C,
        Z_in          => s_flag_Z,
        V_in          => s_flag_V
    );

    inst_dp: top_level port map (
        clk              => clk, 
        rst              => rst, 
        constante_ext    => w_const,
        dado_ram_in      => s_dado_out_ram, -- ENTRA no top_level a leitura da RAM
        wr_en_banco      => w_wr_b, 
        wr_en_acc        => w_wr_a,
        sel_operacao     => w_sel_op,
        sel_reg_wr       => w_sel_w, 
        sel_reg_r1       => w_sel_r,
        sel_mux_ula      => w_m_ula, 
        sel_mux_data     => w_m_data,
        saida_banco      => s_endereco_ram, -- Usando a saída do banco de registradores como endereço para a RAM
        saida_acumulador => s_dado_in_ram,  -- Usando a saída do acumulador como dado de escrita para a RAM
        N_out            => s_flag_N,
        C_out            => s_flag_C,
        Z_out            => s_flag_Z,
        V_out            => s_flag_V
    );

    inst_ram: ram port map (
        clk      => clk,
        endereco => s_endereco_ram(6 downto 0), -- Fatiamento para 7 bits
        wr_en    => s_wr_en_ram,
        dado_in  => s_dado_in_ram,
        dado_out => s_dado_out_ram
    );

end architecture;