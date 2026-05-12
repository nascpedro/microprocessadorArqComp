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
             sel_operacao  : out unsigned(2 downto 0);
             sel_reg_wr    : out unsigned(2 downto 0);
             sel_reg_r1    : out unsigned(2 downto 0);
             sel_mux_ula   : out std_logic;
             sel_mux_data  : out std_logic
       );
    end component;

    component top_level is
       port( clk           : in std_logic;
             rst           : in std_logic;
             constante_ext : in unsigned(15 downto 0);
             wr_en_banco   : in std_logic;
             wr_en_acc     : in std_logic;
             sel_operacao  : in unsigned(2 downto 0);
             sel_reg_wr    : in unsigned(2 downto 0);
             sel_reg_r1    : in unsigned(2 downto 0);
             sel_mux_ula   : in std_logic;
             sel_mux_data  : in std_logic
       );
    end component;

    -- Sinais de ligação entre a UC e o top_level
    signal w_const  : unsigned(15 downto 0);
    signal w_wr_b   : std_logic;
    signal w_wr_a   : std_logic;
    signal w_m_ula  : std_logic;
    signal w_m_data : std_logic;
    signal w_sel_op : unsigned(2 downto 0);
    signal w_sel_w  : unsigned(2 downto 0);
    signal w_sel_r  : unsigned(2 downto 0);

begin
    inst_uc: uc port map (
        clk => clk, 
        rst => rst, 
        constante_out => w_const, 
        wr_en_banco => w_wr_b, 
        wr_en_acc => w_wr_a,
        sel_operacao => w_sel_op, 
        sel_reg_wr => w_sel_w, 
        sel_reg_r1 => w_sel_r,
        sel_mux_ula => w_m_ula, 
        sel_mux_data => w_m_data
    );

    inst_dp: top_level port map (
        clk => clk, 
        rst => rst, 
        constante_ext => w_const,
        wr_en_banco => w_wr_b, 
        wr_en_acc => w_wr_a,
        sel_operacao => w_sel_op,
        sel_reg_wr => w_sel_w, 
        sel_reg_r1 => w_sel_r,
        sel_mux_ula => w_m_ula, 
        sel_mux_data => w_m_data
    );
end architecture;