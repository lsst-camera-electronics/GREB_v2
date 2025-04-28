----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:13:09 07/06/2016 
-- Design Name: 
-- Module Name:    dual_ads1118_controller_fsm - Behavioral 
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

entity dual_ads1118_controller_fsm is

  port (
    clk            : in  std_logic;
    reset          : in  std_logic;
    start_read     : in  std_logic;
    spi_busy       : in  std_logic;
    device_busy    : in  std_logic;
    start_spi      : out std_logic;
    link_busy      : out std_logic;
    data_to_spi    : out std_logic_vector(15 downto 0);
    out_reg_en_bus : out std_logic_vector(3 downto 0)
    );

end dual_ads1118_controller_fsm;

architecture Behavioral of dual_ads1118_controller_fsm is

  type state_type is (wait_start,
                      start_ch0, write_ch0, wait_conv_ch0,
                      start_ch1, write_ch1, wait_conv_ch1,
                      start_ch2, write_ch2, wait_conv_ch2,
                      start_ch3, write_ch3, wait_conv_ch3,
                      start_read_ch3, read_conv_ch3);

  signal pres_state, next_state : state_type;
  signal next_start_spi         : std_logic;
  signal next_link_busy         : std_logic;
  signal next_data_to_spi       : std_logic_vector(15 downto 0);
  signal next_out_reg_en_bus    : std_logic_vector(3 downto 0);

  signal next_cnt : integer range 0 to 1000;
  signal cnt      : integer range 0 to 1000;

-- ADC data control strings

  constant read_ch0 : std_logic_vector(15 downto 0) := x"C"&x"38B";  -- reads channel 0 range +-4.096 T_ASPIC_top
  constant read_ch1 : std_logic_vector(15 downto 0) := x"D"&x"38B";  -- reads channel 1 range +-4.096 T_ASPIC_bot
  constant read_ch2 : std_logic_vector(15 downto 0) := x"E"&x"38B";  -- reads channel 2 range +-4.096 2.5V
  constant read_ch3 : std_logic_vector(15 downto 0) := x"F"&x"38B";  -- reads channel 3 range +-4.096 5V (voltage divider on the board)
  
  --constant read_ch0 : std_logic_vector(15 downto 0) := x"C"&x"303";  -- reads channel 0 range +-4.096 T_ASPIC_top
  --constant read_ch1 : std_logic_vector(15 downto 0) := x"D"&x"303";  -- reads channel 1 range +-4.096 T_ASPIC_bot
  --constant read_ch2 : std_logic_vector(15 downto 0) := x"E"&x"303";  -- reads channel 2 range +-4.096 2.5V
  --constant read_ch3 : std_logic_vector(15 downto 0) := x"F"&x"303";  -- reads channel 3 range +-4.096 5V (voltage divider on the board)
  
  


begin

  process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        pres_state     <= wait_start;
        start_spi      <= '0';
        link_busy      <= '0';
        data_to_spi    <= (others => '0');
        out_reg_en_bus <= (others => '0');
        cnt            <= 0;
      else
        pres_state     <= next_state;
        start_spi      <= next_start_spi;
        link_busy      <= next_link_busy;
        data_to_spi    <= next_data_to_spi;
        out_reg_en_bus <= next_out_reg_en_bus;
        cnt            <= next_cnt;
      end if;
    end if;
  end process;


  process (pres_state, start_read, spi_busy, device_busy, cnt)
  begin

    -------------------- outputs default values  --------------------
    
    next_start_spi      <= '0';
    next_link_busy      <= '1';
    next_data_to_spi    <= (others => '1');
    next_out_reg_en_bus <= (others => '0');
    next_cnt            <= cnt;

    case pres_state is

      when wait_start =>
        if start_read = '1' then
          next_state       <= start_ch0;
          next_start_spi   <= '1';
          next_data_to_spi <= read_ch0;
        else
          next_state     <= wait_start;
          next_link_busy <= '0';
        end if;

      when start_ch0 =>
        if spi_busy = '1' then
          next_state <= write_ch0;
        else
          next_state       <= start_ch0;
          next_start_spi   <= '1';
          next_data_to_spi <= read_ch0;
        end if;
        
      when write_ch0 =>
        if spi_busy = '0' then
          next_state <= wait_conv_ch0;
        else
          next_state <= write_ch0;
        end if;

      when wait_conv_ch0 =>
        if device_busy = '0' then
          next_state <= start_ch1;
        else
          next_state <= wait_conv_ch0;
        end if;

        -- when wait_conv_ch0 =>
        --if cnt = 800 then
        --  next_state <= start_ch1;
        --  next_cnt <= 0;
        --else
        --  next_state <= wait_conv_ch0;
        --  next_cnt <= cnt + 1;
        --end if;


      when start_ch1 =>
        if spi_busy = '1' then
          next_state <= write_ch1;
        else
          next_state       <= start_ch1;
          next_start_spi   <= '1';
          next_data_to_spi <= read_ch1;
        end if;
        
      when write_ch1 =>
        if spi_busy = '0' then
          next_state <= wait_conv_ch1;
        else
          next_state          <= write_ch1;
          next_out_reg_en_bus <= "0001";
        end if;

      when wait_conv_ch1 =>
        if device_busy = '0' then
          next_state <= start_ch2;
        else
          next_state <= wait_conv_ch1;
        end if;

        -- when wait_conv_ch1 =>
        --if cnt = 800 then
        --  next_state <= start_ch2;
        --  next_cnt <= 0;
        --else
        --  next_state <= wait_conv_ch1;
        --  next_cnt <= cnt + 1;
        --end if;

      when start_ch2 =>
        if spi_busy = '1' then
          next_state <= write_ch2;
        else
          next_state       <= start_ch2;
          next_start_spi   <= '1';
          next_data_to_spi <= read_ch2;
        end if;
        
      when write_ch2 =>
        if spi_busy = '0' then
          next_state <= wait_conv_ch2;
        else
          next_state          <= write_ch2;
          next_out_reg_en_bus <= "0010";
        end if;

      when wait_conv_ch2 =>
        if device_busy = '0' then
          next_state <= start_ch3;
        else
          next_state <= wait_conv_ch2;
        end if;

        -- when wait_conv_ch2 =>
        --if cnt = 800 then
        --  next_state <= start_ch3;
        --  next_cnt <= 0;
        --else
        --  next_state <= wait_conv_ch2;
        --  next_cnt <= cnt + 1;
        --end if;

      when start_ch3 =>
        if spi_busy = '1' then
          next_state <= write_ch3;
        else
          next_state       <= start_ch3;
          next_start_spi   <= '1';
          next_data_to_spi <= read_ch3;
        end if;
        
      when write_ch3 =>
        if spi_busy = '0' then
          next_state <= wait_conv_ch3;
        else
          next_state          <= write_ch3;
          next_out_reg_en_bus <= "0100";
        end if;

      when wait_conv_ch3 =>
        if device_busy = '0' then
          next_state <= start_read_ch3;
        else
          next_state <= wait_conv_ch3;
        end if;

        --  when wait_conv_ch3 =>
        --if cnt = 800 then
        --  next_state <= start_read_ch3;
        --  next_cnt <= 0;
        --else
        --  next_state <= wait_conv_ch3;
        --  next_cnt <= cnt + 1;
        --end if;

      when start_read_ch3 =>
        if spi_busy = '1' then
          next_state <= read_conv_ch3;
        else
          next_state       <= start_read_ch3;
          next_start_spi   <= '1';
          next_data_to_spi <= read_ch0;
        end if;
        
      when read_conv_ch3 =>
        if spi_busy = '0' then
          next_state <= wait_start;
        else
          next_state          <= read_conv_ch3;
          next_out_reg_en_bus <= "1000";
        end if;
        
    end case;
  end process;

end Behavioral;

