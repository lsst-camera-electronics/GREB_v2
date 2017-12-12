----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:09:09 18/02/2016 
-- Design Name: 
-- Module Name:    max_11046ctrl_fsm - Behavioral 
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

entity max_11046_ctrl_fsm is

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
    out_reg_en_bus : out std_logic_vector(7 downto 0)
    );

end max_11046_ctrl_fsm;

architecture Behavioural of max_11046_ctrl_fsm is

  type state_type is (wait_start, wait_chip_up_read, wait_conv, wait_EOC_0, wait_EOC_1,
                      wait_ch1, read_ch1, wait_ch2, read_ch2,
                      wait_ch3, read_ch3, wait_ch4, read_ch4,
                      wait_ch5, read_ch5, wait_ch6, read_ch6,
                      wait_ch7, read_ch7, wait_ch8,
                      wait_chip_up_write, write_data
                      );

  signal pres_state, next_state : state_type;
  signal next_link_busy         : std_logic;
  signal next_CS                : std_logic;
  signal next_RD                : std_logic;
  signal next_WR                : std_logic;
  signal next_CONVST            : std_logic;
  signal next_SHDN              : std_logic;
  signal next_write_en          : std_logic;
  signal next_out_reg_en_bus    : std_logic_vector(7 downto 0);

  signal next_cnt : integer range 0 to 50;
  signal cnt      : integer range 0 to 50;

  signal next_cnt_1 : integer range 0 to 2501;
  signal cnt_1      : integer range 0 to 2501;

  constant shdn_recovery_time : integer := 10;
  constant integration_time   : integer := 2500;
  constant wait_data_time     : integer := 10;
  constant read_data_time     : integer := 10;
  

begin  -- Behavioural



  process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        pres_state     <= wait_start;
        link_busy      <= '0';
        CS             <= '1';
        RD             <= '1';
        WR             <= '1';
        CONVST         <= '1';
        SHDN           <= '1';
        write_en       <= '1';
        out_reg_en_bus <= (others => '0');
        cnt            <= 0;
        cnt_1          <= 0;
      else
        pres_state     <= next_state;
        link_busy      <= next_link_busy;
        CS             <= next_CS;
        RD             <= next_RD;
        WR             <= next_WR;
        CONVST         <= next_CONVST;
        SHDN           <= next_SHDN;
        write_en       <= next_write_en;
        out_reg_en_bus <= next_out_reg_en_bus;
        cnt            <= next_cnt;
        cnt_1          <= next_cnt_1;
      end if;
    end if;
  end process;




  process (pres_state, start_read, start_write, EOC, cnt, cnt_1)
  begin
    -------------------------------------------------------------------------
    -- output defoult values
    -------------------------------------------------------------------------
    next_link_busy      <= '1';
    next_CS             <= '1';
    next_RD             <= '1';
    next_WR             <= '1';
    next_CONVST         <= '1';
    next_SHDN           <= '0';
    next_write_en       <= '1';
    next_out_reg_en_bus <= (others => '0');
    next_cnt            <= cnt;
    next_cnt_1          <= cnt_1;

    case pres_state is
      when wait_start =>
        if start_read = '1' and start_write = '0' then
          next_state <= wait_chip_up_read;
          next_cnt_1 <= cnt_1 + 1;
        elsif start_read = '0' and start_write = '1' then
          next_state    <= wait_chip_up_write;
          next_write_en <= '0';
          next_cnt_1    <= cnt_1 + 1;
        else
          next_state     <= wait_start;
          next_cnt       <= 0;
          next_cnt_1     <= 0;
          next_SHDN      <= '1';
          next_link_busy <= '0';
        end if;

      when wait_chip_up_read =>
        if cnt_1 = shdn_recovery_time then
          next_state  <= wait_conv;
          next_CONVST <= '0';
          next_cnt_1  <= 0;
        else
          next_state <= wait_chip_up_read;
          next_cnt_1 <= cnt_1 + 1;
        end if;

      when wait_conv =>
        if cnt_1 = integration_time then
          next_state <= wait_EOC_1;
          next_cnt_1 <= 0;
        else
          next_state  <= wait_conv;
          next_cnt_1  <= cnt_1 + 1;
          next_CONVST <= '0';
        end if;

      when wait_EOC_1 =>
        if EOC = '1' then
          next_state <= wait_EOC_0;
        else
          next_state <= wait_EOC_1;
        end if;

      when wait_EOC_0 =>
        if EOC = '0' then
          next_state <= wait_ch1;
          next_CS    <= '0';
          next_RD    <= '0';
          next_cnt_1 <= cnt_1 + 1;
        else
          next_state <= wait_EOC_0;
        end if;




-- VECCHIO

        --when wait_ch1 =>
        --  if cnt_1 = 3 then
        --    next_state          <= read_ch1;
        --    next_CS             <= '0';
        --    next_RD             <= '1';
        --    next_cnt_1          <= 0;
        --    next_out_reg_en_bus <= "00000001";
        --  else
        --    next_state <= wait_ch1;
        --    next_CS    <= '0';
        --    next_RD    <= '0';
        --    next_cnt_1 <= cnt_1 + 1;
        --  end if;

        --when read_ch1 =>
        --  next_state <= wait_ch2;
        --  next_CS    <= '0';
        --  next_RD    <= '0';
        --  next_cnt_1 <= cnt_1 + 1;

      --when wait_ch2 =>
      --  if cnt_1 = 3 then
      --    next_state          <= read_ch2;
      --    next_CS             <= '0';
      --    next_RD             <= '1';
      --    next_cnt_1          <= 0;
      --    next_out_reg_en_bus <= "00000010";
      --  else
      --    next_state <= wait_ch2;
      --    next_CS    <= '0';
      --    next_RD    <= '0';
      --    next_cnt_1 <= cnt_1 + 1;
      --  end if;

      --when read_ch2 =>
      --  next_state <= wait_ch3;
      --  next_CS    <= '0';
      --  next_RD    <= '0';
      --  next_cnt_1 <= cnt_1 + 1;

      --when wait_ch3 =>
      --  if cnt_1 = 3 then
      --    next_state          <= read_ch3;
      --    next_CS             <= '0';
      --    next_RD             <= '1';
      --    next_cnt_1          <= 0;
      --    next_out_reg_en_bus <= "00000100";
      --  else
      --    next_state <= wait_ch3;
      --    next_CS    <= '0';
      --    next_RD    <= '0';
      --    next_cnt_1 <= cnt_1 + 1;
      --  end if;

      --when read_ch3 =>
      --  next_state <= wait_ch4;
      --  next_CS    <= '0';
      --  next_RD    <= '0';
      --  next_cnt_1 <= cnt_1 + 1;

      --when wait_ch4 =>
      --  if cnt_1 = 3 then
      --    next_state          <= read_ch4;
      --    next_CS             <= '0';
      --    next_RD             <= '1';
      --    next_cnt_1          <= 0;
      --    next_out_reg_en_bus <= "00001000";
      --  else
      --    next_state <= wait_ch4;
      --    next_CS    <= '0';
      --    next_RD    <= '0';
      --    next_cnt_1 <= cnt_1 + 1;
      --  end if;

      --when read_ch4 =>
      --  next_state <= wait_ch5;
      --  next_CS    <= '0';
      --  next_RD    <= '0';
      --  next_cnt_1 <= cnt_1 + 1;

      --when wait_ch5 =>
      --  if cnt_1 = 3 then
      --    next_state          <= read_ch5;
      --    next_CS             <= '0';
      --    next_RD             <= '1';
      --    next_cnt_1          <= 0;
      --    next_out_reg_en_bus <= "00010000";
      --  else
      --    next_state <= wait_ch5;
      --    next_CS    <= '0';
      --    next_RD    <= '0';
      --    next_cnt_1 <= cnt_1 + 1;
      --  end if;

      --when read_ch5 =>
      --  next_state <= wait_ch6;
      --  next_CS    <= '0';
      --  next_RD    <= '0';
      --  next_cnt_1 <= cnt_1 + 1;

      --when wait_ch6 =>
      --  if cnt_1 = 3 then
      --    next_state          <= read_ch6;
      --    next_CS             <= '0';
      --    next_RD             <= '1';
      --    next_cnt_1          <= 0;
      --    next_out_reg_en_bus <= "00100000";
      --  else
      --    next_state <= wait_ch6;
      --    next_CS    <= '0';
      --    next_RD    <= '0';
      --    next_cnt_1 <= cnt_1 + 1;
      --  end if;

      --when read_ch6 =>
      --  next_state <= wait_ch7;
      --  next_CS    <= '0';
      --  next_RD    <= '0';
      --  next_cnt_1 <= cnt_1 + 1;

      --when wait_ch7 =>
      --  if cnt_1 = 3 then
      --    next_state          <= read_ch7;
      --    next_CS             <= '0';
      --    next_RD             <= '1';
      --    next_cnt_1          <= 0;
      --    next_out_reg_en_bus <= "01000000";
      --  else
      --    next_state <= wait_ch7;
      --    next_CS    <= '0';
      --    next_RD    <= '0';
      --    next_cnt_1 <= cnt_1 + 1;
      --  end if;

      --when read_ch7 =>
      --  next_state <= wait_ch8;
      --  next_CS    <= '0';
      --  next_RD    <= '0';
      --  next_cnt_1 <= cnt_1 + 1;

      when wait_ch8 =>
        if cnt_1 = wait_data_time then
          next_state          <= wait_start;
          next_CS             <= '1';
          next_RD             <= '1';
          next_SHDN           <= '1';
          next_cnt_1          <= 0;
         -- next_out_reg_en_bus <= "10000000";
        else
          next_state <= wait_ch8;
          next_CS    <= '0';
          next_RD    <= '0';
           next_out_reg_en_bus <= "10000000";
          next_cnt_1 <= cnt_1 + 1;
        end if;




-- NUOVO
        
      when wait_ch1 =>
        if cnt_1 = wait_data_time then
          next_state <= read_ch1;
          next_CS    <= '0';
          next_RD    <= '1';
          next_cnt   <= cnt + 1;
          next_cnt_1 <= 0;
          --    next_out_reg_en_bus <= "00000001";
        else
          next_state          <= wait_ch1;
          next_CS             <= '0';
          next_RD             <= '0';
          next_out_reg_en_bus <= "00000001";
          next_cnt_1          <= cnt_1 + 1;
        end if;

      when read_ch1 =>
        if cnt = read_data_time then
          next_state <= wait_ch2;
          next_CS    <= '0';
          next_RD    <= '0';
          next_cnt   <= 0;
          next_cnt_1 <= cnt_1 + 1;
        else
          next_state <= read_ch1;
          next_CS    <= '0';
          next_RD    <= '1';
          next_cnt   <= cnt + 1;
        end if;

      when wait_ch2 =>
        if cnt_1 = wait_data_time then
          next_state <= read_ch2;
          next_CS    <= '0';
          next_RD    <= '1';
          next_cnt   <= cnt + 1;
          next_cnt_1 <= 0;
          --  next_out_reg_en_bus <= "00000010";
        else
          next_state          <= wait_ch2;
          next_CS             <= '0';
          next_RD             <= '0';
          next_out_reg_en_bus <= "00000010";
          next_cnt_1          <= cnt_1 + 1;
        end if;

      when read_ch2 =>
        if cnt = read_data_time then
          next_state <= wait_ch3;
          next_CS    <= '0';
          next_RD    <= '0';
          next_cnt   <= 0;
          next_cnt_1 <= cnt_1 + 1;
        else
          next_state <= read_ch2;
          next_CS    <= '0';
          next_RD    <= '1';
          next_cnt   <= cnt + 1;
        end if;

 when wait_ch3 =>
        if cnt_1 = wait_data_time then
          next_state <= read_ch3;
          next_CS    <= '0';
          next_RD    <= '1';
          next_cnt   <= cnt + 1;
          next_cnt_1 <= 0;
          --  next_out_reg_en_bus <= "00000010";
        else
          next_state          <= wait_ch3;
          next_CS             <= '0';
          next_RD             <= '0';
          next_out_reg_en_bus <= "00000100";
          next_cnt_1          <= cnt_1 + 1;
        end if;

      when read_ch3 =>
        if cnt = read_data_time then
          next_state <= wait_ch4;
          next_CS    <= '0';
          next_RD    <= '0';
          next_cnt   <= 0;
          next_cnt_1 <= cnt_1 + 1;
        else
          next_state <= read_ch3;
          next_CS    <= '0';
          next_RD    <= '1';
          next_cnt   <= cnt + 1;
        end if;






         when wait_ch4 =>
        if cnt_1 = wait_data_time then
          next_state <= read_ch4;
          next_CS    <= '0';
          next_RD    <= '1';
          next_cnt   <= cnt + 1;
          next_cnt_1 <= 0;
          --  next_out_reg_en_bus <= "00000010";
        else
          next_state          <= wait_ch4;
          next_CS             <= '0';
          next_RD             <= '0';
          next_out_reg_en_bus <= "00001000";
          next_cnt_1          <= cnt_1 + 1;
        end if;

      when read_ch4 =>
        if cnt = read_data_time then
          next_state <= wait_ch5;
          next_CS    <= '0';
          next_RD    <= '0';
          next_cnt   <= 0;
          next_cnt_1 <= cnt_1 + 1;
        else
          next_state <= read_ch4;
          next_CS    <= '0';
          next_RD    <= '1';
          next_cnt   <= cnt + 1;
        end if;



 when wait_ch5 =>
        if cnt_1 = wait_data_time then
          next_state <= read_ch5;
          next_CS    <= '0';
          next_RD    <= '1';
          next_cnt   <= cnt + 1;
          next_cnt_1 <= 0;
          --  next_out_reg_en_bus <= "00000010";
        else
          next_state          <= wait_ch5;
          next_CS             <= '0';
          next_RD             <= '0';
          next_out_reg_en_bus <= "00010000";
          next_cnt_1          <= cnt_1 + 1;
        end if;

      when read_ch5 =>
        if cnt = read_data_time then
          next_state <= wait_ch6;
          next_CS    <= '0';
          next_RD    <= '0';
          next_cnt   <= 0;
          next_cnt_1 <= cnt_1 + 1;
        else
          next_state <= read_ch5;
          next_CS    <= '0';
          next_RD    <= '1';
          next_cnt   <= cnt + 1;
        end if;


 when wait_ch6 =>
        if cnt_1 = wait_data_time then
          next_state <= read_ch6;
          next_CS    <= '0';
          next_RD    <= '1';
          next_cnt   <= cnt + 1;
          next_cnt_1 <= 0;
          --  next_out_reg_en_bus <= "00000010";
        else
          next_state          <= wait_ch6;
          next_CS             <= '0';
          next_RD             <= '0';
          next_out_reg_en_bus <= "00100000";
          next_cnt_1          <= cnt_1 + 1;
        end if;

      when read_ch6 =>
        if cnt = read_data_time then
          next_state <= wait_ch7;
          next_CS    <= '0';
          next_RD    <= '0';
          next_cnt   <= 0;
          next_cnt_1 <= cnt_1 + 1;
        else
          next_state <= read_ch6;
          next_CS    <= '0';
          next_RD    <= '1';
          next_cnt   <= cnt + 1;
        end if;

        
        



when wait_ch7 =>
        if cnt_1 = wait_data_time then
          next_state <= read_ch7;
          next_CS    <= '0';
          next_RD    <= '1';
          next_cnt   <= cnt + 1;
          next_cnt_1 <= 0;
          --  next_out_reg_en_bus <= "00000010";
        else
          next_state          <= wait_ch7;
          next_CS             <= '0';
          next_RD             <= '0';
          next_out_reg_en_bus <= "01000000";
          next_cnt_1          <= cnt_1 + 1;
        end if;

      when read_ch7 =>
        if cnt = read_data_time then
          next_state <= wait_ch8;
          next_CS    <= '0';
          next_RD    <= '0';
          next_cnt   <= 0;
          next_cnt_1 <= cnt_1 + 1;
        else
          next_state <= read_ch7;
          next_CS    <= '0';
          next_RD    <= '1';
          next_cnt   <= cnt + 1;
        end if;




        

        --when wait_ch3 =>
        --  if cnt_1 = wait_data_time then
        --    next_state <= read_ch3;
        --    next_CS    <= '0';
        --    next_RD    <= '1';
        --    next_cnt_1 <= 0;
        --  else
        --    next_state          <= wait_ch3;
        --    next_CS             <= '0';
        --    next_RD             <= '0';
        --    next_out_reg_en_bus <= "00000100";
        --    next_cnt_1          <= cnt_1 + 1;
        --  end if;

        --when read_ch3 =>
        --  if cnt = read_data_time then
        --    next_state <= wait_ch4;
        --    next_CS    <= '0';
        --    next_RD    <= '0';
        --    next_cnt   <= 0;
        --    next_cnt_1 <= cnt_1 + 1;
        --  else
        --    next_state <= read_ch3;
        --    next_CS    <= '0';
        --    next_RD    <= '1';
        --    next_cnt   <= cnt + 1;
        --  end if;

        --when wait_ch4 =>
        --  if cnt_1 = wait_data_time then
        --    next_state <= read_ch4;
        --    next_CS    <= '0';
        --    next_RD    <= '1';
        --    next_cnt_1 <= 0;
        --  else
        --    next_state          <= wait_ch4;
        --    next_CS             <= '0';
        --    next_RD             <= '0';
        --    next_out_reg_en_bus <= "00001000";
        --    next_cnt_1          <= cnt_1 + 1;
        --  end if;

        --when read_ch4 =>
        --  if cnt = read_data_time then
        --    next_state <= wait_ch5;
        --    next_CS    <= '0';
        --    next_RD    <= '0';
        --    next_cnt   <= 0;
        --    next_cnt_1 <= cnt_1 + 1;
        --  else
        --    next_state <= read_ch4;
        --    next_CS    <= '0';
        --    next_RD    <= '1';
        --    next_cnt   <= cnt + 1;
        --  end if;

        --when wait_ch5 =>
        --  if cnt_1 = wait_data_time then
        --    next_state <= read_ch5;
        --    next_CS    <= '0';
        --    next_RD    <= '1';
        --    next_cnt_1 <= 0;
        --  else
        --    next_state          <= wait_ch5;
        --    next_CS             <= '0';
        --    next_RD             <= '0';
        --    next_out_reg_en_bus <= "00010000";
        --    next_cnt_1          <= cnt_1 + 1;
        --  end if;

        --when read_ch5 =>
        --  if cnt = read_data_time then
        --    next_state <= wait_ch6;
        --    next_CS    <= '0';
        --    next_RD    <= '0';
        --    next_cnt   <= 0;
        --    next_cnt_1 <= cnt_1 + 1;
        --  else
        --    next_state <= read_ch5;
        --    next_CS    <= '0';
        --    next_RD    <= '1';
        --    next_cnt   <= cnt + 1;
        --  end if;

        --when wait_ch6 =>
        --  if cnt_1 = wait_data_time then
        --    next_state <= read_ch6;
        --    next_CS    <= '0';
        --    next_RD    <= '1';
        --    next_cnt_1 <= 0;
        --  else
        --    next_state          <= wait_ch6;
        --    next_CS             <= '0';
        --    next_RD             <= '0';
        --    next_out_reg_en_bus <= "00100000";
        --    next_cnt_1          <= cnt_1 + 1;
        --  end if;

        --when read_ch6 =>
        --  if cnt = read_data_time then
        --    next_state <= wait_ch7;
        --    next_CS    <= '0';
        --    next_RD    <= '0';
        --    next_cnt   <= 0;
        --    next_cnt_1 <= cnt_1 + 1;
        --  else
        --    next_state <= read_ch6;
        --    next_CS    <= '0';
        --    next_RD    <= '1';
        --    next_cnt   <= cnt + 1;
        --  end if;

        --when wait_ch7 =>
        --  if cnt_1 = wait_data_time then
        --    next_state <= read_ch7;
        --    next_CS    <= '0';
        --    next_RD    <= '1';
        --    next_cnt_1 <= 0;
        --  else
        --    next_state          <= wait_ch7;
        --    next_CS             <= '0';
        --    next_RD             <= '0';
        --    next_out_reg_en_bus <= "01000000";
        --    next_cnt_1          <= cnt_1 + 1;
        --  end if;

        --when read_ch7 =>
        --  if cnt = read_data_time then
        --    next_state <= wait_ch8;
        --    next_CS    <= '0';
        --    next_RD    <= '0';
        --    next_cnt   <= 0;
        --    next_cnt_1 <= cnt_1 + 1;
        --  else
        --    next_state <= read_ch7;
        --    next_CS    <= '0';
        --    next_RD    <= '1';
        --    next_cnt   <= cnt + 1;
        --  end if;

        --when wait_ch8 =>
        --  if cnt_1 = wait_data_time then
        --    next_state <= wait_start;
        --    next_CS    <= '1';
        --    next_RD    <= '1';
        --    next_SHDN  <= '1';
        --    next_cnt_1 <= 0;
        --  else
        --    next_state          <= wait_ch8;
        --    next_CS             <= '0';
        --    next_RD             <= '0';
        --    next_out_reg_en_bus <= "10000000";
        --    next_cnt_1          <= cnt_1 + 1;
        --  end if;

      when wait_chip_up_write =>
        if cnt_1 = 100 then
          next_state    <= write_data;
          next_write_en <= '0';
          next_CS       <= '0';
          next_WR       <= '0';
          next_cnt_1    <= 0;
        else
          next_state    <= wait_chip_up_write;
          next_write_en <= '0';
          next_cnt_1    <= cnt_1 + 1;
        end if;

      when write_data =>
        if cnt_1 = 3 then
          next_state    <= wait_start;
          next_CS       <= '1';
          next_WR       <= '1';
          next_write_en <= '0';
          next_cnt_1    <= 0;
        else
          next_state    <= write_data;
          next_write_en <= '0';
          next_cnt_1    <= cnt_1 + 1;
        end if;

    end case;




  end process;
end Behavioural;
