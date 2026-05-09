library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;   

entity proto_uc is
   port( clk      : in std_logic;
         rst      : in std_logic;
         pc_out   : out unsigned(15 downto 0);
         saida_rom : out unsigned(14 downto 0)
   );
end entity;

architecture a_proto_uc of proto_uc is
    
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

    signal s_pc_out : unsigned(15 downto 0);
    signal s_pc_in  : unsigned(15 downto 0);
    signal s_estado   : std_logic;
    signal s_saida_rom : unsigned(14 downto 0); 
begin
    s_pc_in <= s_pc_out + 1;

    maquinaEstados1 : maquinaEstados port map (
        clk => clk,
        rst => rst,
        estado => s_estado
    );

    pc1 : pc port map (
        clk      => clk,
        rst      => rst,
        wr_en    => estado, 
        data_in  => s_pc_in,   
        data_out => s_pc_out   
    );
    
    pc_out <= s_pc_out;

    rom1: rom port map (
        clk      => clk,
        endereco => s_pc_out(6 downto 0), 
        dado     => s_saida_rom
    );
end architecture;
