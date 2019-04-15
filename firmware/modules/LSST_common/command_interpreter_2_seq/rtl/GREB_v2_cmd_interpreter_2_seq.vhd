----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:     11/07/2016 
-- Design Name: 
-- Module Name:    GREB_v2_cmd_interpeter_2_seq - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.all;

use work.GREB_v2_commands_package_2_seq.all;
use work.Base_register_Set_package_greb_2_seq.all;
use work.LsstSciPackage.all;
use work.max_11046_top_package.all;
use work.dual_ads1118_top_package.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity GREB_v2_cmd_interpeter_2_seq is

  port (reset : in std_logic;
        clk   : in std_logic;

-- signals from/to SCI
        regReq           : in  std_logic;  -- with this line the master start a read/write procedure (1 to start)
        regOp            : in  std_logic;  -- this line define if the procedure is read or write (1 to write)
        regAddr          : in  std_logic_vector(23 downto 0);  -- address bus
        statusReg        : in  std_logic_vector(31 downto 0);  -- status reg bus. The RCI handle this bus and this machine pass it to the sure if he wants to read it
        regWrEn          : in  std_logic_vector(31 downto 0);  -- write enable bus. This bus enables the data write bits
        regDataWr_masked : in  std_logic_vector(31 downto 0);  -- data write bus masked. Is the logical AND of data write bus and write enable bus
        regAck           : out std_logic;  -- acknowledge line to activate when the read/write procedure is completed
        regFail          : out std_logic;  -- line to activate when an error occurs during the read/write procedure
        regDataRd        : out std_logic_vector(31 downto 0);  -- data bus to RCI used to transfer read data
        StatusReset      : out std_logic;  -- status block reset

-- Base Register Set signals            
        busy_bus               : in std_logic_vector(31 downto 0);  -- busy bus is composed by the different register sets busy
        time_base_actual_value : in std_logic_vector(63 downto 0);  -- time base value 
        trig_tm_value_SB       : in std_logic_vector(63 downto 0);  -- Status Block trigger time 
        trig_tm_value_TB       : in std_logic_vector(63 downto 0);  -- Time Base trigger time
        trig_tm_value_seq      : in std_logic_vector(63 downto 0);  -- Sequencer Trigger time
        trig_tm_value_V_I      : in std_logic_vector(63 downto 0);  -- Voltage and current sens trigger time
        trig_tm_value_pcb_t    : in std_logic_vector(63 downto 0);  -- PCB temperature Trigger time
--          trig_tm_value_f_adc    : in std_logic_vector(63 downto 0);  -- fast ADC Trigger time

        trigger_ce_bus     : out std_logic_vector(31 downto 0);  -- bus to enable register sets trigger. To trigger a register set that stops itself use en AND val                                      
        trigger_val_bus    : out std_logic_vector(31 downto 0);  -- bus of register sets trigger values  
        load_time_base_lsw : out std_logic;  -- ce signal to load the time base lsw
        load_time_base_MSW : out std_logic;  -- ce signal to load the time base MSW
        cnt_preset         : out std_logic_vector(63 downto 0);  -- preset value for the time base counter

        Mgt_avcc_ok   : in std_logic;
        Mgt_accpll_ok : in std_logic;
        Mgt_avtt_ok   : in std_logic;
        V3_3v_ok      : in std_logic;
        Switch_addr   : in std_logic_vector(7 downto 0);

-- sync commands
        sync_cmd_delay_en   : out std_logic;
        sync_cmd_delay_read : in  std_logic_vector(7 downto 0);

-- Image parameters
        image_size        : in  std_logic_vector(31 downto 0);  -- this register contains the image size
        image_patter_read : in  std_logic;  -- this register gives the state of image patter gen. 1 is ON
        ccd_sel_read      : in  std_logic_vector(2 downto 0);  -- this register contains the CCD to drive
        image_size_en     : out std_logic;  -- this line enables the register where the image size is written
        image_pattern_en  : out std_logic;  -- this register enable the image patter gen. 1 is ON
        ccd_sel_en        : out std_logic;  -- register enable for CCD acquisition selector


-- Sequencer
        -- sequencer 0
        seq_0_time_mem_readbk        : in  std_logic_vector(15 downto 0);  -- time memory read bus
        seq_0_out_mem_readbk         : in  std_logic_vector(31 downto 0);  -- time memory read bus
        seq_0_prog_mem_readbk        : in  std_logic_vector(31 downto 0);  -- sequencer program memory read
        seq_0_time_mem_w_en          : out std_logic;  -- this signal enables the time memory write
        seq_0_out_mem_w_en           : out std_logic;  -- this signal enables the output memory write
        seq_0_prog_mem_w_en          : out std_logic;  -- this signal enables the program memory write
        seq_0_step                   : out std_logic;  -- this signal send the STEP to the sequencer. Valid on in infinite loop (the machine jump out from IL to next function)   
        seq_0_stop                   : out std_logic;  -- this signal send the STOP to the sequencer. Valid on in infinite loop (the machine jump out from IL to next function)
        seq_0_enable_conv_shift_in   : in  std_logic;  -- this signal enable the adc_conv shifter (the adc_conv is shifted 1 clk every time is activated)
        seq_0_enable_conv_shift      : out std_logic;  -- this signal enable the adc_conv shifter (the adc_conv is shifted 1 clk every time is activated)
        seq_0_init_conv_shift        : out std_logic;  -- this signal initialize the adc_conv shifter (the adc_conv is shifted 1 clk every time is activated)
        seq_0_start_add_prog_mem_en  : out std_logic;
        seq_0_start_add_prog_mem_rbk : in  std_logic_vector(9 downto 0);
        seq_0_ind_func_mem_we        : out std_logic;
        seq_0_ind_func_mem_rdbk      : in  std_logic_vector(3 downto 0);
        seq_0_ind_rep_mem_we         : out std_logic;
        seq_0_ind_rep_mem_rdbk       : in  std_logic_vector(23 downto 0);
        seq_0_ind_sub_add_mem_we     : out std_logic;
        seq_0_ind_sub_add_mem_rdbk   : in  std_logic_vector(9 downto 0);
        seq_0_ind_sub_rep_mem_we     : out std_logic;
        seq_0_ind_sub_rep_mem_rdbk   : in  std_logic_vector(15 downto 0);
        seq_0_op_code_error          : in  std_logic;
        seq_0_op_code_error_add      : in  std_logic_vector(9 downto 0);
        seq_0_op_code_error_reset    : out std_logic;

        -- sequencer 1
        seq_1_time_mem_readbk        : in  std_logic_vector(15 downto 0);  -- time memory read bus
        seq_1_out_mem_readbk         : in  std_logic_vector(31 downto 0);  -- time memory read bus
        seq_1_prog_mem_readbk        : in  std_logic_vector(31 downto 0);  -- sequencer program memory read
        seq_1_time_mem_w_en          : out std_logic;  -- this signal enables the time memory write
        seq_1_out_mem_w_en           : out std_logic;  -- this signal enables the output memory write
        seq_1_prog_mem_w_en          : out std_logic;  -- this signal enables the program memory write
        seq_1_step                   : out std_logic;  -- this signal send the STEP to the sequencer. Valid on in infinite loop (the machine jump out from IL to next function)   
        seq_1_stop                   : out std_logic;  -- this signal send the STOP to the sequencer. Valid on in infinite loop (the machine jump out from IL to next function)
        seq_1_enable_conv_shift_in   : in  std_logic;  -- this signal enable the adc_conv shifter (the adc_conv is shifted 1 clk every time is activated)
        seq_1_enable_conv_shift      : out std_logic;  -- this signal enable the adc_conv shifter (the adc_conv is shifted 1 clk every time is activated)
        seq_1_init_conv_shift        : out std_logic;  -- this signal initialize the adc_conv shifter (the adc_conv is shifted 1 clk every time is activated)
        seq_1_start_add_prog_mem_en  : out std_logic;
        seq_1_start_add_prog_mem_rbk : in  std_logic_vector(9 downto 0);
        seq_1_ind_func_mem_we        : out std_logic;
        seq_1_ind_func_mem_rdbk      : in  std_logic_vector(3 downto 0);
        seq_1_ind_rep_mem_we         : out std_logic;
        seq_1_ind_rep_mem_rdbk       : in  std_logic_vector(23 downto 0);
        seq_1_ind_sub_add_mem_we     : out std_logic;
        seq_1_ind_sub_add_mem_rdbk   : in  std_logic_vector(9 downto 0);
        seq_1_ind_sub_rep_mem_we     : out std_logic;
        seq_1_ind_sub_rep_mem_rdbk   : in  std_logic_vector(15 downto 0);
        seq_1_op_code_error          : in  std_logic;
        seq_1_op_code_error_add      : in  std_logic_vector(9 downto 0);
        seq_1_op_code_error_reset    : out std_logic;

-- ASPIC

        aspic_config_r_ccd_1 : in  std_logic_vector(15 downto 0);
        aspic_config_r_ccd_2 : in  std_logic_vector(15 downto 0);
        aspic_config_r_ccd_3 : in  std_logic_vector(15 downto 0);
        aspic_op_end         : in  std_logic;
        aspic_start_trans    : out std_logic;
        aspic_start_reset    : out std_logic;
        aspic_nap_mode_en    : out std_logic;
        aspic_nap_ccd1_in    : in  std_logic;
        aspic_nap_ccd2_in    : in  std_logic;

-- CCD clock rails DAC          
        clk_rail_load_start : out std_logic;
        clk_rail_ldac_start : out std_logic;

-- BIAS DAC (former CABAC bias DAC)
        c_bias_dac_cmd_err : in  std_logic_vector(5 downto 0);
        c_bias_v_undr_th   : in  std_logic_vector(5 downto 0);
        c_bias_load_start  : out std_logic;
        c_bias_ldac_start  : out std_logic;

-- DREB voltage and current sensors
        error_V_HTR_voltage   : in std_logic;
        V_HTR_voltage         : in std_logic_vector(15 downto 0);
        error_V_HTR_current   : in std_logic;
        V_HTR_current         : in std_logic_vector(15 downto 0);
        error_V_DREB_voltage  : in std_logic;
        V_DREB_voltage        : in std_logic_vector(15 downto 0);
        error_V_DREB_current  : in std_logic;
        V_DREB_current        : in std_logic_vector(15 downto 0);
        error_V_CLK_H_voltage : in std_logic;
        V_CLK_H_voltage       : in std_logic_vector(15 downto 0);
        error_V_CLK_H_current : in std_logic;
        V_CLK_H_current       : in std_logic_vector(15 downto 0);
        error_V_ANA_voltage   : in std_logic;
        V_ANA_voltage         : in std_logic_vector(15 downto 0);
        error_V_ANA_current   : in std_logic;
        V_ANA_current         : in std_logic_vector(15 downto 0);
        error_V_OD_voltage    : in std_logic;
        V_OD_voltage          : in std_logic_vector(15 downto 0);
        error_V_OD_current    : in std_logic;
        V_OD_current          : in std_logic_vector(15 downto 0);

-- DREB temperature
        T1_dreb       : in std_logic_vector(15 downto 0);
        T1_dreb_error : in std_logic;
        T2_dreb       : in std_logic_vector(15 downto 0);
        T2_dreb_error : in std_logic;

-- REB temperature gr1
        T1_reb_gr1       : in std_logic_vector(15 downto 0);
        T1_reb_gr1_error : in std_logic;
        T2_reb_gr1       : in std_logic_vector(15 downto 0);
        T2_reb_gr1_error : in std_logic;
        T3_reb_gr1       : in std_logic_vector(15 downto 0);
        T3_reb_gr1_error : in std_logic;
        T4_reb_gr1       : in std_logic_vector(15 downto 0);
        T4_reb_gr1_error : in std_logic;

-- REB temperature gr2
        T1_reb_gr2       : in std_logic_vector(15 downto 0);
        T1_reb_gr2_error : in std_logic;
        T2_reb_gr2       : in std_logic_vector(15 downto 0);
        T2_reb_gr2_error : in std_logic;
        T3_reb_gr2       : in std_logic_vector(15 downto 0);
        T3_reb_gr2_error : in std_logic;
        T4_reb_gr2       : in std_logic_vector(15 downto 0);
        T4_reb_gr2_error : in std_logic;

-- REB temperature gr3
        T1_reb_gr3       : in std_logic_vector(15 downto 0);
        T1_reb_gr3_error : in std_logic;

-- ASPIC temp and voltage monitor
        aspic_t_v_data    :     array432;
        aspic_t_v_busy    : in  std_logic;
        aspic_t_v_start_r : out std_logic;

-- CCD temperature
        ccd_temp_busy        : in  std_logic;
        ccd_temp             : in  std_logic_vector(23 downto 0);
        ccd_temp_start       : out std_logic;
        ccd_temp_start_reset : out std_logic;

-- slow ADCs
        slow_adc_busy        : in  std_logic;
        ck_adc_conv_res      : in  array816;
        ccd1_adc_conv_res    : in  array816;
        ccd2_adc_conv_res    : in  array816;
        slow_adc_start_read  : out std_logic;
        slow_adc_start_write : out std_logic;


-- DREB 1wire serial number
        dreb_onewire_reset : out std_logic;
        dreb_sn_crc_ok     : in  std_logic;
        dreb_sn_dev_error  : in  std_logic;
        dreb_sn            : in  std_logic_vector(47 downto 0);
        dreb_sn_timeout    : in  std_logic;

-- REB 1wire serial number
        reb_onewire_reset : out std_logic;
        reb_sn_crc_ok     : in  std_logic;
        reb_sn_dev_error  : in  std_logic;
        reb_sn            : in  std_logic_vector(47 downto 0);
        reb_sn_timeout    : in  std_logic;

-- CCD clock enable
        ccd1_clk_en_in : in  std_logic;
        ccd2_clk_en_in : in  std_logic;
        ccd_clk_en     : out std_logic;

-- ASPIC reference enable
        aspic_ref_en_in_ccd1 : in  std_logic;
        aspic_ref_en_in_ccd2 : in  std_logic;
        aspic_ref_en         : out std_logic;

-- ASPIC 5V enable
        aspic_5v_en_in_ccd1 : in  std_logic;
        aspic_5v_en_in_ccd2 : in  std_logic;
        aspic_5v_en         : out std_logic;

-- CABAC regulators enable
        CABAC_reg_in : in  std_logic_vector(4 downto 0);
        CABAC_reg_en : out std_logic;

-- back bias switch
        back_bias_sw_rb    : in  std_logic;
        back_bias_cl_rb    : in  std_logic;
        back_bias_sw_error : in  std_logic;
        en_back_bias_sw    : out std_logic;

-- multiboot
        remote_update_reboot_status : in  std_logic_vector(31 downto 0);
        start_multiboot             : out std_logic;

-- remote update
        remote_update_fifo_full  : in  std_logic;
        remote_update_status_reg : in  std_logic_vector(15 downto 0);
        start_remote_update      : out std_logic;
        remote_update_bitstrm_we : out std_logic;
        remote_update_daq_done   : out std_logic

        );


end GREB_v2_cmd_interpeter_2_seq;

architecture Behavioral of GREB_v2_cmd_interpeter_2_seq is
  type state_type is (wait_cmd, error_state, ack_del_1, ack_del_2, wait_end_cmd,

-- BRS states
                      schema, hdl_version, SCI_ID, reserved_1, time_base_read_lsw, time_base_read_MSW,
                      reserved_2, reserved_3, state_busy, trigger_time_SB_lsw, trigger_time_SB_MSW,
                      trigger_time_TB_lsw, trigger_time_TB_MSW, trigger_time_seq_lsw, trigger_time_seq_MSW,
                      trigger_time_V_I_lsw, trigger_time_V_I_MSW, trigger_time_pcb_t_lsw, trigger_time_pcb_t_MSW,
                      --trig_tm_value_f_adc_lsw, trig_tm_value_f_adc_MSW,
                      v_ok_state, time_base_set_lsw, time_base_set_MSW, trigger_state, statusReg_rd,
                      sync_cmd_delay_wr_state, sync_cmd_delay_rd_state,
-- Image parameters
                      read_image_size_state, read_image_patter_mode_state, read_ccd_sel_state,
                      set_image_size_state, set_img_pattern_gen_state,
                      set_ccd_sel_state,
-- Sequncer
                      func_output_wr, func_time_wr, seq_prog_mem_wr,
                      seq_step_state, seq_stop_state,
                      seq_func_time_rd, seq_func_out_rd, seq_prog_mem_rd,
                      enable_conv_shift_rd, enable_conv_shift_state, init_conv_shift_state,
                      enable_start_add_prog_mem_state, start_add_prog_mem_rd_state,
                      seq_ind_func_mem_we_state, seq_ind_func_mem_rdbk_state,
                      seq_ind_rep_mem_we_state, seq_ind_rep_mem_rdbk_state,
                      seq_ind_sub_add_mem_we_state, seq_ind_sub_add_mem_rdbk_state,
                      seq_ind_sub_rep_mem_we_state, seq_ind_sub_rep_mem_rdbk_state,
                      seq_op_code_error_rd_state, seq_op_code_error_reset_state,

-- ASPIC        
                      aspic_start_trans_state,
                      aspic_start_trans_state_1, aspic_start_trans_state_2, aspic_start_trans_state_3,
                      aspic_start_reset_state,
                      aspic_start_reset_state_1, aspic_start_reset_state_2, aspic_start_reset_state_3,
                      aspic_read_conf_ccd_1_state, aspic_read_conf_ccd_2_state,
                      aspic_read_conf_ccd_3_state, set_aspic_nap_mode_state, read_aspic_nap_mode_state,

-- CCD clock rails DAC  
                      clk_rail_load_config_state, clk_rail_ldac_state,


-- CABAC bias DAC       
                      c_bias_load_config_state, c_bias_ldac_state, c_bias_read_error_vut_state,

-- DREB voltage and current sensors
                      V_HTR_voltage_state, V_HTR_current_state,
                      V_DREB_voltage_state, V_DREB_current_state,
                      V_CLK_H_voltage_state, V_CLK_H_current_state,
                      V_ANA_voltage_state, V_ANA_current_state,
                      V_OD_voltage_state, V_OD_current_state,

-- DREB temperature sensors
                      DREB_T1_state, DREB_T2_state,

-- REB temperature sensors gr1
                      REB_T1_gr1_state, REB_T2_gr1_state,
                      REB_T3_gr1_state, REB_T4_gr1_state,

-- REB temperature sensors gr2
                      REB_T1_gr2_state, REB_T2_gr2_state,
                      REB_T3_gr2_state, REB_T4_gr2_state,

-- REB temperature sensors gr3
                      REB_T1_gr3_state,

-- ASPIC temp and voltage monitor
                      aspic_t_v_read_t_top_state, aspic_t_v_read_t_bot_state,
                      aspic_t_v_read_2_5_state, aspic_t_v_read_5_state,
                      aspic_t_v_start_r_state, aspic_t_v_start_r_state_1,


-- CCD temperature sensor
                      ccd_temp_start_state, ccd_temp_start_reset_state, ccd_temp_read_state,

-- slow ADCs
                      slow_adc_start_write_state, slow_adc_start_read_state,

                      ck_adc_read_ch0_state, ck_adc_read_ch1_state,
                      ck_adc_read_ch2_state, ck_adc_read_ch3_state,
                      ck_adc_read_ch4_state, ck_adc_read_ch5_state,
                      ck_adc_read_ch6_state, ck_adc_read_ch7_state,

                      ccd1_adc_read_ch0_state, ccd1_adc_read_ch1_state,
                      ccd1_adc_read_ch2_state, ccd1_adc_read_ch3_state,
                      ccd1_adc_read_ch4_state, ccd1_adc_read_ch5_state,
                      ccd1_adc_read_ch6_state, ccd1_adc_read_ch7_state,

                      ccd2_adc_read_ch0_state, ccd2_adc_read_ch1_state,
                      ccd2_adc_read_ch2_state, ccd2_adc_read_ch3_state,
                      ccd2_adc_read_ch4_state, ccd2_adc_read_ch5_state,
                      ccd2_adc_read_ch6_state, ccd2_adc_read_ch7_state,

-- DREB 1wire serial number
                      dreb_sn_acq_state, dreb_sn_read_w0_state, dreb_sn_read_w1_state,

-- REB 1wire serial number
                      reb_sn_acq_state, reb_sn_read_w0_state, reb_sn_read_w1_state,

-- CCD clock enable
                      ccd_clk_en_rd, ccd_clk_en_state,

-- ASPIC reference enable
                      aspic_ref_en_rd, aspic_ref_en_state,

-- ASPIC 5V enable
                      aspic_5v_en_rd, aspic_5v_en_state,

-- CABAC regulators enable
                      CABAC_reg_en_rd, CABAC_reg_en_state,

-- back bias switch 
                      back_bias_sw_set_state, back_bias_sw_read_state,

-- multiboot    
                      start_multiboot_state, reboot_status_rd_state,

-- remote update
                      remote_update_rd_status_state,
                      start_remote_update_state, remote_update_bitstrm_we_state, remote_update_daq_done_state

                      );

  signal pres_state, next_state : state_type;

  -- this directive is to force the encoding to gray
  -- It is required to solve a vivado bug that apperars if there are more than
  -- 134 states
  attribute fsm_encoding                           : string;
  attribute fsm_encoding of pres_state, next_state : signal is "gray";

-- RCI signals
  signal next_regAck      : std_logic;
  signal next_regFail     : std_logic;
  signal next_regDataRd   : std_logic_vector(31 downto 0);
  signal next_StatusReset : std_logic;

-- BRS signals
  signal next_trigger_ce_bus     : std_logic_vector(31 downto 0);
  signal next_trigger_val_bus    : std_logic_vector(31 downto 0);
  signal next_load_time_base_lsw : std_logic;
  signal next_load_time_base_MSW : std_logic;
  signal next_cnt_preset         : std_logic_vector(63 downto 0);

-- sync commands signals
  signal next_sync_cmd_delay_en : std_logic;

-- Image parameters
  signal next_image_size_en    : std_logic;
  signal next_image_pattern_en : std_logic;
  signal next_ccd_sel_en       : std_logic;

-- Sequencer
  -- sequencer 0
  signal next_seq_0_time_mem_w_en         : std_logic;  -- function outupt register enable flag
  signal next_seq_0_out_mem_w_en          : std_logic;  -- function time register enable flag
  signal next_seq_0_prog_mem_w_en         : std_logic;  -- sequencer program memory enable flag
  signal next_seq_0_step                  : std_logic;  -- this signal send the STEP to the sequencer. Valid on in infinite loop (the machine jump out from IL to next function)   
  signal next_seq_0_stop                  : std_logic;  -- this signal send the STOP to the sequencer. Valid on in infinite loop (the machine jump out from IL and stop all function)   
  signal next_seq_0_enable_conv_shift     : std_logic;
  signal next_seq_0_init_conv_shift       : std_logic;
  signal next_seq_0_start_add_prog_mem_en : std_logic;
  signal next_seq_0_ind_func_mem_we       : std_logic;
  signal next_seq_0_ind_rep_mem_we        : std_logic;
  signal next_seq_0_ind_sub_add_mem_we    : std_logic;
  signal next_seq_0_ind_sub_rep_mem_we    : std_logic;
  signal next_seq_0_op_code_error_reset   : std_logic;

  -- sequencer 1
  signal next_seq_1_time_mem_w_en         : std_logic;  -- function outupt register enable flag
  signal next_seq_1_out_mem_w_en          : std_logic;  -- function time register enable flag
  signal next_seq_1_prog_mem_w_en         : std_logic;  -- sequencer program memory enable flag
  signal next_seq_1_step                  : std_logic;  -- this signal send the STEP to the sequencer. Valid on in infinite loop (the machine jump out from IL to next function)   
  signal next_seq_1_stop                  : std_logic;  -- this signal send the STOP to the sequencer. Valid on in infinite loop (the machine jump out from IL and stop all function)   
  signal next_seq_1_enable_conv_shift     : std_logic;
  signal next_seq_1_init_conv_shift       : std_logic;
  signal next_seq_1_start_add_prog_mem_en : std_logic;
  signal next_seq_1_ind_func_mem_we       : std_logic;
  signal next_seq_1_ind_rep_mem_we        : std_logic;
  signal next_seq_1_ind_sub_add_mem_we    : std_logic;
  signal next_seq_1_ind_sub_rep_mem_we    : std_logic;
  signal next_seq_1_op_code_error_reset   : std_logic;


-- ASPIC
  signal next_aspic_start_trans : std_logic;
  signal next_aspic_start_reset : std_logic;
  signal next_aspic_nap_mode_en : std_logic;

-- CCD clock rails DAC          
  signal next_clk_rail_load_start : std_logic;
  signal next_clk_rail_ldac_start : std_logic;

-- CABAC bias DAC               
  signal next_c_bias_load_start : std_logic;
  signal next_c_bias_ldac_start : std_logic;

-- ASPIC temp and voltage monitor
  signal next_aspic_t_v_start_r : std_logic;

-- CCD tempearture 
  signal next_ccd_temp_start       : std_logic;
  signal next_ccd_temp_start_reset : std_logic;

-- bias slow ADC
  signal next_slow_adc_start_read  : std_logic;
  signal next_slow_adc_start_write : std_logic;

-- DREB 1wire serial number
  signal next_dreb_onewire_reset : std_logic;

-- REB 1wire serial number
  signal next_reb_onewire_reset : std_logic;

-- CCD clock enable   
  signal next_ccd_clk_en : std_logic;

-- ASPIC reference enable   
  signal next_aspic_ref_en : std_logic;

-- ASPIC 5V enable   
  signal next_aspic_5v_en : std_logic;

-- CABAC regulators enable      
  signal next_CABAC_reg_en : std_logic;

-- back bias switch 
  signal next_en_back_bias_sw : std_logic;

-- multiboot
  signal next_start_multiboot : std_logic;

-- remote update
  signal next_start_remote_update      : std_logic;
  signal next_remote_update_bitstrm_we : std_logic;
  signal next_remote_update_daq_done   : std_logic;
  
begin

  process (clk)
  begin
    if clk'event and clk = '1' then
      if reset = '1' then
        pres_state <= wait_cmd;

        -- RCI reset state
        regAck      <= '0';
        regFail     <= '0';
        regDataRd   <= (others => '0');
        StatusReset <= '0';

        -- BRS reset state
        trigger_ce_bus     <= (others => '0');
        trigger_val_bus    <= (others => '0');
        load_time_base_lsw <= '0';
        load_time_base_MSW <= '0';
        cnt_preset         <= (others => '0');
        sync_cmd_delay_en  <= '0';

        -- image parameters reset state
        image_size_en    <= '0';
        image_pattern_en <= '0';
        ccd_sel_en       <= '0';

        -- Sequencer reset state
        -- sequencer 0
        seq_0_time_mem_w_en         <= '0';
        seq_0_out_mem_w_en          <= '0';
        seq_0_prog_mem_w_en         <= '0';
        seq_0_step                  <= '0';
        seq_0_stop                  <= '0';
        seq_0_enable_conv_shift     <= '0';
        seq_0_init_conv_shift       <= '0';
        seq_0_start_add_prog_mem_en <= '0';
        seq_0_ind_func_mem_we       <= '0';
        seq_0_ind_rep_mem_we        <= '0';
        seq_0_ind_sub_add_mem_we    <= '0';
        seq_0_ind_sub_rep_mem_we    <= '0';
        seq_0_op_code_error_reset   <= '0';

        -- sequencer 1
        seq_1_time_mem_w_en         <= '0';
        seq_1_out_mem_w_en          <= '0';
        seq_1_prog_mem_w_en         <= '0';
        seq_1_step                  <= '0';
        seq_1_stop                  <= '0';
        seq_1_enable_conv_shift     <= '0';
        seq_1_init_conv_shift       <= '0';
        seq_1_start_add_prog_mem_en <= '0';
        seq_1_ind_func_mem_we       <= '0';
        seq_1_ind_rep_mem_we        <= '0';
        seq_1_ind_sub_add_mem_we    <= '0';
        seq_1_ind_sub_rep_mem_we    <= '0';
        seq_1_op_code_error_reset   <= '0';

        -- ASPIC
        aspic_start_trans <= '0';
        aspic_start_reset <= '0';
        aspic_nap_mode_en <= '0';

        -- CCD clock rails DAC          
        clk_rail_load_start <= '0';
        clk_rail_ldac_start <= '0';

        -- CABAC bias DAC               
        c_bias_load_start <= '0';
        c_bias_ldac_start <= '0';

        -- ASPIC temp and voltge monitor
        aspic_t_v_start_r <= '0';

        -- CCD temperature 
        ccd_temp_start       <= '0';
        ccd_temp_start_reset <= '0';

        -- slow adcs
        slow_adc_start_read  <= '0';
        slow_adc_start_write <= '0';

        -- DREB 1wire sn
        dreb_onewire_reset <= '0';

        -- REB 1wire sn
        reb_onewire_reset <= '0';

        -- CCD clock enable
        ccd_clk_en <= '0';

        -- ASPIC reference enable
        aspic_ref_en <= '0';

        -- ASPIC 5V enable
        aspic_5v_en <= '0';

        -- CABAC regulators enable
        CABAC_reg_en <= '0';

        -- back bias switch set
        en_back_bias_sw <= '0';

        -- multiboot
        start_multiboot <= '0';

        -- remote update
        start_remote_update      <= '0';
        remote_update_bitstrm_we <= '0';
        remote_update_daq_done   <= '0';

      else
        pres_state <= next_state;

        -- RCI latch
        regAck      <= next_regAck;
        regFail     <= next_regFail;
        regDataRd   <= next_regDataRd;
        StatusReset <= next_StatusReset;

        -- BRS latch
        trigger_ce_bus     <= next_trigger_ce_bus;
        trigger_val_bus    <= next_trigger_val_bus;
        load_time_base_lsw <= next_load_time_base_lsw;
        load_time_base_MSW <= next_load_time_base_MSW;
        cnt_preset         <= next_cnt_preset;
        sync_cmd_delay_en  <= next_sync_cmd_delay_en;

        -- image parameters latch
        image_size_en    <= next_image_size_en;
        image_pattern_en <= next_image_pattern_en;
        ccd_sel_en       <= next_ccd_sel_en;

        -- Sequencer latch
        -- sequencer 0
        seq_0_time_mem_w_en         <= next_seq_0_time_mem_w_en;
        seq_0_out_mem_w_en          <= next_seq_0_out_mem_w_en;
        seq_0_prog_mem_w_en         <= next_seq_0_prog_mem_w_en;
        seq_0_step                  <= next_seq_0_step;
        seq_0_stop                  <= next_seq_0_stop;
        seq_0_enable_conv_shift     <= next_seq_0_enable_conv_shift;
        seq_0_init_conv_shift       <= next_seq_0_init_conv_shift;
        seq_0_start_add_prog_mem_en <= next_seq_0_start_add_prog_mem_en;
        seq_0_ind_func_mem_we       <= next_seq_0_ind_func_mem_we;
        seq_0_ind_rep_mem_we        <= next_seq_0_ind_rep_mem_we;
        seq_0_ind_sub_add_mem_we    <= next_seq_0_ind_sub_add_mem_we;
        seq_0_ind_sub_rep_mem_we    <= next_seq_0_ind_sub_rep_mem_we;
        seq_0_op_code_error_reset   <= next_seq_0_op_code_error_reset;
        -- sequencer 1
        seq_1_time_mem_w_en         <= next_seq_1_time_mem_w_en;
        seq_1_out_mem_w_en          <= next_seq_1_out_mem_w_en;
        seq_1_prog_mem_w_en         <= next_seq_1_prog_mem_w_en;
        seq_1_step                  <= next_seq_1_step;
        seq_1_stop                  <= next_seq_1_stop;
        seq_1_enable_conv_shift     <= next_seq_1_enable_conv_shift;
        seq_1_init_conv_shift       <= next_seq_1_init_conv_shift;
        seq_1_start_add_prog_mem_en <= next_seq_1_start_add_prog_mem_en;
        seq_1_ind_func_mem_we       <= next_seq_1_ind_func_mem_we;
        seq_1_ind_rep_mem_we        <= next_seq_1_ind_rep_mem_we;
        seq_1_ind_sub_add_mem_we    <= next_seq_1_ind_sub_add_mem_we;
        seq_1_ind_sub_rep_mem_we    <= next_seq_1_ind_sub_rep_mem_we;
        seq_1_op_code_error_reset   <= next_seq_1_op_code_error_reset;


        -- ASPIC
        aspic_start_trans <= next_aspic_start_trans;
        aspic_start_reset <= next_aspic_start_reset;
        aspic_nap_mode_en <= next_aspic_nap_mode_en;

        -- CCD clock rails DAC               
        clk_rail_load_start <= next_clk_rail_load_start;
        clk_rail_ldac_start <= next_clk_rail_ldac_start;

        -- CABAC bias DAC               
        c_bias_load_start <= next_c_bias_load_start;
        c_bias_ldac_start <= next_c_bias_ldac_start;

        -- ASPIC temp and voltage monitor
        aspic_t_v_start_r <= next_aspic_t_v_start_r;

        -- CCD temperature
        ccd_temp_start       <= next_ccd_temp_start;
        ccd_temp_start_reset <= next_ccd_temp_start_reset;

        -- slow adcs
        slow_adc_start_read  <= next_slow_adc_start_read;
        slow_adc_start_write <= next_slow_adc_start_write;

        -- DREB 1wire sn
        dreb_onewire_reset <= next_dreb_onewire_reset;

        -- REB 1wire sn
        reb_onewire_reset <= next_reb_onewire_reset;

        -- CCD clock enable
        ccd_clk_en <= next_ccd_clk_en;

        -- ASPIC reference enable
        aspic_ref_en <= next_aspic_ref_en;

        -- ASPIC 5V enable
        aspic_5v_en <= next_aspic_5v_en;

        -- CABAC regulators enable
        CABAC_reg_en <= next_CABAC_reg_en;

        -- back bias switch set
        en_back_bias_sw <= next_en_back_bias_sw;

        -- multiboot
        start_multiboot <= next_start_multiboot;

        -- remote update

        start_remote_update      <= next_start_remote_update;
        remote_update_bitstrm_we <= next_remote_update_bitstrm_we;
        remote_update_daq_done   <= next_remote_update_daq_done;
        
      end if;
    end if;
  end process;


  process (pres_state, regReq , regOP, RegAddr, regdatawr_masked, regwren, switch_addr, time_base_actual_value,
           busy_bus, trig_tm_value_sb, trig_tm_value_tb, trig_tm_value_seq, trig_tm_value_v_i, trig_tm_value_pcb_t,
           --trig_tm_value_f_adc,

           -- CCD bias
           c_bias_dac_cmd_err, c_bias_v_undr_th,
           -- Bacbias switch
           back_bias_sw_rb, back_bias_cl_rb, back_bias_sw_error,

           mgt_avcc_ok, image_size, image_patter_read, ccd_sel_read, statusreg,
           sync_cmd_delay_read,
           seq_0_time_mem_readbk, seq_0_out_mem_readbk, seq_0_prog_mem_readbk, seq_0_ind_func_mem_rdbk,
           seq_0_ind_rep_mem_rdbk, seq_0_ind_sub_add_mem_rdbk, seq_0_ind_sub_rep_mem_rdbk, seq_0_op_code_error,
           seq_0_enable_conv_shift_in, seq_0_start_add_prog_mem_rbk, seq_0_op_code_error_add,
           seq_1_time_mem_readbk, seq_1_out_mem_readbk, seq_1_prog_mem_readbk, seq_1_ind_func_mem_rdbk,
           seq_1_ind_rep_mem_rdbk, seq_1_ind_sub_add_mem_rdbk, seq_1_ind_sub_rep_mem_rdbk, seq_1_op_code_error,
           seq_1_enable_conv_shift_in, seq_1_start_add_prog_mem_rbk, seq_1_op_code_error_add,
           v3_3v_ok, aspic_config_r_ccd_1, aspic_config_r_ccd_2, aspic_config_r_ccd_3, aspic_op_end,
           error_v_htr_voltage, error_v_htr_current, error_v_dreb_voltage, error_v_dreb_current, error_v_clk_h_voltage,
           error_v_clk_h_current, error_v_ana_voltage, error_v_ana_current,
           error_v_od_voltage, error_v_od_current, t1_dreb_error, t2_dreb_error, t1_reb_gr1_error, t2_reb_gr1_error,
           t3_reb_gr1_error, t4_reb_gr1_error, t1_reb_gr2_error, t2_reb_gr2_error, t3_reb_gr2_error, t4_reb_gr2_error,
           t1_reb_gr3_error, aspic_t_v_data, aspic_t_v_busy, ccd_temp, ccd_temp_busy,
           slow_adc_busy, ck_adc_conv_res, ccd1_adc_conv_res, ccd2_adc_conv_res,
           dreb_sn_crc_ok, dreb_sn , dreb_sn_timeout, reb_sn_crc_ok, reb_sn, reb_sn_timeout, ccd1_clk_en_in, ccd2_clk_en_in,
           aspic_ref_en_in_ccd1, aspic_ref_en_in_ccd2, aspic_5v_en_in_ccd1, aspic_5v_en_in_ccd2,
           mgt_accpll_ok, v_htr_voltage, v_htr_current, v_dreb_voltage, mgt_avtt_ok,
           v_dreb_current, v_clk_h_voltage, v_clk_h_current, v_ana_voltage, v_ana_current,
           v_od_voltage, v_od_current, t1_dreb, t2_dreb, t1_reb_gr1, t2_reb_gr1, t3_reb_gr1, t4_reb_gr1, t1_reb_gr2,
           t2_reb_gr2, t3_reb_gr2, t4_reb_gr2, t1_reb_gr3, dreb_sn_dev_error, reb_sn_dev_error,
           CABAC_reg_in, aspic_nap_ccd1_in, aspic_nap_ccd2_in,

           -- Remote Update
           remote_update_fifo_full, remote_update_status_reg, remote_update_reboot_status
           )

  begin

    -------------------- outputs default values --------------------
    -- RCI default state
    next_regAck      <= '0';
    next_regFail     <= '0';
    next_regDataRd   <= (others => '0');
    next_StatusReset <= '0';

                                        -- BRS default state
    next_trigger_ce_bus     <= (others => '0');
    next_trigger_val_bus    <= (others => '0');
    next_load_time_base_lsw <= '0';
    next_load_time_base_MSW <= '0';
    next_cnt_preset         <= (others => '0');
    next_sync_cmd_delay_en  <= '0';

                                        -- Image Parameters default state
    next_image_size_en    <= '0';
    next_image_pattern_en <= '0';
    next_ccd_sel_en       <= '0';

                                        -- Sequencer default state
    -- sequencer 0
    next_seq_0_time_mem_w_en         <= '0';
    next_seq_0_out_mem_w_en          <= '0';
    next_seq_0_prog_mem_w_en         <= '0';
    next_seq_0_step                  <= '0';
    next_seq_0_stop                  <= '0';
    next_seq_0_enable_conv_shift     <= '0';
    next_seq_0_init_conv_shift       <= '0';
    next_seq_0_start_add_prog_mem_en <= '0';

    next_seq_0_ind_func_mem_we    <= '0';
    next_seq_0_ind_rep_mem_we     <= '0';
    next_seq_0_ind_sub_add_mem_we <= '0';
    next_seq_0_ind_sub_rep_mem_we <= '0';

    next_seq_0_op_code_error_reset <= '0';

    -- sequencer 1
    next_seq_1_time_mem_w_en         <= '0';
    next_seq_1_out_mem_w_en          <= '0';
    next_seq_1_prog_mem_w_en         <= '0';
    next_seq_1_step                  <= '0';
    next_seq_1_stop                  <= '0';
    next_seq_1_enable_conv_shift     <= '0';
    next_seq_1_init_conv_shift       <= '0';
    next_seq_1_start_add_prog_mem_en <= '0';

    next_seq_1_ind_func_mem_we    <= '0';
    next_seq_1_ind_rep_mem_we     <= '0';
    next_seq_1_ind_sub_add_mem_we <= '0';
    next_seq_1_ind_sub_rep_mem_we <= '0';

    next_seq_1_op_code_error_reset <= '0';

                                        -- ASPIC
    next_aspic_start_trans <= '0';
    next_aspic_start_reset <= '0';
    next_aspic_nap_mode_en <= '0';

                                        -- CCD clock rails DAC          
    next_clk_rail_load_start <= '0';
    next_clk_rail_ldac_start <= '0';

                                        -- CABAC DAC            
    next_c_bias_load_start <= '0';
    next_c_bias_ldac_start <= '0';

                                        -- ASPIC temp and voltage monitor
    next_aspic_t_v_start_r <= '0';

                                        -- CCD temperature 
    next_ccd_temp_start       <= '0';
    next_ccd_temp_start_reset <= '0';

                                        -- slow adcs
    next_slow_adc_start_read  <= '0';
    next_slow_adc_start_write <= '0';


                                        -- DREB 1wire sn
    next_dreb_onewire_reset <= '0';

                                        -- REB 1wire sn
    next_reb_onewire_reset <= '0';

                                        -- CCD clock enable
    next_ccd_clk_en <= '0';

                                        -- ASPIC reference enable
    next_aspic_ref_en <= '0';

    -- ASPIC 5V enable
    next_aspic_5v_en <= '0';

                                        -- CABAC regulators enable
    next_CABAC_reg_en <= '0';

                                        -- back bias switch set
    next_en_back_bias_sw <= '0';

    -- multiboot
    next_start_multiboot <= '0';

    -- remote update

    next_start_remote_update      <= '0';
    next_remote_update_bitstrm_we <= '0';
    next_remote_update_daq_done   <= '0';



    case pres_state is
--------------------------------------------------------  CMD INTERPTETER --------------------------------------------------------
      
      when wait_cmd =>
        if regReq = '0' then
          next_state <= wait_cmd;
        else
          if regOp = '0' then

------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------  READ ---------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
---------- Base Register Set read

                                        -- schema
            if regAddr = read_schema_cmd then
              next_state <= schema;

                                        -- hdl version
            elsif regAddr = read_hdl_version_cmd then
              next_state <= hdl_version;

                                        -- SCI ID
            elsif regAddr = read_SCI_ID_cmd then
              next_state <= SCI_ID;

                                        -- reserved 1
            elsif regAddr = read_reserved_1_cmd then
              next_state <= reserved_1;

                                        -- time base read lsw
            elsif regAddr = time_base_lsw_cmd then
              next_state <= time_base_read_lsw;

                                        -- time base read MSW
            elsif regAddr = time_base_MSW_cmd then
              next_state <= time_base_read_MSW;

                                        -- reserved 2
            elsif regAddr = read_reserved_2_cmd then
              next_state <= reserved_2;

                                        -- reserved 3           
            elsif regAddr = read_reserved_3_cmd then
              next_state <= reserved_3;

                                        -- read busy state              
            elsif regAddr = read_state_busy_cmd then
              next_state <= state_busy;

                                        -- read Status Block trigger time lsw
            elsif regAddr = read_trig_time_SB_lsw_cmd then
              next_state <= trigger_time_SB_lsw;

                                        -- read Status Block trigger time MSW           
            elsif regAddr = read_trig_time_SB_MSW_cmd then
              next_state <= trigger_time_SB_MSW;

                                        -- read Time Base trigger time lsw      
            elsif regAddr = read_trig_time_TB_lsw_cmd then
              next_state <= trigger_time_TB_lsw;

                                        -- read Time Base trigger time MSW
            elsif regAddr = read_trig_time_TB_MSW_cmd then
              next_state <= trigger_time_TB_MSW;

                                        -- read Sequencer trigger time lsw
            elsif regAddr = read_trig_time_seq_lsw_cmd then
              next_state <= trigger_time_seq_lsw;

                                        -- read Sequencer trigger time MSW
            elsif regAddr = read_trig_time_seq_MSW_cmd then
              next_state <= trigger_time_seq_MSW;

                                        -- read Voltage and Current sens trigger time lsw       
            elsif regAddr = read_trig_time_V_I_lsw_cmd then
              next_state <= trigger_time_V_I_lsw;

                                        -- read Voltage and Current sens trigger time MSW
            elsif regAddr = read_trig_time_V_I_MSW_cmd then
              next_state <= trigger_time_V_I_MSW;

                                        -- read pcb T trigger time lsw
            elsif regAddr = read_trig_time_pcb_t_lsw_cmd then
              next_state <= trigger_time_pcb_t_lsw;

                                        -- read pcb T trigger time MSW
            elsif regAddr = read_trig_time_pcb_t_MSW_cmd then
              next_state <= trigger_time_pcb_t_MSW;

              --                            -- read fast ADC trigger time lsw
              --elsif regAddr = read_trig_time_f_adc_lsw_cmd then
              --  next_state <= trig_tm_value_f_adc_lsw;

              --                            -- read fast ADC trigger time MSW
              --elsif regAddr = read_trig_time_f_adc_MSW_cmd then
              --  next_state <= trig_tm_value_f_adc_MSW;

                                        -- read Voltages OK 
            elsif regAddr = read_v_ok_cmd then
              next_state <= v_ok_state;

                                        -- read status register         
            elsif (regAddr >= read_status_reg_base) and (regAddr <= read_status_reg_high) then
              next_state <= statusReg_rd;

            elsif regAddr = sync_cmd_delay_cmd then
              next_state <= sync_cmd_delay_rd_state;

              -------- Image parameters read                            
              -- read image size          
            elsif regAddr = image_size_cmd then
              next_state <= read_image_size_state;

                                        -- read image patter mode configuration
            elsif regAddr = image_patter_mode_cmd then
              next_state <= read_image_patter_mode_state;

                                        -- read CCD selector configuration
            elsif regAddr = ccd_sel_cmd then
              next_state <= read_ccd_sel_state;

              -------- Sequencer parameters read
              -- time memory read
            elsif ((regAddr >= func_time_set_base_0) and (regAddr <= func_time_set_high_0)) or
              ((regAddr >= func_time_set_base_1) and (regAddr <= func_time_set_high_1))
            then
              next_state <= seq_func_time_rd;

                                        -- output memory read
            elsif ((regAddr >= func_out_set_base_0) and (regAddr <= func_out_set_high_0)) or
              ((regAddr >= func_out_set_base_1) and (regAddr <= func_out_set_high_1))
            then
              next_state <= seq_func_out_rd;

                                        -- program memory read
            elsif ((regAddr >= prog_mem_base_0) and (regAddr <= prog_mem_high_0)) or
              ((regAddr >= prog_mem_base_1) and (regAddr <= prog_mem_high_1))
            then
              next_state <= seq_prog_mem_rd;

                                        -- read ADC conv shifter configuration
            elsif regAddr = enable_conv_shift_cmd_0 or regAddr = enable_conv_shift_cmd_1 then
              next_state <= enable_conv_shift_rd;

                                        -- read the program mem start address 
            elsif regAddr = start_add_cmd_0 or regAddr = start_add_cmd_1 then
              next_state <= start_add_prog_mem_rd_state;

                                        -- reads indirect functions memory  
            elsif ((regAddr >= seq_ind_func_mem_base_0) and (regAddr <= seq_ind_func_mem_high_1)) or
              ((regAddr >= seq_ind_func_mem_base_0) and (regAddr <= seq_ind_func_mem_high_1))
            then
              next_state <= seq_ind_func_mem_rdbk_state;

                                        -- reads indirect repetitions mem 
            elsif ((regAddr >= seq_ind_rep_mem_base_0) and (regAddr <= seq_ind_rep_mem_high_0)) or
              ((regAddr >= seq_ind_rep_mem_base_1) and (regAddr <= seq_ind_rep_mem_high_1))
            then
              next_state <= seq_ind_rep_mem_rdbk_state;

                                        -- reads indirect subroutines mem 
            elsif ((regAddr >= seq_ind_sub_add_mem_base_0) and (regAddr <= seq_ind_sub_add_mem_high_0)) or
              ((regAddr >= seq_ind_sub_add_mem_base_1) and (regAddr <= seq_ind_sub_add_mem_high_1))
            then
              next_state <= seq_ind_sub_add_mem_rdbk_state;

                                        -- reads indirect subroutines repetitions mem 
            elsif ((regAddr >= seq_ind_sub_rep_mem_base_0) and (regAddr <= seq_ind_sub_rep_mem_high_0)) or
              ((regAddr >= seq_ind_sub_rep_mem_base_1) and (regAddr <= seq_ind_sub_rep_mem_high_1))
            then
              next_state <= seq_ind_sub_rep_mem_rdbk_state;

                                        -- reads op code error flag 
            elsif regAddr = seq_op_code_error_rd_cmd_0 or regAddr = seq_op_code_error_rd_cmd_1 then
              next_state <= seq_op_code_error_rd_state;

              --------CABAC parameters read             
              -- CABAC configuration ccd 1 read
              --elsif regAddr = cabac_conf_read_ccd1_cmd then
              --  next_state <= cabac_read_conf_ccd_1_state;

              --------ASPIC parameters read             
              -- ASPIC configuration ccd 1 read
            elsif regAddr = aspic_conf_read_ccd1_cmd then
              next_state <= aspic_read_conf_ccd_1_state;

                                        -- ASPIC configuration ccd 2 read
            elsif regAddr = aspic_conf_read_ccd2_cmd then
              next_state <= aspic_read_conf_ccd_2_state;

                                        -- ASPIC configuration ccd 3 read
            elsif regAddr = aspic_conf_read_ccd3_cmd then
              next_state <= aspic_read_conf_ccd_3_state;

                                        -- read ASPIC nap mode
            elsif regAddr = aspic_nap_mode_cmd then
              next_state <= read_aspic_nap_mode_state;

              --------CCD bias protection error and flag read

            elsif regAddr = c_bias_err_vut_cmd then
              next_state <= c_bias_read_error_vut_state;

              --elsif regAddr = ccd_bias_err_vut_cmd then
              --  next_state <= ccd_bias_read_error_vut_state;

                                        --------REB voltage and current sensors read                           
                                        -- V_HTR voltage read
            elsif regAddr = V_HTR_voltage_cmd then
              next_state <= V_HTR_voltage_state;

                                        -- V_HTR current read
            elsif regAddr = V_HTR_current_cmd then
              next_state <= V_HTR_current_state;

                                        -- V_DREB voltage read
            elsif regAddr = V_DREB_voltage_cmd then
              next_state <= V_DREB_voltage_state;

                                        -- V_DREB current read
            elsif regAddr = V_DREB_current_cmd then
              next_state <= V_DREB_current_state;

                                        -- V_CLK_H voltage read
            elsif regAddr = V_CLK_H_voltage_cmd then
              next_state <= V_CLK_H_voltage_state;

                                        -- V_CLK_H current read
            elsif regAddr = V_CLK_H_current_cmd then
              next_state <= V_CLK_H_current_state;

                                        -- V_ANA voltage read
            elsif regAddr = V_ANA_voltage_cmd then
              next_state <= V_ANA_voltage_state;

                                        -- V_ANA current read
            elsif regAddr = V_ANA_current_cmd then
              next_state <= V_ANA_current_state;

                                        -- V_OD voltage read
            elsif regAddr = V_OD_voltage_cmd then
              next_state <= V_OD_voltage_state;

                                        -- V_OD current read
            elsif regAddr = V_OD_current_cmd then
              next_state <= V_OD_current_state;

                                        --------DREB temperature sensors read                          
                                        -- DREB T1 read
            elsif regAddr = DREB_T1_cmd then
              next_state <= DREB_T1_state;

                                        -- DREB T2 read
            elsif regAddr = DREB_T2_cmd then
              next_state <= DREB_T2_state;

                                        --------REB temperature sensors gr1 read                               
                                        -- REB T1 gr1 read
            elsif regAddr = REB_T1_gr1_cmd then
              next_state <= REB_T1_gr1_state;

                                        -- REB T2 gr1 read
            elsif regAddr = REB_T2_gr1_cmd then
              next_state <= REB_T2_gr1_state;

                                        -- REB T3 gr1 read
            elsif regAddr = REB_T3_gr1_cmd then
              next_state <= REB_T3_gr1_state;

                                        -- REB T4 gr1 read
            elsif regAddr = REB_T4_gr1_cmd then
              next_state <= REB_T4_gr1_state;

                                        --------REB temperature sensors gr2 read                               
                                        -- REB T1 gr2 read
            elsif regAddr = REB_T1_gr2_cmd then
              next_state <= REB_T1_gr2_state;

                                        -- REB T2 gr2 read
            elsif regAddr = REB_T2_gr2_cmd then
              next_state <= REB_T2_gr2_state;

                                        -- REB T3 gr2 read
            elsif regAddr = REB_T3_gr2_cmd then
              next_state <= REB_T3_gr2_state;

                                        -- REB T4 gr2 read
            elsif regAddr = REB_T4_gr2_cmd then
              next_state <= REB_T4_gr2_state;

                                        --------REB temperature sensors gr3 read                               
                                        -- REB T1 gr3 read
            elsif regAddr = REB_T1_gr3_cmd then
              next_state <= REB_T1_gr3_state;

                                        -------- ASPIC temp and voltage monitor
            elsif regAddr = aspic_t_v_read_t_top_cmd then
              next_state <= aspic_t_v_read_t_top_state;

            elsif regAddr = aspic_t_v_read_t_bot_cmd then
              next_state <= aspic_t_v_read_t_bot_state;

            elsif regAddr = aspic_t_v_read_2_5_cmd then
              next_state <= aspic_t_v_read_2_5_state;

            elsif regAddr = aspic_t_v_read_5_cmd then
              next_state <= aspic_t_v_read_5_state;

                                        --------CCD temeprature read                                   
            elsif regAddr = ccd_temp_read_cmd then
              next_state <= ccd_temp_read_state;

-------- slow adcs
              --------clock rails slow adc
            elsif regAddr = ck_adc_read_ch0_cmd then
              next_state <= ck_adc_read_ch0_state;

            elsif regAddr = ck_adc_read_ch1_cmd then
              next_state <= ck_adc_read_ch1_state;

            elsif regAddr = ck_adc_read_ch2_cmd then
              next_state <= ck_adc_read_ch2_state;

            elsif regAddr = ck_adc_read_ch3_cmd then
              next_state <= ck_adc_read_ch3_state;

            elsif regAddr = ck_adc_read_ch4_cmd then
              next_state <= ck_adc_read_ch4_state;

            elsif regAddr = ck_adc_read_ch5_cmd then
              next_state <= ck_adc_read_ch5_state;

            elsif regAddr = ck_adc_read_ch6_cmd then
              next_state <= ck_adc_read_ch6_state;

            elsif regAddr = ck_adc_read_ch7_cmd then
              next_state <= ck_adc_read_ch7_state;

            elsif regAddr = ccd1_adc_read_ch0_cmd then
              next_state <= ccd1_adc_read_ch0_state;

            elsif regAddr = ccd1_adc_read_ch1_cmd then
              next_state <= ccd1_adc_read_ch1_state;

            elsif regAddr = ccd1_adc_read_ch2_cmd then
              next_state <= ccd1_adc_read_ch2_state;

            elsif regAddr = ccd1_adc_read_ch3_cmd then
              next_state <= ccd1_adc_read_ch3_state;

            elsif regAddr = ccd1_adc_read_ch4_cmd then
              next_state <= ccd1_adc_read_ch4_state;

            elsif regAddr = ccd1_adc_read_ch5_cmd then
              next_state <= ccd1_adc_read_ch5_state;

            elsif regAddr = ccd1_adc_read_ch6_cmd then
              next_state <= ccd1_adc_read_ch6_state;

            elsif regAddr = ccd1_adc_read_ch7_cmd then
              next_state <= ccd1_adc_read_ch7_state;

            elsif regAddr = ccd2_adc_read_ch0_cmd then
              next_state <= ccd2_adc_read_ch0_state;

            elsif regAddr = ccd2_adc_read_ch1_cmd then
              next_state <= ccd2_adc_read_ch1_state;

            elsif regAddr = ccd2_adc_read_ch2_cmd then
              next_state <= ccd2_adc_read_ch2_state;

            elsif regAddr = ccd2_adc_read_ch3_cmd then
              next_state <= ccd2_adc_read_ch3_state;

            elsif regAddr = ccd2_adc_read_ch4_cmd then
              next_state <= ccd2_adc_read_ch4_state;

            elsif regAddr = ccd2_adc_read_ch5_cmd then
              next_state <= ccd2_adc_read_ch5_state;

            elsif regAddr = ccd2_adc_read_ch6_cmd then
              next_state <= ccd2_adc_read_ch6_state;

            elsif regAddr = ccd2_adc_read_ch7_cmd then
              next_state <= ccd2_adc_read_ch7_state;

                                        --------DREB 1wire serial number                       
                                        -- DREB serial number word 0 read
            elsif regAddr = dreb_sn_read_w0_cmd then
              next_state <= dreb_sn_read_w0_state;

                                        -- DREB serial number word 1 read
            elsif regAddr = dreb_sn_read_w1_cmd then
              next_state <= dreb_sn_read_w1_state;

                                        --------REB 1wire serial number                        
                                        -- REB serial number word 0 read
            elsif regAddr = reb_sn_read_w0_cmd then
              next_state <= reb_sn_read_w0_state;

                                        -- REB serial number word 1 read
            elsif regAddr = reb_sn_read_w1_cmd then
              next_state <= reb_sn_read_w1_state;

                                        --------CCD clock enable read                        
                                        -- CCD clock enable read
            elsif regAddr = ccd_clk_en_cmd then
              next_state <= ccd_clk_en_rd;

                                        --------ASPIC reference enable read                        
                                        -- ASPIC reference enable read
            elsif regAddr = aspic_ref_en_cmd then
              next_state <= aspic_ref_en_rd;

                                        --------ASPIC 5V enable read                        
                                        -- ASPIC 5V enable read
            elsif regAddr = aspic_5v_en_cmd then
              next_state <= aspic_5v_en_rd;

                                        --------CABAC regulators enable read                   
                                        -- CABAC regulators enable read
            elsif regAddr = CABAC_reg_en_cmd then
              next_state <= CABAC_reg_en_rd;


                                        --------back bias switch read          
                                        -- back bias switch read
            elsif regAddr = back_bias_sw_cmd then
              next_state <= back_bias_sw_read_state;

              ---------- Remote Update read status register
            elsif regAddr = ru_status_read_cmd then
              next_state <= remote_update_rd_status_state;

            elsif regAddr = start_multiboot_cmd then
              next_state <= reboot_status_rd_state;

-- ERROR                                                        
            else
              next_state   <= error_state;
              next_regFail <= '1';
              next_regAck  <= '1';
            end if;
          else

------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------  WRITE --------------------------------------------------------                                                        
------------------------------------------------------------------------------------------------------------------------

---------- Base Register Set write

                                        -- TIME BASE SET lsw 
            if regAddr = time_base_lsw_cmd then
              next_state                    <= time_base_set_lsw;
              next_load_time_base_lsw       <= '1';
              next_cnt_preset(31 downto 0)  <= regDataWr_masked;
              next_cnt_preset(63 downto 32) <= (others => '0');

                                                  -- TIME BASE SET MSW 
            elsif regAddr = time_base_MSW_cmd then
              next_state                    <= time_base_set_MSW;
              next_load_time_base_MSW       <= '1';
              next_cnt_preset(31 downto 0)  <= (others => '0');
              next_cnt_preset(63 downto 32) <= regDataWr_masked;
                                                  -- TRIGGER SET 
            elsif regAddr = trigger_set_cmd then  -- trigger
              next_state           <= trigger_state;
              next_trigger_ce_bus  <= regWrEn;
              next_trigger_val_bus <= regDataWr_masked;

---------- Sync Commands 
              -- sync command 0 delay set
            elsif regAddr = sync_cmd_delay_cmd then
              next_state             <= sync_cmd_delay_wr_state;
              next_sync_cmd_delay_en <= '1';

---------- Image Parameters Write

                                        -- image size write                                                     
            elsif regAddr = image_size_cmd then
              next_state         <= set_image_size_state;
              next_image_size_en <= '1';

              -- Image Patter Generator enable (1 = ON)                                                 
            elsif regAddr = image_patter_mode_cmd then
              next_state            <= set_img_pattern_gen_state;
              next_image_pattern_en <= '1';

                                        -- CCD selector enable (CCD 1 = lsb)                                                    
            elsif regAddr = ccd_sel_cmd then
              next_state      <= set_ccd_sel_state;
              next_ccd_sel_en <= '1';

---------- Sequencer Parameters Write

                                        -- function time write          
            elsif ((regAddr >= func_time_set_base_0) and (regAddr <= func_time_set_high_0)) or
              ((regAddr >= func_time_set_base_1) and (regAddr <= func_time_set_high_1))
            then
              next_state <= func_time_wr;
              if regAddr(12) = '0' then
                next_seq_0_time_mem_w_en <= '1';
              else
                next_seq_1_time_mem_w_en <= '1';
              end if;

                                        -- function outputs write
            elsif ((regAddr >= func_out_set_base_0) and (regAddr <= func_out_set_high_0)) or
              ((regAddr >= func_out_set_base_1) and (regAddr <= func_out_set_high_1))
            then
              next_state <= func_output_wr;
              if regAddr(12) = '0' then
                next_seq_0_out_mem_w_en <= '1';
              else
                next_seq_1_out_mem_w_en <= '1';
              end if;

                                        -- program memory write                 
            elsif ((regAddr >= prog_mem_base_0) and (regAddr <= prog_mem_high_0)) or
              ((regAddr >= prog_mem_base_1) and (regAddr <= prog_mem_high_1))
            then
              next_state <= seq_prog_mem_wr;
              if regAddr(12) = '0' then
                next_seq_0_prog_mem_w_en <= '1';
              else
                next_seq_1_prog_mem_w_en <= '1';
              end if;

                                        -- sequencer step                       
            elsif regAddr = seq_step_cmd_0 or regAddr = seq_step_cmd_1 then
              next_state <= seq_step_state;
              if regAddr(12) = '0' then
                next_seq_0_step <= '1';
              else
                next_seq_1_step <= '1';
              end if;

                                        -- sequencer stop
            elsif regAddr = func_stop_cmd_0 or regAddr = func_stop_cmd_1 then
              next_state <= seq_stop_state;
              if regAddr(12) = '0' then
                next_seq_0_stop <= '1';
              else
                next_seq_1_stop <= '1';
              end if;

                                        -- enable video ADC conv shift
            elsif regAddr = enable_conv_shift_cmd_0 or regAddr = enable_conv_shift_cmd_1 then
              next_state <= enable_conv_shift_state;
              if regAddr(12) = '0' then
                next_seq_0_enable_conv_shift <= '1';
              else
                next_seq_1_enable_conv_shift <= '1';
              end if;

                                        -- initialize video ADC conv shift
            elsif regAddr = init_conv_shift_cmd_0 or regAddr = init_conv_shift_cmd_1 then
              next_state <= init_conv_shift_state;
              if regAddr(12) = '0' then
                next_seq_0_init_conv_shift <= '1';
              else
                next_seq_1_init_conv_shift <= '1';
              end if;

                                        -- indirect memory write                        
            elsif regAddr = start_add_cmd_0 or regAddr = start_add_cmd_1 then
              next_state <= enable_start_add_prog_mem_state;
              if regAddr(12) = '0' then
                next_seq_0_start_add_prog_mem_en <= '1';
              else
                next_seq_1_start_add_prog_mem_en <= '1';
              end if;
              
            elsif ((regAddr >= seq_ind_func_mem_base_0) and (regAddr <= seq_ind_func_mem_high_0)) or
              ((regAddr >= seq_ind_func_mem_base_1) and (regAddr <= seq_ind_func_mem_high_1))
            then
              next_state <= seq_ind_func_mem_we_state;
              if regAddr(12) = '0' then
                next_seq_0_ind_func_mem_we <= '1';
              else
                next_seq_1_ind_func_mem_we <= '1';
              end if;
              
            elsif ((regAddr >= seq_ind_rep_mem_base_0) and (regAddr <= seq_ind_rep_mem_high_0)) or
              ((regAddr >= seq_ind_rep_mem_base_1) and (regAddr <= seq_ind_rep_mem_high_1))
            then
              next_state <= seq_ind_rep_mem_we_state;
              if regAddr(12) = '0' then
                next_seq_0_ind_rep_mem_we <= '1';
              else
                next_seq_1_ind_rep_mem_we <= '1';
              end if;
              
            elsif ((regAddr >= seq_ind_sub_add_mem_base_0) and (regAddr <= seq_ind_sub_add_mem_high_0)) or
              ((regAddr >= seq_ind_sub_add_mem_base_1) and (regAddr <= seq_ind_sub_add_mem_high_1))
            then
              next_state <= seq_ind_sub_add_mem_we_state;
              if regAddr(12) = '0' then
                next_seq_0_ind_sub_add_mem_we <= '1';
              else
                next_seq_1_ind_sub_add_mem_we <= '1';
              end if;
              
            elsif ((regAddr >= seq_ind_sub_rep_mem_base_0) and (regAddr <= seq_ind_sub_rep_mem_high_0)) or
              ((regAddr >= seq_ind_sub_rep_mem_base_1) and (regAddr <= seq_ind_sub_rep_mem_high_1))
            then
              next_state <= seq_ind_sub_rep_mem_we_state;
              if regAddr(12) = '0' then
                next_seq_0_ind_sub_rep_mem_we <= '1';
              else
                next_seq_1_ind_sub_rep_mem_we <= '1';
              end if;

              -- op code error reset
            elsif regAddr = seq_op_code_error_reset_cmd_0 or regAddr = seq_op_code_error_reset_cmd_1 then
              next_state <= seq_op_code_error_reset_state;
              if regAddr(12) = '0' then
                next_seq_0_op_code_error_reset <= '1';
              else
                next_seq_1_op_code_error_reset <= '1';
              end if;

---------- CABAC Parameters Write
              -- CABAC start trans                                                                                                              
              --elsif regAddr = cabac_start_trans_cmd then
              --  next_state             <= cabac_start_trans_state;
              --  next_cabac_start_trans <= '1';

              --  -- CABAC start reset                                                                                                              
              --elsif regAddr = cabac_start_reset_cmd then
              --  next_state             <= cabac_start_reset_state;
              --  next_cabac_start_reset <= '1';

---------- ASPIC Parameters Write
              -- ASPIC start trans                                                                                                              
            elsif regAddr = aspic_start_trans_cmd then
              next_state             <= aspic_start_trans_state;
              next_aspic_start_trans <= '1';

              -- ASPIC start reset                                                                                                              
            elsif regAddr = aspic_start_reset_cmd then
              next_state             <= aspic_start_reset_state;
              next_aspic_start_reset <= '1';

              -- ASPIC set nap mode
            elsif regAddr = aspic_nap_mode_cmd then
              next_state             <= set_aspic_nap_mode_state;
              next_aspic_nap_mode_en <= '1';


---------- CCD clock rails DAC
              -- start write config
            elsif regAddr = clk_rail_load_config_cmd then
              next_state               <= clk_rail_load_config_state;
              next_clk_rail_load_start <= '1';
                                        -- start send LDAC
            elsif regAddr = clk_rail_ldac_cmd then
              next_state               <= clk_rail_ldac_state;
              next_clk_rail_ldac_start <= '1';

---------- CABAC bias DAC
              -- start write config
            elsif regAddr = c_bias_load_config_cmd then
              next_state             <= c_bias_load_config_state;
              next_c_bias_load_start <= '1';
                                        -- start send LDAC
            elsif regAddr = c_bias_ldac_cmd then
              next_state             <= c_bias_ldac_state;
              next_c_bias_ldac_start <= '1';

---------- ASPIC temp and voltage monitor
            elsif regAddr = aspic_t_v_start_r_cmd then
              next_state             <= aspic_t_v_start_r_state;
              next_aspic_t_v_start_r <= '1';

---------- CCD temperature
              -- start procedure
            elsif regAddr = ccd_temp_start_cmd then
              next_state          <= ccd_temp_start_state;
              next_ccd_temp_start <= '1';

            elsif regAddr = ccd_temp_start_reset_cmd then
              next_state                <= ccd_temp_start_reset_state;
              next_ccd_temp_start_reset <= '1';

---------- slow adcs
            elsif regAddr = slow_adc_start_read_cmd then
              next_state               <= slow_adc_start_read_state;
              next_slow_adc_start_read <= '1';

            elsif regAddr = slow_adc_start_write_cmd then
              next_state                <= slow_adc_start_write_state;
              next_slow_adc_start_write <= '1';

---------- DREB 1wire serial number                                                     
              -- DREB 1wire serial number start acq                                                                                                          
            elsif regAddr = dreb_sn_acq_cmd then
              next_state              <= dreb_sn_acq_state;
              next_dreb_onewire_reset <= '1';

---------- REB 1wire serial number                                                      
              -- REB 1wire serial number start acq                                                                                                           
            elsif regAddr = reb_sn_acq_cmd then
              next_state             <= reb_sn_acq_state;
              next_reb_onewire_reset <= '1';

---------- CCD clock enable                                                   
            elsif regAddr = ccd_clk_en_cmd then
              next_state      <= ccd_clk_en_state;
              next_ccd_clk_en <= '1';

---------- ASPIC reference enable                                                   
            elsif regAddr = aspic_ref_en_cmd then
              next_state        <= aspic_ref_en_state;
              next_aspic_ref_en <= '1';

--------- ASPIC 5V enable                                                   
            elsif regAddr = aspic_5v_en_cmd then
              next_state       <= aspic_5v_en_state;
              next_aspic_5v_en <= '1';


---------- CABAC regulators enable                                                      
            elsif regAddr = CABAC_reg_en_cmd then
              next_state        <= CABAC_reg_en_state;
              next_CABAC_reg_en <= '1';

---------- Back bias switch enable                                                      
            elsif regAddr = back_bias_sw_cmd then
              next_state           <= back_bias_sw_set_state;
              next_en_back_bias_sw <= '1';

---------- multiboot                                                    
            elsif regAddr = start_multiboot_cmd then
              next_state           <= start_multiboot_state;
              next_start_multiboot <= '1';

---------- remote update                                                   
            elsif regAddr = ru_start_cmd then
              next_state               <= start_remote_update_state;
              next_start_remote_update <= '1';

            elsif regAddr = ru_bitstream_we_cmd then
              if remote_update_fifo_full = '0' then
                next_state                    <= remote_update_bitstrm_we_state;
                next_remote_update_bitstrm_we <= '1';
              else
                next_state   <= error_state;
                next_regFail <= '1';
                next_regAck  <= '1';
              end if;

            elsif regAddr = ru_bitstream_daq_done_cmd then
              next_state                  <= remote_update_daq_done_state;
              next_remote_update_daq_done <= '1';

---------- ERROR                                                                                                        
            else
              next_state   <= error_state;
              next_regFail <= '1';
              next_regAck  <= '1';
            end if;
          end if;
        end if;





------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------  CMD EXECUTION ------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

---------------------- BASE REGISTER SET READ  --------------------------
        -- SCHEMA (add 0)               
      when schema =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= schema_value;

        -- HDL VERSION (add 1)
      when hdl_version =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= version_dev_level & x"1" & LSST_SCI_VERSION(7 downto 0) & REB_vhdl_version;
--                      next_regDataRd                          <= version_dev_level & x"01E" & REB_vhdl_version;       
        -- SCI ID (add 2)
      when SCI_ID =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= x"0000_00" & Switch_addr;
        -- RESERVED 1 (add3)
      when reserved_1 =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= reserved_1_value;
        -- TIME BASE READ lsw (add4)
      when time_base_read_lsw =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= time_base_actual_value(31 downto 0);
        -- TIME BASE READ MSW (add5)
      when time_base_read_MSW =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= time_base_actual_value(63 downto 32);
        -- RESERVED 2 (add 6)
      when reserved_2 =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= reserved_2_value;
        -- RESERVED 3 (add 7)           
      when reserved_3 =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= reserved_3_value;
        -- STATE (add 8)        
      when state_busy =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= busy_bus;
        -- TRIGGER TIME READ SB lsw  (addA)
      when trigger_time_SB_lsw =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= trig_tm_value_SB(31 downto 0);
        -- TRIGGER TIME READ SB MSW  (addB)
      when trigger_time_SB_MSW =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= trig_tm_value_SB(63 downto 32);
        -- TRIGGER TIME READ TB lsw  (addC)
      when trigger_time_TB_lsw =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= trig_tm_value_TB(31 downto 0);
        -- TRIGGER TIME READ TB LSW  (addD)
      when trigger_time_TB_MSW =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= trig_tm_value_TB(63 downto 32);
        -- TRIGGER TIME READ seq lsw  (addE)
      when trigger_time_seq_lsw =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= trig_tm_value_seq(31 downto 0);
        -- TRIGGER TIME READ seq MSW  (addF)
      when trigger_time_seq_MSW =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= trig_tm_value_seq(63 downto 32);


        -- TRIGGER TIME READ V_I lsw  (add10)
      when trigger_time_V_I_lsw =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= trig_tm_value_V_I(31 downto 0);
        -- TRIGGER TIME READ V_I MSW  (add11)
      when trigger_time_V_I_MSW =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= trig_tm_value_V_I(63 downto 32);
        -- TRIGGER TIME READ pcb temp lsw  (add12)
      when trigger_time_pcb_t_lsw =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= trig_tm_value_pcb_t(31 downto 0);
        -- TRIGGER TIME READ pcb temp MSW  (add13)
      when trigger_time_pcb_t_MSW =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= trig_tm_value_pcb_t(63 downto 32);
        --  -- TRIGGER TIME READ fast ADC lsw  (add14)
        --when trig_tm_value_f_adc_lsw =>
        --  next_state     <= wait_end_cmd;
        --  next_regAck    <= '1';
        --  next_regDataRd <= trig_tm_value_f_adc(31 downto 0);
        --  -- TRIGGER TIME READ fast ADC MSW  (add15)
        --when trig_tm_value_f_adc_MSW =>
        --  next_state     <= wait_end_cmd;
        --  next_regAck    <= '1';
        --  next_regDataRd <= trig_tm_value_f_adc(63 downto 32);
        -- READ Voltage OK state   (add100)
      when v_ok_state =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= x"0000000" & Mgt_avcc_ok & Mgt_accpll_ok & Mgt_avtt_ok & V3_3v_ok;
        -- immage size read (add 400005)                
      when read_image_size_state =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= image_size;

        -- Sync command 0 delay
      when sync_cmd_delay_rd_state =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= x"000000"&sync_cmd_delay_read;

        -- image patter on read (add 400006)    
      when read_image_patter_mode_state =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= x"0000000" & "000" & image_patter_read;

        -- CCD selector read (add 400007)       
      when read_ccd_sel_state =>
        next_state     <= wait_end_cmd;
        next_regAck    <= '1';
        next_regDataRd <= x"0000000" & '0' & ccd_sel_read;



        -- status block read  
      when statusReg_rd =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= statusReg;
        next_regAck    <= '1';

---------------------- BASE REGISTER SET WRITE  --------------------------

        -- TIME BASE lsw write (add4) 
      when time_base_set_lsw =>
        next_state <= ack_del_1;

        -- TIME BASE MSW write (add5)
      when time_base_set_MSW =>
        next_state <= ack_del_1;

        -- TRIGGER write (add 9)
      when trigger_state =>
        next_state <= ack_del_1;

        -- sync command 0 delay set
      when sync_cmd_delay_wr_state =>
        next_state <= ack_del_1;

---------------------- Image Parameters Write --------------------------

        -- write the image size register 
      when set_image_size_state =>
        next_state <= ack_del_1;

        -- enables the image patter generator
      when set_img_pattern_gen_state =>
        next_state <= ack_del_1;

        -- enables the CCD selector register
      when set_ccd_sel_state =>
        next_state <= ack_del_1;

---------------------- Sequencer Parameters Write/Read --------------------------

        -- write function output state
      when func_output_wr =>
        next_state <= ack_del_1;

        -- write function output state
      when func_time_wr =>
        next_state <= ack_del_1;

        -- write program memory state
      when seq_prog_mem_wr =>
        next_state <= ack_del_1;

        -- sequencer step state
      when seq_step_state =>
        next_state <= ack_del_1;

        -- sequencer stop state
      when seq_stop_state =>
        next_state <= ack_del_1;

        -- enable video ADC conv state
      when enable_conv_shift_state =>
        next_state <= ack_del_1;

        -- initialize video ADC conv state
      when init_conv_shift_state =>
        next_state <= ack_del_1;

        -- write program start address
      when enable_start_add_prog_mem_state =>
        next_state <= ack_del_1;

        -- write indirect function mem
      when seq_ind_func_mem_we_state =>
        next_state <= ack_del_1;

        -- write indirect function repetition mem
      when seq_ind_rep_mem_we_state =>
        next_state <= ack_del_1;

        -- write indirect subrutine mem
      when seq_ind_sub_add_mem_we_state =>
        next_state <= ack_del_1;

        -- write indirect subrutine rep mem
      when seq_ind_sub_rep_mem_we_state =>
        next_state <= ack_del_1;

        -- reset op code flag
      when seq_op_code_error_reset_state =>
        next_state <= ack_del_1;



        -- sequencer time memory read           
      when seq_func_time_rd =>
        if regAddr(12) = '0' then
          next_regDataRd(15 downto 0) <= seq_0_time_mem_readbk;
        else
          next_regDataRd(15 downto 0) <= seq_1_time_mem_readbk;
        end if;
        next_state                   <= wait_end_cmd;
        next_regDataRd(31 downto 16) <= x"0000";
        next_regAck                  <= '1';

        -- sequencer output memory read         
      when seq_func_out_rd =>
        if regAddr(12) = '0' then
          next_regDataRd <= seq_0_out_mem_readbk;
        else
          next_regDataRd <= seq_1_out_mem_readbk;
        end if;
        next_state  <= wait_end_cmd;
        next_regAck <= '1';

        -- sequencer program memory read                
      when seq_prog_mem_rd =>
        if regAddr(12) = '0' then
          next_regDataRd <= seq_0_prog_mem_readbk;
        else
          next_regDataRd <= seq_1_prog_mem_readbk;
        end if;
        next_state  <= wait_end_cmd;
        next_regAck <= '1';

        -- enable video ADC conv shift read             
      when enable_conv_shift_rd =>
        if regAddr(12) = '0' then
          next_regDataRd <= x"0000000" & "000" & seq_0_enable_conv_shift_in;
        else
          next_regDataRd <= x"0000000" & "000" & seq_1_enable_conv_shift_in;
        end if;
        next_state  <= wait_end_cmd;
        next_regAck <= '1';

        -- program memory init address read             
      when start_add_prog_mem_rd_state =>
        if regAddr(12) = '0' then
          next_regDataRd <= x"00000" & "00" & seq_0_start_add_prog_mem_rbk;
        else
          next_regDataRd <= x"00000" & "00" & seq_1_start_add_prog_mem_rbk;
        end if;
        next_state  <= wait_end_cmd;
        next_regAck <= '1';

        -- indirect functions mem read          
      when seq_ind_func_mem_rdbk_state =>
        if regAddr(12) = '0' then
          next_regDataRd <= x"0000000" & seq_0_ind_func_mem_rdbk;
        else
          next_regDataRd <= x"0000000" & seq_1_ind_func_mem_rdbk;
        end if;
        next_state  <= wait_end_cmd;
        next_regAck <= '1';

        -- indirect function repetitons mem read                
      when seq_ind_rep_mem_rdbk_state =>
        if regAddr(12) = '0' then
          next_regDataRd <= x"00" & seq_0_ind_rep_mem_rdbk;
        else
          next_regDataRd <= x"00" & seq_1_ind_rep_mem_rdbk;
        end if;
        next_state  <= wait_end_cmd;
        next_regAck <= '1';

        -- indirect subrutine address mem read          
      when seq_ind_sub_add_mem_rdbk_state =>
        if regAddr(12) = '0' then
          next_regDataRd <= x"00000" & "00" & seq_0_ind_sub_add_mem_rdbk;
        else
          next_regDataRd <= x"00000" & "00" & seq_1_ind_sub_add_mem_rdbk;
        end if;
        next_state  <= wait_end_cmd;
        next_regAck <= '1';

        -- indirect subrutine repetition mem read               
      when seq_ind_sub_rep_mem_rdbk_state =>
        if regAddr(12) = '0' then
          next_regDataRd <= x"0000" & seq_0_ind_sub_rep_mem_rdbk;
        else
          next_regDataRd <= x"0000" & seq_1_ind_sub_rep_mem_rdbk;
        end if;
        next_state  <= wait_end_cmd;
        next_regAck <= '1';

        --op code error flag read       
      when seq_op_code_error_rd_state =>
        if regAddr(12) = '0' then
          next_regDataRd <= "000" & seq_0_op_code_error & x"0000" & "00" & seq_0_op_code_error_add;
        else
          next_regDataRd <= "000" & seq_1_op_code_error & x"0000" & "00" & seq_1_op_code_error_add;
        end if;
        next_state  <= wait_end_cmd;
        next_regAck <= '1';

---------------------- CABAC Parameters Write/Read --------------------------
        -- read CABAC config ccd1
        --when cabac_read_conf_ccd_1_state =>
        --  next_state     <= wait_end_cmd;
        --  next_regDataRd <= x"0000" & cabac_config_r_ccd_1;
        --  next_regAck    <= '1';

        --  -- CABAC start transaction
        --when cabac_start_trans_state =>
        --  if cabac_op_end = '1' then
        --    next_state <= cabac_start_trans_state;
        --  else
        --    next_state <= ack_del_1;
        --  end if;

        --  -- CABAC start reset
        --when cabac_start_reset_state =>
        --  if cabac_op_end = '1' then
        --    next_state <= cabac_start_reset_state;
        --  else
        --    next_state <= ack_del_1;
        --  end if;

---------------------- ASPIC Parameters Write/Read --------------------------
        -- read ASPIC config ccd1
      when aspic_read_conf_ccd_1_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000"&aspic_config_r_ccd_1;
        next_regAck    <= '1';

        -- read ASPIC config ccd2
      when aspic_read_conf_ccd_2_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000"&aspic_config_r_ccd_2;
        next_regAck    <= '1';

        -- read ASPIC config ccd3
      when aspic_read_conf_ccd_3_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000"&aspic_config_r_ccd_3;
        next_regAck    <= '1';

                                        -- read ASPIC nap mode
      when read_aspic_nap_mode_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000000"& "00" & aspic_nap_ccd2_in & aspic_nap_ccd1_in;
        next_regAck    <= '1';

-- following states are necessariy to wait ASPIC spi fsm to start and activate busy                     
        -- ASPIC start transaction
      when aspic_start_trans_state =>
        next_state <= aspic_start_trans_state_1;
        
      when aspic_start_trans_state_1 =>
        next_state <= aspic_start_trans_state_2;
        
      when aspic_start_trans_state_2 =>
        next_state <= aspic_start_trans_state_3;
        
      when aspic_start_trans_state_3 =>
        if aspic_op_end = '1' then
          next_state <= aspic_start_trans_state_3;
        else
          next_state <= ack_del_1;
        end if;

        -- ASPIC start reset
      when aspic_start_reset_state =>
        next_state <= aspic_start_reset_state_1;
        
      when aspic_start_reset_state_1 =>
        next_state <= aspic_start_reset_state_2;
        
      when aspic_start_reset_state_2 =>
        next_state <= aspic_start_reset_state_3;
        
      when aspic_start_reset_state_3 =>
        if aspic_op_end = '1' then
          next_state <= aspic_start_reset_state_3;
        else
          next_state <= ack_del_1;
        end if;

        -- ASPIC set nap mode
      when set_aspic_nap_mode_state =>
        next_state <= ack_del_1;


---------------------- CCD clock rails DAC Write --------------------------

      when clk_rail_load_config_state =>
        next_state <= ack_del_1;

      when clk_rail_ldac_state =>
        next_state <= ack_del_1;

---------------------- CABAC bias DAC Write --------------------------
        
      when c_bias_load_config_state =>
        next_state <= ack_del_1;

      when c_bias_ldac_state =>
        next_state <= ack_del_1;

        -- error and Voltage Under Threshold read
      when c_bias_read_error_vut_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= "0000" & x"0" & "00" & c_bias_v_undr_th & "0000" & x"0" & "00" & c_bias_dac_cmd_err;
        next_regAck    <= '1';

---------------------- DREB voltage and current sensors --------------------------      
        -- V_HTR voltage
      when V_HTR_voltage_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & error_V_HTR_voltage & V_HTR_voltage;
        next_regAck    <= '1';

        -- V_HTR current
      when V_HTR_current_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & error_V_HTR_current & V_HTR_current;
        next_regAck    <= '1';

        -- V_DREB voltage
      when V_DREB_voltage_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & error_V_DREB_voltage & V_DREB_voltage;
        next_regAck    <= '1';

        -- V_DREB current
      when V_DREB_current_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & error_V_DREB_current & V_DREB_current;
        next_regAck    <= '1';

        -- V_CLK_H voltage
      when V_CLK_H_voltage_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & error_V_CLK_H_voltage & V_CLK_H_voltage;
        next_regAck    <= '1';

        -- V_CLK_H current
      when V_CLK_H_current_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & error_V_CLK_H_current & V_CLK_H_current;
        next_regAck    <= '1';

        -- V_ANA voltage
      when V_ANA_voltage_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & error_V_ANA_voltage & V_ANA_voltage;
        next_regAck    <= '1';

        -- V_ANA current
      when V_ANA_current_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & error_V_ANA_current & V_ANA_current;
        next_regAck    <= '1';

        -- V_OD voltage
      when V_OD_voltage_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & error_V_OD_voltage & V_OD_voltage;
        next_regAck    <= '1';

        -- V_OD current
      when V_OD_current_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & error_V_OD_current & V_OD_current;
        next_regAck    <= '1';

---------------------- DREB Temperature sensors --------------------------      
        -- DREB T1 
      when DREB_T1_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & T1_dreb_error & T1_dreb;
        next_regAck    <= '1';

        -- DREB T2
      when DREB_T2_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & T2_dreb_error & T2_dreb;
        next_regAck    <= '1';

---------------------- REB Temperature sensors group 1 --------------------------       
        -- REB T1 gr1 
      when REB_T1_gr1_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & T1_reb_gr1_error & T1_reb_gr1;
        next_regAck    <= '1';

        -- REB T2 gr1
      when REB_T2_gr1_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & T2_reb_gr1_error & T2_reb_gr1;
        next_regAck    <= '1';

        -- REB T3 gr1 
      when REB_T3_gr1_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & T3_reb_gr1_error & T3_reb_gr1;
        next_regAck    <= '1';

        -- REB T4 gr1
      when REB_T4_gr1_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & T4_reb_gr1_error & T4_reb_gr1;
        next_regAck    <= '1';

---------------------- REB Temperature sensors group 2 --------------------------       
        -- REB T1 gr2 
      when REB_T1_gr2_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & T1_reb_gr2_error & T1_reb_gr2;
        next_regAck    <= '1';

        -- REB T2 gr2
      when REB_T2_gr2_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & T2_reb_gr2_error & T2_reb_gr2;
        next_regAck    <= '1';

        -- REB T3 gr2 
      when REB_T3_gr2_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & T3_reb_gr2_error & T3_reb_gr2;
        next_regAck    <= '1';

        -- REB T4 gr2
      when REB_T4_gr2_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & T4_reb_gr2_error & T4_reb_gr2;
        next_regAck    <= '1';

---------------------- REB Temperature sensors group 3 --------------------------       
        -- REB T1 gr3 
      when REB_T1_gr3_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" &"000" & T1_reb_gr3_error & T1_reb_gr3;
        next_regAck    <= '1';

---------------------- ASPIC temp and voltage monitor --------------------------  

      when aspic_t_v_start_r_state =>
        next_state <= aspic_t_v_start_r_state_1;

      when aspic_t_v_start_r_state_1 =>
        if aspic_t_v_busy = '1' then
          next_state <= aspic_t_v_start_r_state_1;
        else
          next_state <= ack_del_1;
        end if;
        
      when aspic_t_v_read_t_top_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= aspic_t_v_data(0);
        next_regAck    <= '1';

      when aspic_t_v_read_t_bot_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= aspic_t_v_data(1);
        next_regAck    <= '1';

      when aspic_t_v_read_2_5_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= aspic_t_v_data(2);
        next_regAck    <= '1';

      when aspic_t_v_read_5_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= aspic_t_v_data(3);
        next_regAck    <= '1';

---------------------- CCD Temperature sensor --------------------------                                
        -- CCD temperature read
      when ccd_temp_read_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"00" & ccd_temp;
        next_regAck    <= '1';

        -- CCD temperature start procedure
      when ccd_temp_start_state =>
        if ccd_temp_busy = '1' then
          next_state <= ccd_temp_start_state;
        else
          next_state <= ack_del_1;
        end if;

      when ccd_temp_start_reset_state =>
        if ccd_temp_busy = '1' then
          next_state <= ccd_temp_start_reset_state;
        else
          next_state <= ack_del_1;
        end if;


---------------------- slow adcs  --------------------------
-- start read 
      when slow_adc_start_read_state =>
        if slow_adc_busy = '1' then
          next_state <= slow_adc_start_read_state;
        else
          next_state <= ack_del_1;
        end if;

        -- start write
      when slow_adc_start_write_state =>
        if slow_adc_busy = '1' then
          next_state <= slow_adc_start_write_state;
        else
          next_state <= ack_del_1;
        end if;

-- CCD1

-- read ch0
      when ccd1_adc_read_ch0_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ccd1_adc_conv_res(0);
        next_regAck    <= '1';

-- read ch1
      when ccd1_adc_read_ch1_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ccd1_adc_conv_res(1);
        next_regAck    <= '1';

-- read ch2
      when ccd1_adc_read_ch2_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ccd1_adc_conv_res(2);
        next_regAck    <= '1';

-- read ch3
      when ccd1_adc_read_ch3_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ccd1_adc_conv_res(3);
        next_regAck    <= '1';

-- read ch4
      when ccd1_adc_read_ch4_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ccd1_adc_conv_res(4);
        next_regAck    <= '1';

-- read ch5
      when ccd1_adc_read_ch5_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ccd1_adc_conv_res(5);
        next_regAck    <= '1';

-- read ch6
      when ccd1_adc_read_ch6_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ccd1_adc_conv_res(6);
        next_regAck    <= '1';

-- read ch7
      when ccd1_adc_read_ch7_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ccd1_adc_conv_res(7);
        next_regAck    <= '1';

-- CCD2

-- read ch0
      when ccd2_adc_read_ch0_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ccd2_adc_conv_res(0);
        next_regAck    <= '1';

-- read ch1
      when ccd2_adc_read_ch1_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ccd2_adc_conv_res(1);
        next_regAck    <= '1';

-- read ch2
      when ccd2_adc_read_ch2_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ccd2_adc_conv_res(2);
        next_regAck    <= '1';

-- read ch3
      when ccd2_adc_read_ch3_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ccd2_adc_conv_res(3);
        next_regAck    <= '1';

-- read ch4
      when ccd2_adc_read_ch4_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ccd2_adc_conv_res(4);
        next_regAck    <= '1';

-- read ch5
      when ccd2_adc_read_ch5_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ccd2_adc_conv_res(5);
        next_regAck    <= '1';

-- read ch6
      when ccd2_adc_read_ch6_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ccd2_adc_conv_res(6);
        next_regAck    <= '1';

-- read ch7
      when ccd2_adc_read_ch7_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ccd2_adc_conv_res(7);
        next_regAck    <= '1';

-- clock rails slow adc  

-- read ch0
      when ck_adc_read_ch0_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ck_adc_conv_res(0);
        next_regAck    <= '1';

-- read ch1
      when ck_adc_read_ch1_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ck_adc_conv_res(1);
        next_regAck    <= '1';

-- read ch2
      when ck_adc_read_ch2_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ck_adc_conv_res(2);
        next_regAck    <= '1';

-- read ch3
      when ck_adc_read_ch3_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ck_adc_conv_res(3);
        next_regAck    <= '1';

-- read ch4
      when ck_adc_read_ch4_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ck_adc_conv_res(4);
        next_regAck    <= '1';

-- read ch5
      when ck_adc_read_ch5_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ck_adc_conv_res(5);
        next_regAck    <= '1';

-- read ch6
      when ck_adc_read_ch6_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ck_adc_conv_res(6);
        next_regAck    <= '1';

-- read ch7
      when ck_adc_read_ch7_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"0000" & ck_adc_conv_res(7);
        next_regAck    <= '1';

---------------------- DREB 1wire serial number --------------------------                              
-- DREB 1wire serial number acq
      when dreb_sn_acq_state =>
        --if dreb_sn_crc_ok = '0' and dreb_sn_dev_error = '0' and dreb_sn_timeout = '0' then
        --  next_state              <= dreb_sn_acq_state;
        next_dreb_onewire_reset <= '0';
        --    else
        next_state              <= ack_del_1;
        --    end if;

-- DREB 1wire serial number read w 0            
      when dreb_sn_read_w0_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= dreb_sn(31 downto 0);
        next_regAck    <= '1';

-- DREB 1wire serial number read w 1            
      when dreb_sn_read_w1_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" & '0' & dreb_sn_timeout & dreb_sn_dev_error & dreb_sn_crc_ok & dreb_sn(47 downto 32);
        next_regAck    <= '1';

---------------------- REB 1wire serial number --------------------------                               
-- REB 1wire serial number acq
      when reb_sn_acq_state =>
        --if reb_sn_crc_ok = '0' and reb_sn_dev_error = '0' and reb_sn_timeout = '0' then
        --  next_state             <= reb_sn_acq_state;
        next_reb_onewire_reset <= '0';
        --   else
        next_state             <= ack_del_1;
        --   end if;

-- REB 1wire serial number read w 0             
      when reb_sn_read_w0_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= reb_sn(31 downto 0);
        next_regAck    <= '1';

-- REB 1wire serial number read w 1             
      when reb_sn_read_w1_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= x"000" & '0' & reb_sn_timeout & reb_sn_dev_error & reb_sn_crc_ok & reb_sn(47 downto 32);
        next_regAck    <= '1';

---------------------- CCD clock enable --------------------------                            
-- CCD clock enable read      
      when ccd_clk_en_rd =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= X"0000000" & "00" & ccd2_clk_en_in & ccd1_clk_en_in;
        next_regAck    <= '1';

        -- enable CCD clock
      when ccd_clk_en_state =>
        next_state <= ack_del_1;

---------------------- ASPIC reference enable --------------------------                            
-- ASPIC reference enable read      
      when aspic_ref_en_rd =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= X"0000000" & "00" & aspic_ref_en_in_ccd2 & aspic_ref_en_in_ccd1;
        next_regAck    <= '1';

        -- enable ASPIC reference
      when aspic_ref_en_state =>
        next_state <= ack_del_1;

---------------------- ASPIC 5V enable --------------------------                            
-- ASPIC 5V enable read      
      when aspic_5v_en_rd =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= X"0000000" & "00" & aspic_5v_en_in_ccd2 & aspic_5v_en_in_ccd1;
        next_regAck    <= '1';

        -- enable ASPIC reference
      when aspic_5v_en_state =>
        next_state <= ack_del_1;

---------------------- CABAC regulators enable --------------------------                               
-- CABAC regulators enable read 
      when CABAC_reg_en_rd =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= X"000000" & "000" & CABAC_reg_in;
        next_regAck    <= '1';

        -- enable CABAC regulators
      when CABAC_reg_en_state =>
        next_state <= ack_del_1;

---------------------- Back bias switch enable --------------------------                               
-- Back bias enable read        
      when back_bias_sw_read_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= X"0000000" & '0' & back_bias_sw_error & back_bias_cl_rb & back_bias_sw_rb;
        next_regAck    <= '1';

        -- enable DC/DC clock
      when back_bias_sw_set_state =>
        next_state <= ack_del_1;

---------------------- Multiboot --------------------------                             
        -- start multiboot
      when start_multiboot_state =>
        next_state <= ack_del_1;

---------------------- Remote Update --------------------------                             

        -- start remote update
      when start_remote_update_state =>
        next_state <= ack_del_1;

      when remote_update_bitstrm_we_state =>
        next_state <= ack_del_1;

      when remote_update_daq_done_state =>
        next_state <= ack_del_1;

      when remote_update_rd_status_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= X"0000" & remote_update_status_reg;
        next_regAck    <= '1';

      when reboot_status_rd_state =>
        next_state     <= wait_end_cmd;
        next_regDataRd <= remote_update_reboot_status;
        next_regAck    <= '1';

---------------------- WAIT END CMD  --------------------------
        
      when wait_end_cmd =>
        if regReq = '1' then
          next_state <= wait_end_cmd;
        else
          next_state <= wait_cmd;
        end if;


---------------------- delay for ACK --------------------------
      when ack_del_1 =>
        next_state <= ack_del_2;
      when ack_del_2 =>
        next_state  <= wait_end_cmd;
        next_regAck <= '1';

--------------------------------------------------------   error detected --------------------------------------------------------  
        
      when error_state =>
        if regReq = '1' then
          next_state <= error_state;
        else
          next_state <= wait_cmd;
        end if;
        
    end case;
  end process;

end Behavioral;

