----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:21:09 5/07/2016 
-- Design Name: 
-- Module Name:    max_11046_multiple_3_top - Behavioral 
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

use work.max_11046_top_package.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity max_11046_multiple_3_top is
  
  port (
    clk              : in  std_logic;
    reset            : in  std_logic;
    start_write      : in  std_logic;
    start_read       : in  std_logic;
    EOC_ck           : in  std_logic;
    EOC_ccd1         : in  std_logic;
    EOC_ccd2         : in  std_logic;
    data_to_adc      : in  std_logic_vector(5 downto 0);
    data_from_adc    : in  std_logic_vector(15 downto 0);
    link_busy        : out std_logic;
    CS_ck            : out std_logic;
    CS_ccd1          : out std_logic;
    CS_ccd2          : out std_logic;
    RD               : out std_logic;
    WR               : out std_logic;
    CONVST_ck        : out std_logic;
    CONVST_ccd1      : out std_logic;
    CONVST_ccd2      : out std_logic;
    SHDN_ck          : out std_logic;
    SHDN_ccd1        : out std_logic;
    SHDN_ccd2        : out std_logic;
    write_en         : out std_logic;
    data_to_adc_out  : out std_logic_vector(3 downto 0);
    cnv_results_ck   : out array816;
    cnv_results_ccd1 : out array816;
    cnv_results_ccd2 : out array816
    );

end max_11046_multiple_3_top;

architecture behavioural of max_11046_multiple_3_top is

  component max_11046_multi_ctrl_fsm is
    port (
      clk            : in  std_logic;
      reset          : in  std_logic;
      start_read     : in  std_logic;
      start_write    : in  std_logic;
      EOC            : in  std_logic;
      write_device   : in  std_logic_vector(1 downto 0);
      link_busy      : out std_logic;
      CS             : out std_logic;
      RD             : out std_logic;
      WR             : out std_logic;
      CONVST         : out std_logic;
      SHDN           : out std_logic;
      write_en       : out std_logic;
      mux_sel        : out std_logic_vector(1 downto 0);
      out_reg_en_bus : out std_logic_vector(7 downto 0));
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

  component demux_1_4_clk_pres
    port (
      reset    : in  std_logic;
      clk      : in  std_logic;
      data_in  : in  std_logic;
      selector : in  std_logic_vector(1 downto 0);
      data_out : out std_logic_vector(3 downto 0));
  end component;

  component mux_4_1_clk
    port (
      reset    : in  std_logic;
      clk      : in  std_logic;
      selector : in  std_logic_vector(1 downto 0);
      in_0     : in  std_logic;
      in_1     : in  std_logic;
      in_2     : in  std_logic;
      in_3     : in  std_logic;
      output   : out std_logic);
  end component;

  component ff_ce is
    port (
      reset    : in  std_logic;         -- syncronus reset
      clk      : in  std_logic;         -- clock
      data_in  : in  std_logic;         -- data in
      ce       : in  std_logic;         -- clock enable
      data_out : out std_logic);        -- data out
  end component;

  signal EOC_int    : std_logic;
  signal CS_int     : std_logic;
  signal RD_int     : std_logic;
  signal WR_int     : std_logic;
  signal CONVST_int : std_logic;
  signal SHDN_int   : std_logic;

--  signal write_device   : std_logic_vector(1 downto 0);  
  signal data_to_adc_out_int : std_logic_vector(5 downto 0);
  signal mux_sel             : std_logic_vector(1 downto 0);
  signal cs_out_bus          : std_logic_vector(3 downto 0);
  signal convst_out_bus      : std_logic_vector(3 downto 0);
  signal out_reg_en_bus      : std_logic_vector(7 downto 0);
  signal out_reg_en_bus_ck   : std_logic_vector(7 downto 0);
  signal out_reg_en_bus_ccd1 : std_logic_vector(7 downto 0);
  signal out_reg_en_bus_ccd2 : std_logic_vector(7 downto 0);

begin  -- behavioural


  max_11046_multi_ctrl_fsm_1 : max_11046_multi_ctrl_fsm
    port map (
      clk            => clk,
      reset          => reset,
      start_read     => start_read,
      start_write    => start_write,
      EOC            => EOC_int,
      write_device   => data_to_adc_out_int(5 downto 4),
      link_busy      => link_busy,
      CS             => CS_int,
      RD             => RD_int,
      WR             => WR_int,
      CONVST         => CONVST_int,
      SHDN           => SHDN_int,
      write_en       => write_en,
      mux_sel        => mux_sel,
      out_reg_en_bus => out_reg_en_bus);

  data_to_adc_reg : generic_reg_ce_init
    generic map(width => 5)
    port map (
      reset    => reset,
      clk      => clk,
      ce       => start_write,
      init     => '0',
      data_in  => data_to_adc,
      data_out => data_to_adc_out_int
      );

  spi_out_reg_ck_generate :
  for i in 0 to 7 generate
    out_ck_reg : generic_reg_ce_init
      generic map(width => 15)
      port map (
        reset    => reset,
        clk      => clk,
        ce       => out_reg_en_bus_ck(i),
        init     => '0',
        data_in  => data_from_adc,
        data_out => cnv_results_ck(i)
        );
  end generate;

  en_bus_ck_generate :
  for i in 0 to 7 generate
    out_reg_en_bus_ck(i) <= out_reg_en_bus(i) and (not mux_sel(0)) and (not mux_sel(1));
  end generate;


  spi_out_reg_ccd1_generate :
  for i in 0 to 7 generate
    out_ccd1_reg : generic_reg_ce_init
      generic map(width => 15)
      port map (
        reset    => reset,
        clk      => clk,
        ce       => out_reg_en_bus_ccd1(i),
        init     => '0',
        data_in  => data_from_adc,
        data_out => cnv_results_ccd1(i)
        );
  end generate;

  en_bus_ccd1_generate :
  for i in 0 to 7 generate
    out_reg_en_bus_ccd1(i) <= out_reg_en_bus(i) and (mux_sel(0)) and (not mux_sel(1));
  end generate;

  spi_out_reg_ccd2_generate :
  for i in 0 to 7 generate
    out_ccd2_reg : generic_reg_ce_init
      generic map(width => 15)
      port map (
        reset    => reset,
        clk      => clk,
        ce       => out_reg_en_bus_ccd2(i),
        init     => '0',
        data_in  => data_from_adc,
        data_out => cnv_results_ccd2(I)
        );
  end generate;

  en_bus_ccd2_generate :
  for i in 0 to 7 generate
    out_reg_en_bus_ccd2(i) <= out_reg_en_bus(i) and (not mux_sel(0)) and (mux_sel(1));
  end generate;

  ff_ce_WR : ff_ce
    port map (
      reset    => reset,
      clk      => clk,
      data_in  => WR_int,
      ce       => '1',
      data_out => WR);

  ff_ce_RD : ff_ce
    port map (
      reset    => reset,
      clk      => clk,
      data_in  => RD_int,
      ce       => '1',
      data_out => RD);

  demux_1_4_clk_CS : demux_1_4_clk_pres
    port map (
      reset    => reset,
      clk      => clk,
      data_in  => CS_int,
      selector => mux_sel,
      data_out => cs_out_bus);

  demux_1_4_clk_CONVST : demux_1_4_clk_pres
    port map (
      reset    => reset,
      clk      => clk,
      data_in  => CONVST_int,
      selector => mux_sel,
      data_out => convst_out_bus);

  mux_4_1_clk_EOC : mux_4_1_clk
    port map (
      reset    => reset,
      clk      => clk,
      selector => mux_sel,
      in_0     => EOC_ck,
      in_1     => EOC_ccd1,
      in_2     => EOC_ccd2,
      in_3     => '0',
      output   => EOC_int);

  CS_ck   <= cs_out_bus(0);
  CS_ccd1 <= cs_out_bus(1);
  CS_ccd2 <= cs_out_bus(2);

  CONVST_ck   <= convst_out_bus(0);
  CONVST_ccd1 <= convst_out_bus(1);
  CONVST_ccd2 <= convst_out_bus(2);

  data_to_adc_out <= data_to_adc_out_int(3 downto 0);

  -- shoutdown seams not working. After shutdown the ADC gives wrong values. 
  SHDN_ck   <= '0';
  SHDN_ccd1 <= '0';
  SHDN_ccd2 <= '0';
  

end behavioural;
