--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:53:14 07/08/2016
-- Design Name:   
-- Module Name:   C:/Xilinx_prj/test_dual_ads1118/TB/TB_dual_ads1118_top.vhd
-- Project Name:  test_dual_ads1118
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: dual_ads1118_top
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

use work.dual_ads1118_top_package.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;

LIBRARY modelsim_lib;
use modelsim_lib.util.all;

 
ENTITY TB_dual_ads1118_top IS
END TB_dual_ads1118_top;
 
ARCHITECTURE behavior OF TB_dual_ads1118_top IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT dual_ads1118_top
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         start_read : IN  std_logic;
         device_select : IN  std_logic;
         miso : IN  std_logic;
         mosi : OUT  std_logic;
         ss_adc_1 : OUT  std_logic;
         ss_adc_2 : OUT  std_logic;
         sclk : OUT  std_logic;
         link_busy : OUT  std_logic;
         data_from_adc : OUT  array432
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '1';
   signal start_read : std_logic := '0';
   signal device_select : std_logic := '0';
   signal miso : std_logic := '0';

 	--Outputs
   signal mosi : std_logic;
   signal ss_adc_1 : std_logic;
   signal ss_adc_2 : std_logic;
   signal sclk : std_logic;
   signal link_busy : std_logic;
   signal data_from_adc : array432;
	
	-- internal signals
	signal top_sig1 : std_logic;
	
	-- output words
	constant adc_0 : std_logic_vector(31 downto 0) := x"facafaca";
	constant adc_1 : std_logic_vector(31 downto 0) := x"dacadaca";
	constant adc_2 : std_logic_vector(31 downto 0) := x"bacabaca";
	constant adc_3 : std_logic_vector(31 downto 0) := x"2aca2aca";

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: dual_ads1118_top PORT MAP (
          clk => clk,
          reset => reset,
          start_read => start_read,
          device_select => device_select,
          miso => miso,
          mosi => mosi,
          ss_adc_1 => ss_adc_1,
          ss_adc_2 => ss_adc_2,
          sclk => sclk,
          link_busy => link_busy,
          data_from_adc => data_from_adc
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

spy_process : process
  begin
    init_signal_spy("/tb_dual_ads1118_top/uut/spi_busy","/top_sig1",1);
    wait;
  end process spy_process;


   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		
		reset <= '0';
		
		
		wait for 305 ns;
		start_read <= '1';
		wait for clk_period;
	   start_read <= '0';
		
		wait until top_sig1 = '1';
		wait until top_sig1 = '0';
	-- simulating conversion time	
		miso <= '1';
		wait for 1 us;
		miso <= '0';
	-- sending data	
		for i in adc_0'range loop
      wait until sclk = '1';
		miso <= adc_0(i);
   end loop; 
	
	-- ch 1
		-- simulating conversion time		
		wait until top_sig1 = '0';
		miso <= '1';
		wait for 1 us;
		miso <= '0';
	-- sending data		
		for i in adc_1'range loop
      wait until sclk = '1';
		miso <= adc_1(i);
   end loop; 

-- ch 2
		-- simulating conversion time		
		wait until top_sig1 = '0';
		miso <= '1';
		wait for 1 us;
		miso <= '0';
	-- sending data		
		for i in adc_2'range loop
      wait until sclk = '1';
		miso <= adc_2(i);
   end loop; 
	
	-- ch 3
		-- simulating conversion time		
		wait until top_sig1 = '0';
		miso <= '1';
		wait for 1 us;
		miso <= '0';
	-- sending data		
		for i in adc_3'range loop
      wait until sclk = '1';
		miso <= adc_3(i);
   end loop; 

      wait;
   end process;

END;
