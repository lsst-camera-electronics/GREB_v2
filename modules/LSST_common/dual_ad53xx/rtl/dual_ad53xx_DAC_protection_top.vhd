----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:47:43 04/17/2013 
-- Design Name: 
-- Module Name:    dual_ad53xx_DAC_protection_top - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dual_ad53xx_DAC_protection_top is

  port (
    clk             : in  std_logic;
    reset           : in  std_logic;
    start_write     : in  std_logic;
    start_ldac      : in  std_logic;
    bbs_switch_on   : in  std_logic;
    d_to_slave      : in  std_logic_vector(16 downto 0);
    command_error   : out std_logic_vector(5 downto 0);
    values_under_th : out std_logic_vector(5 downto 0);
    mosi            : out std_logic;
    ss_dac_0        : out std_logic;
    ss_dac_1        : out std_logic;
    sclk            : out std_logic;
    ldac            : out std_logic
    );

end dual_ad53xx_DAC_protection_top;

architecture Behavioral of dual_ad53xx_DAC_protection_top is

  component SPI_write is
    generic (clk_divide  : integer := 4;
             num_bit_max : integer := 16);
    port (
      clk         : in  std_logic;
      reset       : in  std_logic;
      start_write : in  std_logic;
      d_to_slave  : in  std_logic_vector(num_bit_max - 1 downto 0);
      mosi        : out std_logic;
      ss          : out std_logic;
      sclk        : out std_logic
      );
  end component;

  component ff_ce is
    port (
      reset    : in  std_logic;         -- syncronus reset
      clk      : in  std_logic;         -- clock
      data_in  : in  std_logic;         -- data in
      ce       : in  std_logic;         -- clock enable
      data_out : out std_logic);        -- data out
  end component;

  component demux_1_2_clk_def_1 is
    port (
      reset    : in  std_logic;                      -- syncronus reset
      clk      : in  std_logic;                      -- clock
      data_in  : in  std_logic;                      -- data in
      selector : in  std_logic;
      data_out : out std_logic_vector(1 downto 0));  -- data out
  end component;

  signal dac_selector : std_logic;

  signal start_write_delay_1 : std_logic;

  signal d_to_slave_delay_1 : std_logic_vector(15 downto 0);

  signal ss : std_logic;

  signal ldac_delay_1 : std_logic;
  signal ldac_delay_2 : std_logic;

  signal command_error_i   : std_logic_vector(5 downto 0);
  signal values_under_th_i : std_logic_vector(5 downto 0);

  constant GD_add : std_logic_vector(3 downto 0) := x"0";
  constant OD_add : std_logic_vector(3 downto 0) := x"5";
  constant RD_add : std_logic_vector(3 downto 0) := x"1";

  constant GD_th : std_logic_vector(11 downto 0) := x"472";
  constant OD_th : std_logic_vector(11 downto 0) := x"8E3";
  constant RD_th : std_logic_vector(11 downto 0) := x"660";


begin

  SPI_write_0 : SPI_write
    generic map (clk_divide  => 2,
                 num_bit_max => 16)
    port map (
      clk         => clk,
      reset       => reset,
      start_write => start_write_delay_1,
      d_to_slave  => d_to_slave_delay_1,
      mosi        => mosi,
      ss          => ss,
      sclk        => sclk
      );




-------------------------------------------------------------------------------
-- protection logic
-------------------------------------------------------------------------------
  process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        start_write_delay_1 <= '0';
        d_to_slave_delay_1  <= (others => '0');
        command_error_i     <= (others => '0');
        values_under_th_i   <= (others => '1');
      else
        if start_write = '1' and d_to_slave(15 downto 12) = GD_add then
          if d_to_slave(11 downto 0) < GD_th then
            if bbs_switch_on = '1' then
              start_write_delay_1 <= '0';
              d_to_slave_delay_1  <= (others => '0');
              if d_to_slave(16) = '0' then
                command_error_i(0) <= '1';
                command_error_i(3) <= command_error_i(3);
              else
                command_error_i(0) <= command_error_i(0);
                command_error_i(3) <= '1';
              end if;
              command_error_i(1) <= command_error_i(1);
              command_error_i(2) <= command_error_i(2);
              command_error_i(4) <= command_error_i(4);
              command_error_i(5) <= command_error_i(5);
              values_under_th_i  <= values_under_th_i;
            else
              start_write_delay_1 <= start_write;
              d_to_slave_delay_1  <= d_to_slave(15 downto 0);
              if d_to_slave(16) = '0' then
                command_error_i(0) <= '0';
                command_error_i(3) <= command_error_i(3);
              else
                command_error_i(0) <= command_error_i(0);
                command_error_i(3) <= '0';
              end if;
              command_error_i(1) <= command_error_i(1);
              command_error_i(2) <= command_error_i(2);
              command_error_i(4) <= command_error_i(4);
              command_error_i(5) <= command_error_i(5);
              if d_to_slave(16) = '0' then
                values_under_th_i(0) <= '1';
                values_under_th_i(3) <= values_under_th_i(3);
              else
                values_under_th_i(0) <= values_under_th_i(0);
                values_under_th_i(3) <= '1';
              end if;
              values_under_th_i(1) <= values_under_th_i(1);
              values_under_th_i(2) <= values_under_th_i(2);
              values_under_th_i(4) <= values_under_th_i(4);
              values_under_th_i(5) <= values_under_th_i(5);
            end if;
          else
            start_write_delay_1 <= start_write;
            d_to_slave_delay_1  <= d_to_slave(15 downto 0);
            if d_to_slave(16) = '0' then
              command_error_i(0) <= '0';
              command_error_i(3) <= command_error_i(3);
            else
              command_error_i(0) <= command_error_i(0);
              command_error_i(3) <= '0';
            end if;
            command_error_i(1) <= command_error_i(1);
            command_error_i(2) <= command_error_i(2);
            command_error_i(4) <= command_error_i(4);
            command_error_i(5) <= command_error_i(5);
            if d_to_slave(16) = '0' then
              values_under_th_i(0) <= '0';
              values_under_th_i(3) <= values_under_th_i(3);
            else
              values_under_th_i(0) <= values_under_th_i(0);
              values_under_th_i(3) <= '0';
            end if;
            values_under_th_i(1) <= values_under_th_i(1);
            values_under_th_i(2) <= values_under_th_i(2);
            values_under_th_i(4) <= values_under_th_i(4);
            values_under_th_i(5) <= values_under_th_i(5);
          end if;
          
        elsif start_write = '1' and d_to_slave(15 downto 12) = OD_add then
          if d_to_slave(11 downto 0) < OD_th then
            if bbs_switch_on = '1' then
              start_write_delay_1 <= '0';
              d_to_slave_delay_1  <= (others => '0');
              command_error_i(0)  <= command_error_i(0);
              if d_to_slave(16) = '0' then
                command_error_i(1) <= '1';
                command_error_i(4) <= command_error_i(4);
              else
                command_error_i(1) <= command_error_i(1);
                command_error_i(4) <= '1';
              end if;
              command_error_i(2) <= command_error_i(2);
              command_error_i(3) <= command_error_i(3);
              command_error_i(5) <= command_error_i(5);
              values_under_th_i  <= values_under_th_i;
            else
              start_write_delay_1 <= start_write;
              d_to_slave_delay_1  <= d_to_slave(15 downto 0);
              command_error_i(0)  <= command_error_i(0);
              if d_to_slave(16) = '0' then
                command_error_i(1) <= '0';
                command_error_i(4) <= command_error_i(4);
              else
                command_error_i(1) <= command_error_i(1);
                command_error_i(4) <= '0';
              end if;
              command_error_i(2) <= command_error_i(2);
              command_error_i(3) <= command_error_i(3);
              command_error_i(5) <= command_error_i(5);

              values_under_th_i(0) <= values_under_th_i(0);
              if d_to_slave(16) = '0' then
                values_under_th_i(1) <= '1';
                values_under_th_i(4) <= values_under_th_i(4);
              else
                values_under_th_i(1) <= values_under_th_i(1);
                values_under_th_i(4) <= '1';
              end if;
              values_under_th_i(2) <= values_under_th_i(2);
              values_under_th_i(3) <= values_under_th_i(3);
              values_under_th_i(5) <= values_under_th_i(5);
            end if;
          else
            start_write_delay_1 <= start_write;
            d_to_slave_delay_1  <= d_to_slave(15 downto 0);
            command_error_i(0)  <= command_error_i(0);
            if d_to_slave(16) = '0' then
              command_error_i(1) <= '0';
              command_error_i(4) <= command_error_i(4);
            else
              command_error_i(1) <= command_error_i(1);
              command_error_i(4) <= '0';
            end if;
            command_error_i(2) <= command_error_i(2);
            command_error_i(3) <= command_error_i(3);
            command_error_i(5) <= command_error_i(5);

            values_under_th_i(0) <= values_under_th_i(0);
            if d_to_slave(16) = '0' then
              values_under_th_i(1) <= '0';
              values_under_th_i(4) <= values_under_th_i(4);
            else
              values_under_th_i(1) <= values_under_th_i(1);
              values_under_th_i(4) <= '0';
            end if;
            values_under_th_i(2) <= values_under_th_i(2);
            values_under_th_i(3) <= values_under_th_i(3);
            values_under_th_i(5) <= values_under_th_i(5);
          end if;
          
          
        elsif start_write = '1' and d_to_slave(15 downto 12) = RD_add then
          if d_to_slave(11 downto 0) < RD_th then
            if bbs_switch_on = '1' then
              start_write_delay_1 <= '0';
              d_to_slave_delay_1  <= (others => '0');
              command_error_i(0)  <= command_error_i(0);
              command_error_i(1)  <= command_error_i(1);
              command_error_i(3)  <= command_error_i(3);
              command_error_i(4)  <= command_error_i(4);
              if d_to_slave(16) = '0' then
                command_error_i(2) <= '1';
                command_error_i(5) <= command_error_i(5);
              else
                command_error_i(2) <= command_error_i(2);
                command_error_i(5) <= '1';
              end if;

              values_under_th_i <= values_under_th_i;
            else
              start_write_delay_1 <= start_write;
              d_to_slave_delay_1  <= d_to_slave(15 downto 0);
              command_error_i(0)  <= command_error_i(0);
              command_error_i(1)  <= command_error_i(1);
              command_error_i(3)  <= command_error_i(3);
              command_error_i(4)  <= command_error_i(4);
              if d_to_slave(16) = '0' then
                command_error_i(2) <= '0';
                command_error_i(5) <= command_error_i(5);
              else
                command_error_i(2) <= command_error_i(2);
                command_error_i(5) <= '0';
              end if;

              values_under_th_i(0) <= values_under_th_i(0);
              values_under_th_i(1) <= values_under_th_i(1);
              values_under_th_i(3) <= values_under_th_i(3);
              values_under_th_i(4) <= values_under_th_i(4);
              if d_to_slave(16) = '0' then
                values_under_th_i(2) <= '1';
                values_under_th_i(5) <= values_under_th_i(5);
              else
                values_under_th_i(2) <= values_under_th_i(2);
                values_under_th_i(5) <= '1';
              end if;
            end if;
          else
            start_write_delay_1 <= start_write;
            d_to_slave_delay_1  <= d_to_slave(15 downto 0);
            command_error_i(0)  <= command_error_i(0);
            command_error_i(1)  <= command_error_i(1);
            command_error_i(3)  <= command_error_i(3);
            command_error_i(4)  <= command_error_i(4);
            if d_to_slave(16) = '0' then
              command_error_i(2) <= '0';
              command_error_i(5) <= command_error_i(5);
            else
              command_error_i(2) <= command_error_i(2);
              command_error_i(5) <= '0';
            end if;
            values_under_th_i(0) <= values_under_th_i(0);
            values_under_th_i(1) <= values_under_th_i(1);
            values_under_th_i(3) <= values_under_th_i(3);
            values_under_th_i(4) <= values_under_th_i(4);
            if d_to_slave(16) = '0' then
              values_under_th_i(2) <= '0';
              values_under_th_i(5) <= values_under_th_i(5);
            else
              values_under_th_i(2) <= values_under_th_i(2);
              values_under_th_i(5) <= '0';
            end if;
          end if;
        else
          start_write_delay_1 <= start_write;
          d_to_slave_delay_1  <= d_to_slave(15 downto 0);
          command_error_i     <= command_error_i;
          values_under_th_i   <= values_under_th_i;
        end if;
      end if;
    end if;
  end process;


  command_error   <= command_error_i;
  values_under_th <= values_under_th_i;



  dac_selector_ff : ff_ce
    port map (
      reset    => reset,
      clk      => clk,
      data_in  => d_to_slave(16),
      ce       => start_write,
      data_out => dac_selector); 


  ss_demux : demux_1_2_clk_def_1
    port map (
      reset       => reset,
      clk         => clk,
      data_in     => ss,
      selector    => dac_selector,
      data_out(0) => ss_dac_0,
      data_out(1) => ss_dac_1);

  ldac_delay_ff_1 : ff_ce
    port map (
      reset    => reset,
      clk      => clk,
      data_in  => start_ldac,
      ce       => '1',
      data_out => ldac_delay_1); 

  ldac_delay_ff_2 : ff_ce
    port map (
      reset    => reset,
      clk      => clk,
      data_in  => ldac_delay_1,
      ce       => '1',
      data_out => ldac_delay_2); 

  ldac <= not(ldac_delay_1 or ldac_delay_2);

end Behavioral;

