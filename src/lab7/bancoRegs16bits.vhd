library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 

entity bancoRegs16bits is
   port( clk      : in std_logic;
         rst      : in std_logic;
         wr_en    : in std_logic;
         data_wr  : in unsigned(15 downto 0);
         reg_wr   : in unsigned(2 downto 0);
         reg_r1   : in unsigned(2 downto 0);
         data_r1  : out unsigned(15 downto 0)
   );
end entity;

architecture a_bancoRegs16bits of bancoRegs16bits is

      component reg16bits is          
         port( clk      : in std_logic;
               rst      : in std_logic;
               wr_en    : in std_logic;
               data_in  : in unsigned(15 downto 0);
               data_out : out unsigned(15 downto 0)
         );
      end component;

      -- Saida de dados de cada reg
      signal output_reg0, output_reg1, output_reg2, output_reg3, output_reg4, 
             output_reg5, output_reg6: unsigned(15 downto 0);

      -- Habilitar escrita de cada reg individualmente
      signal we_reg0, we_reg1, we_reg2, we_reg3, we_reg4, we_reg5, we_reg6: std_logic;

begin
      R0: reg16bits port map (clk => clk, rst => rst, wr_en => we_reg0, data_in => data_wr, data_out => output_reg0);
      R1: reg16bits port map (clk => clk, rst => rst, wr_en => we_reg1, data_in => data_wr, data_out => output_reg1);
      R2: reg16bits port map (clk => clk, rst => rst, wr_en => we_reg2, data_in => data_wr, data_out => output_reg2);
      R3: reg16bits port map (clk => clk, rst => rst, wr_en => we_reg3, data_in => data_wr, data_out => output_reg3);
      R4: reg16bits port map (clk => clk, rst => rst, wr_en => we_reg4, data_in => data_wr, data_out => output_reg4);
      R5: reg16bits port map (clk => clk, rst => rst, wr_en => we_reg5, data_in => data_wr, data_out => output_reg5);
      R6: reg16bits port map (clk => clk, rst => rst, wr_en => we_reg6, data_in => data_wr, data_out => output_reg6);
      
      -- Lógica de escrita: ativa o wr_en do reg selecionado por reg_wr
      we_reg0 <= wr_en when reg_wr = "000" else '0';
      we_reg1 <= wr_en when reg_wr = "001" else '0';
      we_reg2 <= wr_en when reg_wr = "010" else '0';
      we_reg3 <= wr_en when reg_wr = "011" else '0';
      we_reg4 <= wr_en when reg_wr = "100" else '0';
      we_reg5 <= wr_en when reg_wr = "101" else '0';
      we_reg6 <= wr_en when reg_wr = "110" else '0';


      -- Lógica de leitura: seleciona a saída do reg indicado por reg_r1 e nao precisa de outros por usar acumulador
      data_r1 <= output_reg0 when reg_r1 = "000" else
                 output_reg1 when reg_r1 = "001" else
                 output_reg2 when reg_r1 = "010" else
                 output_reg3 when reg_r1 = "011" else
                 output_reg4 when reg_r1 = "100" else
                 output_reg5 when reg_r1 = "101" else
                 output_reg6 when reg_r1 = "110" else
                 "0000000000000000";
      

end  architecture ; 

