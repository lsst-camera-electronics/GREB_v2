----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:06:09 07/08/2016 
-- Design Name: 
-- Module Name:    dual_ads1118_top - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.dual_ads1118_top_package.all;

entity dual_ads1118_top is

  port (
    clk           : in  std_logic;
    reset         : in  std_logic;
    start_read    : in  std_logic;
    device_select : in  std_logic;
    miso          : in  std_logic;
    mosi          : out std_logic;
    ss_adc_1      : out std_logic;
    ss_adc_2      : out std_logic;
    sclk          : out std_logic;
    link_busy     : out std_logic;
    data_from_adc : out array432
    );

end dual_ads1118_top;

architecture Behavioral of dual_ads1118_top is

  component dual_ads1118_controller_fsm
    port (
      clk            : in  std_logic;
      reset          : in  std_logic;
      start_read     : in  std_logic;
      spi_busy       : in  std_logic;
      device_busy    : in  std_logic;
      start_spi      : out std_logic;
      link_busy      : out std_logic;
      data_to_spi    : out std_logic_vector(15 downto 0);
      out_reg_en_bus : out std_logic_vector(3 downto 0));
  end component;

  component SPI_read_write_noss is
    generic (clk_divide  : integer := 4;
             num_bit_max : integer := 32);
    port (
      clk          : in  std_logic;
      reset        : in  std_logic;
      start_write  : in  std_logic;
      d_to_slave   : in  std_logic_vector(num_bit_max - 1 downto 0);
      miso         : in  std_logic;
      mosi         : out std_logic;
      ss           : out std_logic;
      sclk         : out std_logic;
      busy         : out std_logic;
      d_from_slave : out std_logic_vector(num_bit_max - 1 downto 0)
      );
  end component;

  component generic_reg_ce_init is
    generic (width : integer := 15);
    port (
      reset    : in  std_logic;         -- syncronus reset
      clk      : in  std_logic;         -- clock
      ce       : in  std_logic;         -- clock enable
      init     : in  std_logic;  -- signal to reset the reg (active high)
      data_in  : in  std_logic_vector(width downto 0);   -- data in
      data_out : out std_logic_vector(width downto 0));  -- data out
  end component;

  component demux_1_2_clk_def_1
    port (
      reset    : in  std_logic;
      clk      : in  std_logic;
      data_in  : in  std_logic;
      selector : in  std_logic;
      data_out : out std_logic_vector(1 downto 0));
  end component;

  component ff_ce is
    port (
      reset    : in  std_logic;         -- syncronus reset
      clk      : in  std_logic;         -- clock
      data_in  : in  std_logic;         -- data in
      ce       : in  std_logic;         -- clock enable
      data_out : out std_logic);        -- data out
  end component;

  signal spi_busy          : std_logic;
  signal start_spi         : std_logic;
  signal device_select_int : std_logic;
  signal data_to_spi_16    : std_logic_vector(15 downto 0);
  signal data_to_spi       : std_logic_vector(31 downto 0);
  signal out_reg_en_bus    : std_logic_vector(3 downto 0);
  signal data_from_spi     : std_logic_vector(31 downto 0);
  signal ss_bus            : std_logic_vector(1 downto 0);

  signal ss_int   : std_logic;
  signal miso_int : std_logic;
  signal mosi_int : std_logic;
  signal sclk_int : std_logic;

begin

  dual_ads1118_controller_fsm_1 : dual_ads1118_controller_fsm
    port map (
      clk            => clk,
      reset          => reset,
      start_read     => start_read,
      spi_busy       => spi_busy,
      device_busy    => miso_int,
      start_spi      => start_spi,
      link_busy      => link_busy,
      data_to_spi    => data_to_spi_16,
      out_reg_en_bus => out_reg_en_bus);

  ff_ce_1 : ff_ce
    port map (
      reset    => reset,
      clk      => clk,
      data_in  => device_select,
      ce       => start_read,
      data_out => device_select_int);

  SPI_read_write_noss_1 : SPI_read_write_noss
    generic map (
      clk_divide  => 10,
      num_bit_max => 32)
    port map (
      clk          => clk,
      reset        => reset,
      start_write  => start_spi,
      d_to_slave   => data_to_spi,
      miso         => miso_int,
      mosi         => mosi_int,
      ss           => ss_int,
      sclk         => sclk_int,
      busy         => spi_busy,
      d_from_slave => data_from_spi);



  spi_out_reg_generate :
  for i in 0 to 3 generate
    out_reg : generic_reg_ce_init
      generic map(width => 31)
      port map (
        reset    => reset,
        clk      => clk,
        ce       => out_reg_en_bus(i),
        init     => '0',
        data_in  => data_from_spi,
        data_out => data_from_adc(i)
        );
  end generate;



  ff_ce_mosi : ff_ce
    port map (
      reset    => reset,
      clk      => clk,
      data_in  => mosi_int,
      ce       => '1',
      data_out => mosi);

  ff_ce_miso : ff_ce
    port map (
      reset    => reset,
      clk      => clk,
      data_in  => miso,
      ce       => '1',
      data_out => miso_int);

  ff_ce_sckl : ff_ce
    port map (
      reset    => reset,
      clk      => clk,
      data_in  => sclk_int,
      ce       => '1',
      data_out => sclk);

  demux_1_2_clk_def_1_1 : demux_1_2_clk_def_1
    port map (
      reset    => reset,
      clk      => clk,
      data_in  => ss_int,
      selector => device_select_int,
      data_out => ss_bus);

  data_to_spi <= data_to_spi_16 & x"0000";
  ss_adc_1    <= ss_bus(0);
  ss_adc_2    <= ss_bus(1);
  
end Behavioral;
