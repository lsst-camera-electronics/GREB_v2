----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:03:36 04/25/2013 
-- Design Name: 
-- Module Name:    ADC_data_handler_fsm_v3 - Behavioral 
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

use work.ADC_data_handler_package.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ADC_data_handler_fsm_v4 is

  port (
    reset        : in  std_logic;
    clk          : in  std_logic;
    trigger      : in  std_logic;
--       cnt_end                  : in  std_logic;
    start_of_img : in  std_logic;  -- this signal is generated by the user (using the sequencer) and has to arrive before the first trigger
    end_of_img   : in  std_logic;  -- this signal is generated by the user (using the sequencer) and has to arrive after the last  ADC trasfer
    end_sequence : in  std_logic;  -- this signal is the end of sequence generated by the sequencer and is used as a timeot to generate EOF.
    ccd_sel      : in  std_logic_vector(2 downto 0);
    data_ccd_1   : in  array1618;
    data_ccd_2   : in  array1618;
    data_ccd_3   : in  array1618;
    cnt_en       : out std_logic;
    init_cnt     : out std_logic;
    SOT          : out std_logic;
    EOT          : out std_logic;
    write_enable : out std_logic;
    handler_busy : out std_logic;
    data_out     : out std_logic_vector(17 downto 0)
    );

end ADC_data_handler_fsm_v4;

architecture Behavioral of ADC_data_handler_fsm_v4 is
  type state_type is (wait_SOF, wait_trigger,
                       out_ccd_1_1, out_ccd_1_2, out_ccd_1_3, out_ccd_1_4, out_ccd_1_5, out_ccd_1_6,
                       out_ccd_1_7, out_ccd_1_8, out_ccd_1_9, out_ccd_1_10, out_ccd_1_11, out_ccd_1_12,
                       out_ccd_1_13, out_ccd_1_14, out_ccd_1_15,

                       out_ccd_2_0, out_ccd_2_1, out_ccd_2_2, out_ccd_2_3, out_ccd_2_4, out_ccd_2_5, out_ccd_2_6,
                       out_ccd_2_7, out_ccd_2_8, out_ccd_2_9, out_ccd_2_10, out_ccd_2_11, out_ccd_2_12,
                       out_ccd_2_13, out_ccd_2_14, out_ccd_2_15,

                       out_ccd_3_0, out_ccd_3_1, out_ccd_3_2, out_ccd_3_3, out_ccd_3_4, out_ccd_3_5, out_ccd_3_6,
                       out_ccd_3_7, out_ccd_3_8, out_ccd_3_9, out_ccd_3_10, out_ccd_3_11, out_ccd_3_12,
                       out_ccd_3_13, out_ccd_3_14, out_ccd_3_15,

                       wait_end_trigger);

  signal pres_state, next_state : state_type;
  signal next_cnt_en            : std_logic;
  signal next_init_cnt          : std_logic;
  signal next_SOT               : std_logic;
  signal next_EOT               : std_logic;
  signal next_write_enable      : std_logic;
  signal next_handler_busy      : std_logic;
  signal next_data_out          : std_logic_vector(17 downto 0);



begin


  process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        pres_state   <= wait_SOF;
        cnt_en       <= '0';
        init_cnt     <= '0';
        SOT          <= '0';
        EOT          <= '0';
        write_enable <= '0';
        handler_busy <= '0';
        data_out     <= (others => '0');
      else
        pres_state   <= next_state;
        cnt_en       <= next_cnt_en;
        init_cnt     <= next_init_cnt;
        SOT          <= next_SOT;
        EOT          <= next_EOT;
        write_enable <= next_write_enable;
        handler_busy <= next_handler_busy;
        data_out     <= next_data_out;

      end if;
    end if;
  end process;


  process (pres_state, trigger, start_of_img, end_of_img, end_sequence, data_ccd_1, data_ccd_2, data_ccd_3, ccd_sel)
  begin

    -------------------- outputs defoult values  --------------------

    next_cnt_en       <= '0';
    next_init_cnt     <= '0';
    next_SOT          <= '0';
    next_EOT          <= '0';
    next_write_enable <= '0';
    next_handler_busy <= '1';
    next_data_out     <= (others => '0');

    case pres_state is

-------------------------------------------------------- CMD INTERPTETER  --------------------------------------------------------

      when wait_SOF =>

        if start_of_img = '1' then
          next_state        <= wait_trigger;
          next_SOT          <= '1';
          next_write_enable <= '1';
        else
          next_state        <= wait_SOF;
          next_handler_busy <= '0';
        end if;
        
        
      when wait_trigger =>
        if trigger = '0' and end_of_img = '0' and end_sequence = '0' then
          next_state <= wait_trigger;
        elsif trigger = '1' and end_of_img = '0' and end_sequence = '0' then
          if ccd_sel(0) = '1' then
            next_state        <= out_ccd_1_1;
            next_write_enable <= '1';
            next_cnt_en       <= '1';
            next_data_out     <= data_ccd_1(0);
          elsif ccd_sel(0) = '0' and ccd_sel(1) = '1' then
            next_state        <= out_ccd_2_1;
            next_write_enable <= '1';
            next_cnt_en       <= '1';
            next_data_out     <= data_ccd_2(0);
          elsif ccd_sel(0) = '0' and ccd_sel(1) = '0' and ccd_sel(2) = '1' then
            next_state        <= out_ccd_3_1;
            next_write_enable <= '1';
            next_cnt_en       <= '1';
            next_data_out     <= data_ccd_3(0);
          else  -- the machine should never reach this condition
            next_state <= wait_SOF;
          end if;
        elsif trigger = '0' and (end_of_img = '1' or end_sequence = '1') then
          next_state        <= wait_SOF;
          next_write_enable <= '1';
          next_EOT          <= '1';
          next_init_cnt     <= '1';
        else    -- the machine should never reach this condition
          next_state <= wait_SOF;
        end if;

      when out_ccd_1_1 =>
        next_state        <= out_ccd_1_2;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_1(1);

      when out_ccd_1_2 =>
        next_state        <= out_ccd_1_3;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_1(2);

      when out_ccd_1_3 =>
        next_state        <= out_ccd_1_4;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_1(3);

      when out_ccd_1_4 =>
        next_state        <= out_ccd_1_5;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_1(4);

      when out_ccd_1_5 =>
        next_state        <= out_ccd_1_6;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_1(5);

      when out_ccd_1_6 =>
        next_state        <= out_ccd_1_7;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_1(6);
        
      when out_ccd_1_7 =>
        next_state        <= out_ccd_1_8;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_1(7);

      when out_ccd_1_8 =>
        next_state        <= out_ccd_1_9;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_1(8);

      when out_ccd_1_9 =>
        next_state        <= out_ccd_1_10;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_1(9);

      when out_ccd_1_10 =>
        next_state        <= out_ccd_1_11;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_1(10);

      when out_ccd_1_11 =>
        next_state        <= out_ccd_1_12;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_1(11);

      when out_ccd_1_12 =>
        next_state        <= out_ccd_1_13;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_1(12);
        
      when out_ccd_1_13 =>
        next_state        <= out_ccd_1_14;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_1(13);
        
      when out_ccd_1_14 =>
        next_state        <= out_ccd_1_15;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_1(14);

      when out_ccd_1_15 =>
        if ccd_sel(1) = '1' then
          next_state        <= out_ccd_2_0;
          next_write_enable <= '1';
          next_data_out     <= data_ccd_1(15);
        elsif ccd_sel(1) = '0' and ccd_sel(2) = '1' then
          next_state        <= out_ccd_3_0;
          next_write_enable <= '1';
          next_data_out     <= data_ccd_1(15);
        else
          next_state        <= wait_end_trigger;
          next_write_enable <= '1';
          next_data_out     <= data_ccd_1(15);
        end if;

      when out_ccd_2_0 =>
        next_state        <= out_ccd_2_1;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_2(0);
        
      when out_ccd_2_1 =>
        next_state        <= out_ccd_2_2;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_2(1);

      when out_ccd_2_2 =>
        next_state        <= out_ccd_2_3;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_2(2);

      when out_ccd_2_3 =>
        next_state        <= out_ccd_2_4;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_2(3);

      when out_ccd_2_4 =>
        next_state        <= out_ccd_2_5;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_2(4);

      when out_ccd_2_5 =>
        next_state        <= out_ccd_2_6;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_2(5);

      when out_ccd_2_6 =>
        next_state        <= out_ccd_2_7;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_2(6);
        
      when out_ccd_2_7 =>
        next_state        <= out_ccd_2_8;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_2(7);

      when out_ccd_2_8 =>
        next_state        <= out_ccd_2_9;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_2(8);

      when out_ccd_2_9 =>
        next_state        <= out_ccd_2_10;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_2(9);

      when out_ccd_2_10 =>
        next_state        <= out_ccd_2_11;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_2(10);

      when out_ccd_2_11 =>
        next_state        <= out_ccd_2_12;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_2(11);

      when out_ccd_2_12 =>
        next_state        <= out_ccd_2_13;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_2(12);
        
      when out_ccd_2_13 =>
        next_state        <= out_ccd_2_14;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_2(13);
        
      when out_ccd_2_14 =>
        next_state        <= out_ccd_2_15;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_2(14);

      when out_ccd_2_15 =>
        if ccd_sel(2) = '1' then
          next_state        <= out_ccd_3_0;
          next_write_enable <= '1';
          next_data_out     <= data_ccd_2(15);
        else
          next_state        <= wait_end_trigger;
          next_write_enable <= '1';
          next_data_out     <= data_ccd_2(15);
        end if;

      when out_ccd_3_0 =>
        next_state        <= out_ccd_3_1;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_3(0);
        
      when out_ccd_3_1 =>
        next_state        <= out_ccd_3_2;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_3(1);

      when out_ccd_3_2 =>
        next_state        <= out_ccd_3_3;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_3(2);

      when out_ccd_3_3 =>
        next_state        <= out_ccd_3_4;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_3(3);

      when out_ccd_3_4 =>
        next_state        <= out_ccd_3_5;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_3(4);

      when out_ccd_3_5 =>
        next_state        <= out_ccd_3_6;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_3(5);

      when out_ccd_3_6 =>
        next_state        <= out_ccd_3_7;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_3(6);
        
      when out_ccd_3_7 =>
        next_state        <= out_ccd_3_8;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_3(7);

      when out_ccd_3_8 =>
        next_state        <= out_ccd_3_9;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_3(8);

      when out_ccd_3_9 =>
        next_state        <= out_ccd_3_10;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_3(9);

      when out_ccd_3_10 =>
        next_state        <= out_ccd_3_11;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_3(10);

      when out_ccd_3_11 =>
        next_state        <= out_ccd_3_12;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_3(11);

      when out_ccd_3_12 =>
        next_state        <= out_ccd_3_13;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_3(12);
        
      when out_ccd_3_13 =>
        next_state        <= out_ccd_3_14;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_3(13);
        
      when out_ccd_3_14 =>
        next_state        <= out_ccd_3_15;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_3(14);

      when out_ccd_3_15 =>
        next_state        <= wait_end_trigger;
        next_write_enable <= '1';
        next_data_out     <= data_ccd_3(15);
        
      when wait_end_trigger =>
        if trigger = '1' then
          next_state <= wait_end_trigger;
        else
          next_state <= wait_trigger;
        end if;
        
        
    end case;
  end process;



end Behavioral;

