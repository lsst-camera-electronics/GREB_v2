----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:09:09 18/02/2016 
-- Design Name: 
-- Module Name:    max_11046ctrl_top - Behavioral 
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


entity max_11046_top is
  
  port (
    clk             : in  std_logic;
    reset           : in  std_logic;
    start_write     : in  std_logic;
    start_read      : in  std_logic;
    EOC             : in  std_logic;
    data_to_adc     : in  std_logic_vector(3 downto 0);
    data_from_adc   : in  std_logic_vector(15 downto 0);
    link_busy       : out std_logic;
    CS              : out std_logic;
    RD              : out std_logic;
    WR              : out std_logic;
    CONVST          : out std_logic;
    SHDN            : out std_logic;
    write_en        : out std_logic;
    data_to_adc_out : out std_logic_vector(3 downto 0);
    cnv_results     : out array816
    );

end max_11046_top;

architecture behavioural of max_11046_top is

  component max_11046_ctrl_fsm is
    port (
      clk            : in  std_logic;
      reset          : in  std_logic;
      start_read     : in  std_logic;
      start_write    : in  std_logic;
      EOC            : in  std_logic;
      link_busy      : out std_logic;
      CS             : out std_logic;
      RD             : out std_logic;
      WR             : out std_logic;
      CONVST         : out std_logic;
      SHDN           : out std_logic;
      write_en       : out std_logic;
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



  signal data_to_adc_int : std_logic_vector(3 downto 0);

  signal out_reg_en_bus : std_logic_vector(7 downto 0);

begin  -- behavioural




  max_11046_ctrl_fsm_1 : max_11046_ctrl_fsm
    port map (
      clk            => clk,
      reset          => reset,
      start_read     => start_read,
      start_write    => start_write,
      EOC            => EOC,
      link_busy      => link_busy,
      CS             => CS,
      RD             => RD,
      WR             => WR,
      CONVST         => CONVST,
      SHDN           => SHDN,
      write_en       => write_en,
      out_reg_en_bus => out_reg_en_bus
      );

  data_to_adc_reg : generic_reg_ce_init
    generic map(width => 3)
    port map (
      reset    => reset,
      clk      => clk,
      ce       => start_write,
      init     => '0',
      data_in  => data_to_adc,
      data_out => data_to_adc_out
      );

  spi_out_reg_generate :
  for i in 0 to 7 generate
    out_lsw_reg : generic_reg_ce_init
      generic map(width => 15)
      port map (
        reset    => reset,
        clk      => clk,
        ce       => out_reg_en_bus(i),
        init     => '0',
        data_in  => data_from_adc,
        data_out => cnv_results(i)
        );
  end generate;

end behavioural;

