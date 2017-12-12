----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:08:58 07/01/2016 
-- Design Name: 
-- Module Name:    ltc2945_multi_read_greb_fsm - Behavioral 
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

entity ltc2945_multi_read_greb_fsm is

  port (
    clk             : in std_logic;
    reset           : in std_logic;
    start_procedure : in std_logic;
    end_i2c         : in std_logic;

    busy         : out std_logic;
    start_i2c    : out std_logic;
    device_addr  : out std_logic_vector (6 downto 0);  --address of target slave
    reg_add      : out std_logic_vector (7 downto 0);
    latch_en_bus : out std_logic_vector (9 downto 0)
    );

end ltc2945_multi_read_greb_fsm;

architecture Behavioral of ltc2945_multi_read_greb_fsm is

  type state_type is (wait_start,
                      read_V_sens_1, read_I_sens_1,
                      read_V_sens_2, read_I_sens_2,
                      read_V_sens_3, read_I_sens_3,
                      read_V_sens_4, read_I_sens_4,
                      read_V_sens_5, read_I_sens_5);

  signal pres_state, next_state : state_type;
  signal next_busy              : std_logic;
  signal next_start_i2c         : std_logic;
  signal next_device_addr       : std_logic_vector (6 downto 0);
  signal next_reg_add           : std_logic_vector (7 downto 0);
  signal next_latch_en_bus      : std_logic_vector (9 downto 0);

  constant V_HTR_dev_add   : std_logic_vector (6 downto 0) := x"D"&"001";  -- D2 ??V
  constant V_DREB_dev_add  : std_logic_vector (6 downto 0) := x"D"&"010";  -- D4 3.3V
  constant V_CLK_H_dev_add : std_logic_vector (6 downto 0) := x"D"&"011";  -- D6 ??V
  constant V_OD_dev_add    : std_logic_vector (6 downto 0) := x"D"&"111";  -- DE 40V
  constant V_ANA_dev_add   : std_logic_vector (6 downto 0) := x"D"&"110";  -- DC 5V


  constant V_reg_add : std_logic_vector (7 downto 0) := x"1E";
  constant I_reg_add : std_logic_vector (7 downto 0) := x"14";

begin

  process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        pres_state   <= wait_start;
        busy         <= '0';
        start_i2c    <= '0';
        device_addr  <= (others => '0');
        reg_add      <= (others => '0');
        latch_en_bus <= (others => '0');
      else
        pres_state   <= next_state;
        busy         <= next_busy;
        start_i2c    <= next_start_i2c;
        device_addr  <= next_device_addr;
        reg_add      <= next_reg_add;
        latch_en_bus <= next_latch_en_bus;
      end if;
    end if;
  end process;

  process (start_procedure, end_i2c)

  begin

    -------------------- outputs defoult values --------------------
    next_busy         <= '1';
    next_start_i2c    <= '0';
    next_device_addr  <= (others => '0');
    next_reg_add      <= (others => '0');
    next_latch_en_bus <= (others => '0');

    case pres_state is
      
      when wait_start =>
        if start_procedure = '0' then
          next_state <= wait_start;
          next_busy  <= '0';
        else
          next_state        <= read_V_sens_1;
          next_start_i2c    <= '1';
          next_device_addr  <= V_HTR_dev_add;
          next_reg_add      <= V_reg_add;
          next_latch_en_bus <= "0000000001";
        end if;
        
      when read_V_sens_1 =>
        if end_i2c = '0' then
          next_state        <= read_V_sens_1;
          next_device_addr  <= V_HTR_dev_add;
          next_reg_add      <= V_reg_add;
          next_latch_en_bus <= "0000000001";
        else
          next_state        <= read_I_sens_1;
          next_start_i2c    <= '1';
          next_device_addr  <= V_HTR_dev_add;
          next_reg_add      <= I_reg_add;
          next_latch_en_bus <= "0000000010";
        end if;
        
      when read_I_sens_1 =>
        if end_i2c = '0' then
          next_state        <= read_I_sens_1;
          next_device_addr  <= V_HTR_dev_add;
          next_reg_add      <= I_reg_add;
          next_latch_en_bus <= "0000000010";
        else
          next_state        <= read_V_sens_2;
          next_start_i2c    <= '1';
          next_device_addr  <= V_DREB_dev_add;
          next_reg_add      <= V_reg_add;
          next_latch_en_bus <= "0000000100";
        end if;
        
      when read_V_sens_2 =>
        if end_i2c = '0' then
          next_state        <= read_V_sens_2;
          next_device_addr  <= V_DREB_dev_add;
          next_reg_add      <= V_reg_add;
          next_latch_en_bus <= "0000000100";
        else
          next_state        <= read_I_sens_2;
          next_start_i2c    <= '1';
          next_device_addr  <= V_DREB_dev_add;
          next_reg_add      <= I_reg_add;
          next_latch_en_bus <= "0000001000";
        end if;
        
      when read_I_sens_2 =>
        if end_i2c = '0' then
          next_state        <= read_I_sens_2;
          next_device_addr  <= V_DREB_dev_add;
          next_reg_add      <= I_reg_add;
          next_latch_en_bus <= "0000001000";
        else
          next_state        <= read_V_sens_3;
          next_start_i2c    <= '1';
          next_device_addr  <= V_CLK_H_dev_add;
          next_reg_add      <= V_reg_add;
          next_latch_en_bus <= "0000010000";
        end if;
        
      when read_V_sens_3 =>
        if end_i2c = '0' then
          next_state        <= read_V_sens_3;
          next_device_addr  <= V_CLK_H_dev_add;
          next_reg_add      <= V_reg_add;
          next_latch_en_bus <= "0000010000";
        else
          next_state        <= read_I_sens_3;
          next_start_i2c    <= '1';
          next_device_addr  <= V_CLK_H_dev_add;
          next_reg_add      <= I_reg_add;
          next_latch_en_bus <= "0000100000";
        end if;
        
      when read_I_sens_3 =>
        if end_i2c = '0' then
          next_state        <= read_I_sens_3;
          next_device_addr  <= V_CLK_H_dev_add;
          next_reg_add      <= I_reg_add;
          next_latch_en_bus <= "0000100000";
        else
          next_state        <= read_V_sens_4;
          next_start_i2c    <= '1';
          next_device_addr  <= V_OD_dev_add;
          next_reg_add      <= V_reg_add;
          next_latch_en_bus <= "0001000000";
        end if;
        
      when read_V_sens_4 =>
        if end_i2c = '0' then
          next_state        <= read_V_sens_4;
          next_device_addr  <= V_OD_dev_add;
          next_reg_add      <= V_reg_add;
          next_latch_en_bus <= "0001000000";
        else
          next_state        <= read_I_sens_4;
          next_start_i2c    <= '1';
          next_device_addr  <= V_OD_dev_add;
          next_reg_add      <= I_reg_add;
          next_latch_en_bus <= "0010000000";
        end if;
        
      when read_I_sens_4 =>
        if end_i2c = '0' then
          next_state        <= read_I_sens_4;
          next_device_addr  <= V_OD_dev_add;
          next_reg_add      <= I_reg_add;
          next_latch_en_bus <= "0010000000";
        else
          next_state        <= read_V_sens_5;
          next_start_i2c    <= '1';
          next_device_addr  <= V_ANA_dev_add;
          next_reg_add      <= V_reg_add;
          next_latch_en_bus <= "0100000000";
        end if;
        
      when read_V_sens_5 =>
        if end_i2c = '0' then
          next_state        <= read_V_sens_5;
          next_device_addr  <= V_ANA_dev_add;
          next_reg_add      <= V_reg_add;
          next_latch_en_bus <= "0100000000";
        else
          next_state        <= read_I_sens_5;
          next_start_i2c    <= '1';
          next_device_addr  <= V_ANA_dev_add;
          next_reg_add      <= I_reg_add;
          next_latch_en_bus <= "1000000000";
        end if;
        
      when read_I_sens_5 =>
        if end_i2c = '0' then
          next_state        <= read_I_sens_5;
          next_device_addr  <= V_ANA_dev_add;
          next_reg_add      <= I_reg_add;
          next_latch_en_bus <= "1000000000";
        else
          next_state <= wait_start;
          next_busy  <= '1';
        end if;
        
    end case;
  end process;

end Behavioral;

