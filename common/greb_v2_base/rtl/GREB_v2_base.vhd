library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.std_logic_misc.all;

library UNISIM;
use UNISIM.VComponents.all;

library surf;
use surf.StdRtlPkg.all;

library lsst_sci;
use lsst_sci.LsstSciPackage.all;

library lsst_reb;
use lsst_reb.reb_config_pkg.all;
use lsst_reb.basic_elements_pkg.all;
use lsst_reb.SequencerPkg.all;

library common;
use common.GREB_v2_commands_package.all;
use common.GREB_v2_pkg.all;

entity GREB_v2_base is
  generic (
    BUILD_INFO_G : BuildInfoType;
    CONFIG_G     : RebConfigType
  );
  port (
    ------ Clock signals ------
    -- PGP serdes clk
    PgpRefClk_P : in    std_logic;
    PgpRefClk_M : in    std_logic;

    ------ PGP signals ------
    PgpRx_P : in    std_logic_vector(1 downto 0);
    PgpRx_M : in    std_logic_vector(1 downto 0);
    PgpTx_P : out   std_logic_vector(1 downto 0);
    PgpTx_M : out   std_logic_vector(1 downto 0);

    ------ CCD -----
    -- CCD ADC
    adc_data_ccd    : in    Slv16Array(NUM_SENSORS_C-1 downto 0);
    adc_cnv_ccd     : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    adc_sck_ccd     : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    adc_buff_pd_ccd : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);

    -- ASPIC signals
    ASPIC_r_up_ccd_p   : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ASPIC_r_up_ccd_n   : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ASPIC_r_down_ccd_p : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ASPIC_r_down_ccd_n : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ASPIC_clamp_ccd_p  : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ASPIC_clamp_ccd_n  : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ASPIC_reset_ccd_p  : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ASPIC_reset_ccd_n  : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);

    -- CCD Clocks signals
    par_clk_ccd_p    : out   Slv4Array(NUM_SENSORS_C-1 downto 0);
    par_clk_ccd_n    : out   Slv4Array(NUM_SENSORS_C-1 downto 0);
    ser_clk_ccd_p    : out   Slv3Array(NUM_SENSORS_C-1 downto 0);
    ser_clk_ccd_n    : out   Slv3Array(NUM_SENSORS_C-1 downto 0);
    reset_gate_ccd_p : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    reset_gate_ccd_n : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);

    ---- ASPICs SPI link ----
    -- ASPIC control signals
    ASPIC_spi_mosi_ccd   : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ASPIC_spi_sclk_ccd   : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ASPIC_spi_miso_t_ccd : in    std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ASPIC_spi_miso_b_ccd : in    std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ASPIC_ss_t_ccd       : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ASPIC_ss_b_ccd       : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ASPIC_spi_reset_ccd  : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ASPIC_nap_ccd        : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);

    -- backbias sw
    backbias_clamp : out   std_logic;
    backbias_ssbe  : out   std_logic;

    -- CABAC pulse
    pulse_ccd_p : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    pulse_ccd_n : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);

    ------ REB V & I sensors ------
    LTC2945_SCL : inout std_logic;
    LTC2945_SDA : inout std_logic;

    ------ Temperature ------
    -- DREB PCB temperature
    DREB_temp_sda : inout std_logic;
    DREB_temp_scl : inout std_logic;

    -- board temp ADC
    Temp_adc_scl_ccd : inout std_logic_vector(NUM_SENSORS_C-1 downto 0);
    Temp_adc_sda_ccd : inout std_logic_vector(NUM_SENSORS_C-1 downto 0);

    -- CCD temperatures
    csb_24ADC  : out   std_logic;
    sclk_24ADC : out   std_logic;
    din_24ADC  : out   std_logic;
    dout_24ADC : in    std_logic;

    -- ASPICs temp and voltage ADC
    aspic_t_v_miso    : in    std_logic;
    aspic_t_v_mosi    : out   std_logic;
    aspic_t_v_ss_ccd  : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    aspic_t_v_sclk    : out   std_logic;

    ------ DACs ------
    -- cabac clock rails DAC
    ldac_RAILS      : out   std_logic;
    din_RAILS       : out   std_logic;
    sclk_RAILS      : out   std_logic;
    sync_RAILS_dac  : out   std_logic_vector(1 downto 0);

    -- CCD BIAS
    ldac_C_BIAS : out   std_logic;
    din_C_BIAS  : out   std_logic;
    sync_C_BIAS : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    sclk_C_BIAS : out   std_logic;

    -- max 11056 slow adc
    ck_adc_EOC                 : in    std_logic;
    ccd_adc_EOC                : in    std_logic_vector(NUM_SENSORS_C-1 downto 0);
    slow_adc_data_from_adc_dcr : inout std_logic_vector(3 downto 0);
    slow_adc_data_from_adc     : in    std_logic_vector(15 downto 4);
    ck_adc_CS                  : out   std_logic;
    ccd_adc_CS                 : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    slow_adc_RD                : out   std_logic;
    slow_adc_WR                : out   std_logic;
    ck_adc_CONVST              : out   std_logic;
    ccd_adc_CONVST             : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ck_adc_SHDN                : out   std_logic;
    ccd_adc_SHDN               : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);

    ------ Remote Update ------
    ru_outSpiCsB   : out   std_logic;
    ru_outSpiMosi  : out   std_logic;
    ru_inSpiMiso   : in    std_logic;
    ru_outSpiWpB   : out   std_logic;     -- SPI flash write protect
    ru_outSpiHoldB : out   std_logic;

    ------ MISC ------
    -- Resistors
    r_add : in    std_logic_vector(7 downto 0);

    -- Test port
    TEST : out   std_logic_vector(3 downto 0);

    -- Power ON reset
    Pwron_Rst_L : in    std_logic;

    -- CCD clocks enable
    ccd_clk_en_out_p : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ccd_clk_en_out_n : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);

    -- ASPIC reference power down
    ASPIC_ref_sd_ccd : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ASPIC_5V_sd_ccd  : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);

    -- GPIO power cable
    gpio_0_p   : out   std_logic;
    gpio_0_n   : out   std_logic;
    gpio_0_dir : out   std_logic;
    gpio_1_p   : out   std_logic;
    gpio_1_n   : out   std_logic;
    gpio_1_dir : out   std_logic;

    -- GPIO silver cable
    gpio_2 : out   std_logic;

    -- DREB serial number
    reb_sn_onewire : inout std_logic
  );
end entity GREB_v2_base;

architecture Behavioral of GREB_v2_base is

  -- Config
  constant NUM_SENSORS_C   : integer := 2;
  constant HAS_MULTIBOOT_C : boolean := True;
  constant cfg             : RebConfigType := CONFIG_G;
  constant fwVersion       : std_logic_vector(31 downto 0) := toBuildInfo(BUILD_INFO_G).fwVersion;

  -- Clocks
  signal pgpRefClk       : std_logic;
  signal stable_clk      : std_logic;
  signal stable_rst      : std_logic;
  signal usrClk          : std_logic;
  signal sys_clk         : std_logic;
  signal multiboot_clk   : std_logic;

  -- Reset
  signal n_rst            : std_logic;
  signal usrRst           : std_logic;
  signal sys_rst          : std_logic;
  signal first_reset_done : std_logic;
  signal first_reset      : std_logic;
  signal prev_sys_rst     : std_logic;

  -- SCI signals
  signal pgpLocLinkReady : std_logic;
  signal pgpRemLinkReady : std_logic;
  signal regReq          : std_logic;
  signal regOp           : std_logic;
  signal RegAddr         : std_logic_vector(23 downto 0);
  signal RegDataWr       : std_logic_vector(31 downto 0);
  signal regAck          : std_logic;
  signal regFail         : std_logic;
  signal RegDataRd       : std_logic_vector(31 downto 0);
  signal RegWrEn         : std_logic_vector(31 downto 0);
  signal SCI_DataIn      : LsstSciImageDataArray(2 downto 0) := (others => LSST_SCI_IMAGE_DATA_IN_INIT_C);

  signal StatusAddr : std_logic_vector(23 downto 0);
  signal StatusReg  : std_logic_vector(31 downto 0);
  signal StatusRst  : std_logic;

  -- CMD interpreter signals
  signal regDataWr_masked   : std_logic_vector(31 downto 0);
  signal busy_bus           : std_logic_vector(31 downto 0);
  signal trigger_ce_bus     : std_logic_vector(31 downto 0);
  signal trigger_val_bus    : std_logic_vector(31 downto 0);
  signal load_time_base_lsw : std_logic;
  signal load_time_base_MSW : std_logic;
  signal cnt_preset         : std_logic_vector(63 downto 0);

  -- sync commands signals
  signal sync_cmd_en         : std_logic;
  signal sync_cmd_in         : std_logic_vector(7 downto 0);
  signal sync_cmd_start_seq  : std_logic;
  signal sync_cmd_step_seq   : std_logic;
  signal sync_cmd_stop_seq   : std_logic;
  signal sync_cmd_main_add   : std_logic_vector(4 downto 0);
  signal sync_cmd_delay_en   : std_logic;
  signal sync_cmd_delay_read : std_logic_vector(7 downto 0);

  -- iterrupt signals
  signal interrupt_bus_in  : std_logic_vector(31 downto 0);
  signal mask_bus_in_en    : std_logic;
  signal mask_bus_out      : std_logic_vector(31 downto 0);
  signal interrupt_en_out  : std_logic;
  signal interrupt_bus_out : std_logic_vector(31 downto 0);
  signal interrupt_edge_en : std_logic_vector(31 downto 0);
  signal fe_reset_notice   : std_logic;

  -- BRS signals
  signal time_base_actual_value : std_logic_vector(63 downto 0);
  signal trig_tm_value_SB       : std_logic_vector(63 downto 0);
  signal trig_tm_value_TB       : std_logic_vector(63 downto 0);
  signal trig_tm_value_seq      : std_logic_vector(63 downto 0);
  signal trig_tm_value_V_I      : std_logic_vector(63 downto 0);
  signal trig_tm_value_pcb_t    : std_logic_vector(63 downto 0);
  signal time_base_busy         : std_logic;

  -- sequencer signals
  signal seq_start                : std_logic;
  signal sequencer_busy           : std_logic_vector(cfg.numSequencers-1 downto 0);
  signal seq_time_mem_readbk      : Slv16Array(cfg.numSequencers-1 downto 0);
  signal seq_out_mem_readbk       : Slv32Array(cfg.numSequencers-1 downto 0);
  signal seq_prog_mem_readbk      : Slv32Array(cfg.numSequencers-1 downto 0);
  signal seq_time_mem_w_en        : std_logic_vector(cfg.numSequencers-1 downto 0);
  signal seq_out_mem_w_en         : std_logic_vector(cfg.numSequencers-1 downto 0);
  signal seq_prog_mem_w_en        : std_logic_vector(cfg.numSequencers-1 downto 0);
  signal seq_step_cmd             : std_logic_vector(cfg.numSequencers-1 downto 0);
  signal seq_stop_cmd             : std_logic_vector(cfg.numSequencers-1 downto 0);
  signal enable_conv_shift        : std_logic_vector(cfg.numSequencers-1 downto 0);
  signal enable_conv_shift_out    : std_logic_vector(cfg.numSequencers-1 downto 0);
  signal init_conv_shift          : std_logic_vector(cfg.numSequencers-1 downto 0);
  signal end_sequence             : std_logic_vector(cfg.numSequencers-1 downto 0);
  signal start_add_prog_mem_en    : std_logic_vector(cfg.numSequencers-1 downto 0);
  signal start_add_prog_mem_rbk   : Slv10Array(cfg.numSequencers-1 downto 0);
  signal seq_ind_func_mem_we      : std_logic_vector(cfg.numSequencers-1 downto 0);
  signal seq_ind_func_mem_rdbk    : Slv4Array(cfg.numSequencers-1 downto 0);
  signal seq_ind_rep_mem_we       : std_logic_vector(cfg.numSequencers-1 downto 0);
  signal seq_ind_rep_mem_rdbk     : Slv24Array(cfg.numSequencers-1 downto 0);
  signal seq_ind_sub_add_mem_we   : std_logic_vector(cfg.numSequencers-1 downto 0);
  signal seq_ind_sub_add_mem_rdbk : Slv10Array(cfg.numSequencers-1 downto 0);
  signal seq_ind_sub_rep_mem_we   : std_logic_vector(cfg.numSequencers-1 downto 0);
  signal seq_ind_sub_rep_mem_rdbk : Slv16Array(cfg.numSequencers-1 downto 0);
  signal seq_op_code_error        : std_logic_vector(cfg.numSequencers-1 downto 0);
  signal seq_op_code_error_reset  : std_logic_vector(cfg.numSequencers-1 downto 0);
  signal seq_op_code_error_add    : Slv10Array(cfg.numSequencers-1 downto 0);

  signal sequencer_outputs : SequencerOutputArray(NUM_SENSORS_C-1 downto 0);
  signal seq_override_we   : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal seq_override_rd   : Slv32Array(NUM_SENSORS_C-1 downto 0);

  -- Image handler signals
  signal image_pattern_read : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal image_pattern_en   : std_logic;
  signal ADC_trigger        : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal pattern_reset      : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal adc_data_int       : SlV16Array(NUM_SENSORS_C-1 downto 0);
  signal adc_cnv_int        : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal adc_sck_int        : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal ccd_oe_en          : std_logic;
  signal ccd_oe             : std_logic_vector(NUM_SENSORS_C-1 downto 0);

  -- ASPIC config signals
  signal aspic_start_trans    : std_logic;
  signal aspic_start_reset    : std_logic;
  signal aspic_busy           : std_logic;
  signal aspic_config_r_ccd   : Slv16Array(NUM_SENSORS_C-1 downto 0);
  signal ASPIC_spi_reset_int  : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal ASPIC_ss_t_ccd_int   : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal ASPIC_ss_b_ccd_int   : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal ASPIC_spi_miso_ccd   : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal ASPIC_miso_sel_ccd   : std_logic_vector(NUM_SENSORS_C-1 downto 0);

  signal aspic_nap_mode_en    : std_logic;
  signal aspic_nap_mode_ccd   : std_logic_vector(NUM_SENSORS_C-1 downto 0);

  -- ASPIC CCD
  signal ASPIC_r_up_ccd   : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal ASPIC_r_down_ccd : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal ASPIC_clamp_ccd  : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal ASPIC_reset_ccd  : std_logic_vector(NUM_SENSORS_C-1 downto 0);

  -- CCD signals
  signal par_clk_ccd    : Slv4Array(NUM_SENSORS_C-1 downto 0);
  signal ser_clk_ccd    : Slv3Array(NUM_SENSORS_C-1 downto 0);
  signal reset_gate_ccd : std_logic_vector(NUM_SENSORS_C-1 downto 0);

  -- CCD clock rails DAC
  signal clk_rail_load_start : std_logic;
  signal clk_rail_ldac_start : std_logic;

  -- CABAC bias
  signal bias_dac_cmd_err : std_logic_vector(5 downto 0);
  signal bias_v_undr_th   : std_logic_vector(5 downto 0);
  signal bias_load_start  : std_logic;
  signal bias_ldac_start  : std_logic;

  signal bias_gd_thresh_ccd : Slv12Array(NUM_SENSORS_C-1 downto 0);
  signal bias_od_thresh_ccd : Slv12Array(NUM_SENSORS_C-1 downto 0);
  signal bias_rd_thresh_ccd : Slv12Array(NUM_SENSORS_C-1 downto 0);

  -- ltc2945 V & I sensors read
  signal V_I_read_start        : std_logic;
  signal V_I_busy              : std_logic;
  signal error_V_HTR_voltage   : std_logic;
  signal V_HTR_voltage         : std_logic_vector(15 downto 0);
  signal error_V_HTR_current   : std_logic;
  signal V_HTR_current         : std_logic_vector(15 downto 0);
  signal error_V_DREB_voltage  : std_logic;
  signal V_DREB_voltage        : std_logic_vector(15 downto 0);
  signal error_V_DREB_current  : std_logic;
  signal V_DREB_current        : std_logic_vector(15 downto 0);
  signal error_V_CLK_H_voltage : std_logic;
  signal V_CLK_H_voltage       : std_logic_vector(15 downto 0);
  signal error_V_CLK_H_current : std_logic;
  signal V_CLK_H_current       : std_logic_vector(15 downto 0);
  signal error_V_OD_voltage    : std_logic;
  signal V_OD_voltage          : std_logic_vector(15 downto 0);
  signal error_V_OD_current    : std_logic;
  signal V_OD_current          : std_logic_vector(15 downto 0);
  signal error_V_ANA_voltage   : std_logic;
  signal V_ANA_voltage         : std_logic_vector(15 downto 0);
  signal error_V_ANA_current   : std_logic;
  signal V_ANA_current         : std_logic_vector(15 downto 0);

  -- PCB temperature
  signal temp_read_start : std_logic;
  signal temp_busy       : std_logic;

  -- DREB temperature
  signal DREB_temp_busy : std_logic;
  signal T1_dreb        : std_logic_vector(15 downto 0);
  signal T1_dreb_error  : std_logic;
  signal T2_dreb        : std_logic_vector(15 downto 0);
  signal T2_dreb_error  : std_logic;

  -- REB temperature
  signal REB_temp_busy_gr : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal T1_reb_gr        : Slv16Array(NUM_SENSORS_C-1 downto 0);
  signal T1_reb_gr_error  : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal T2_reb_gr        : Slv16Array(NUM_SENSORS_C-1 downto 0);
  signal T2_reb_gr_error  : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal T3_reb_gr        : Slv16Array(NUM_SENSORS_C-1 downto 0);
  signal T3_reb_gr_error  : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal T4_reb_gr        : Slv16Array(NUM_SENSORS_C-1 downto 0);
  signal T4_reb_gr_error  : std_logic_vector(NUM_SENSORS_C-1 downto 0);

  -- ASPIC temp and voltage monitor
  signal aspic_t_v_data    : Slv32Array(3 downto 0);
  signal aspic_t_v_start_r : std_logic;
  signal aspic_t_v_busy    : std_logic;

  -- CCD temperature
  signal ccd_temp_busy        : std_logic;
  signal ccd_temp             : std_logic_vector(23 downto 0);
  signal ccd_temp_start       : std_logic;
  signal ccd_temp_start_reset : std_logic;

  -- slow adc
  signal slow_adc_busy              : std_logic;
  signal ck_adc_conv_res            : array816;
  signal ccd1_adc_conv_res          : array816;
  signal ccd2_adc_conv_res          : array816 := (others => (others => '0'));
  signal slow_adc_start_read        : std_logic;
  signal slow_adc_start_write       : std_logic;
  signal slow_adc_write_en          : std_logic;
  signal slow_adc_data_to_adc_out   : std_logic_vector(3 downto 0);
  signal slow_adc_data_from_adc_int : std_logic_vector(15 downto 0);

  signal reb_onewire_reset : std_logic;
  signal sn_start_dcm_int  : std_logic;
  signal sn_start_dcm      : std_logic;
  signal sn_start          : std_logic;
  signal reb_sn_crc_ok     : std_logic;
  signal reb_sn_dev_error  : std_logic;
  signal sn_error_bus      : std_logic_vector(1 downto 0);
  signal reb_sn            : std_logic_vector(47 downto 0);
  signal reb_sn_long       : std_logic_vector(63 downto 0);

  -- CCD clock enable
  signal ccd_clk_en_out_int : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal ccd_clk_en         : std_logic;

  -- ASPIC reference enable
  signal aspic_ref_en_out_int_ccd : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal aspic_ref_en             : std_logic;

  -- ASPIC 5V enable
  signal aspic_5v_en_out_int_ccd : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal aspic_5v_en             : std_logic;

  -- CABAC regulators enable
  signal CABAC_reg_in : std_logic_vector(4 downto 0);
  signal CABAC_reg_en : std_logic;

  ------ MISC ------
  signal dcm_locked : std_logic;
  signal test_port  : std_logic_vector(3 downto 0);

  -- CABAC_pulse
  signal cabac_pulse_ccd : std_logic_vector(NUM_SENSORS_C-1 downto 0);

  -- back bias switch signals
  signal en_back_bias_sw               : std_logic;
  signal back_bias_sw_protected        : std_logic;
  signal back_bias_sw_protected_int    : std_logic;
  signal back_bias_clamp_protected_int : std_logic;
  signal back_bias_sw_error            : std_logic;
  signal back_bias_sw_error_int        : std_logic;

  -- this line enables the output buffers
  signal enable_io : std_logic;

  -- multiboot
  signal start_multiboot : std_logic;

  -- bitstream Remote Update
  signal ru_start               : std_logic;
  signal ru_transfer_done       : std_logic;
  signal ru_image_ID_we         : std_logic;
  signal ru_bitstream_we        : std_logic;
  signal ru_bitstream_fifo_full : std_logic;
  signal ru_busy                : std_logic;
  signal ru_satatus_reg         : std_logic_vector(15 downto 0);
  signal ru_reboot_status       : std_logic_vector(31 downto 0);

  signal LTC2945_SDA_int : std_logic;
  signal LTC2945_SCL_int : std_logic;

  signal reb_sn_onewire_int : std_logic;

  signal ASPIC_spi_mosi_int : std_logic;
  signal ASPIC_spi_sclk_int : std_logic;

  signal gpio_0_int : std_logic;
  signal gpio_1_int : std_logic;

  signal aspic_t_v_mosi_int   : std_logic;
  signal aspic_t_v_ss_ccd_int : std_logic_vector(NUM_SENSORS_C-1 downto 0);
  signal aspic_t_v_sclk_int   : std_logic;

  constant TPD_C : time := 1 ns;

begin

  check_configuration(cfg, NUM_SENSORS_C, HAS_MULTIBOOT_C, fwVersion, LSST_SCI_VERSION);

  --------------------------------------------------------------------------
  -- Signal assignments
  --------------------------------------------------------------------------
  regDataWr_masked         <= regDataWr and regWrEn;
  StatusAddr(23 downto 10) <= (others => '0');
  StatusAddr(9 downto 0)   <= regAddr(9 downto 0);

  ------------ Trigger signals assignment ------------
  seq_start       <= (trigger_val_bus(2) and trigger_ce_bus(2)) or sync_cmd_start_seq;
  V_I_read_start  <= (trigger_val_bus(3) and trigger_ce_bus(3));
  temp_read_start <= (trigger_val_bus(4) and trigger_ce_bus(4));

  ------------ Interrupt signals assignment ------------
  -- busy signals
  -- temperature signals
  temp_busy <= DREB_temp_busy or uOr(REB_temp_busy_gr);

  -- interrupt configuration
  interrupt_edge_en <= "00" & x"000" & "001" & "11101" & "11101" & "11101";

  single_sequencer : if cfg.numSequencers = 1 generate
    interrupt_bus_in  <= "00" & x"000" & temp_busy & V_I_busy & fe_reset_notice &
                         "00000" &
                         "00000" &
                         sequencer_outputs(0).user_bit & SCI_DataIn(0).eot & SCI_DataIn(0).sot & sequencer_busy(0) & sequencer_busy(0);
    busy_bus          <= x"000000" & "00" & sequencer_busy & temp_busy & V_I_busy & uOr(sequencer_busy) & time_base_busy & '0';
  end generate single_sequencer;

  multi_sequencer : if cfg.numSequencers = 2 generate
    interrupt_bus_in  <= "00" & x"000" & temp_busy & V_I_busy & fe_reset_notice &
                         "00000" &
                         sequencer_outputs(1).user_bit & SCI_DataIn(1).eot & SCI_DataIn(1).sot & sequencer_busy(1) & sequencer_busy(1) &
                         sequencer_outputs(0).user_bit & SCI_DataIn(0).eot & SCI_DataIn(0).sot & sequencer_busy(0) & sequencer_busy(0);
    busy_bus          <= x"000000" & '0' & sequencer_busy & temp_busy & V_I_busy & uOr(sequencer_busy) & time_base_busy & '0';
  end generate multi_sequencer;

  ------------ Sensor signals assignment ------------
  sequencer_connection : for s in 0 to NUM_SENSORS_C-1 generate

    ASPIC_r_up_ccd(s)   <= not sequencer_outputs(s).aspic_r_up;
    ASPIC_r_down_ccd(s) <= not sequencer_outputs(s).aspic_r_down;
    ASPIC_reset_ccd(s)  <=     sequencer_outputs(s).aspic_reset;
    ASPIC_clamp_ccd(s)  <=     sequencer_outputs(s).aspic_clamp;
    ser_clk_ccd(s)      <=     sequencer_outputs(s).ser_clk;
    reset_gate_ccd(s)   <=     sequencer_outputs(s).reset_gate;
    par_clk_ccd(s)      <=     sequencer_outputs(s).par_clk;
    ADC_trigger(s)      <=     sequencer_outputs(s).adc_trigger;
    pattern_reset(s)    <=     sequencer_outputs(s).pattern_reset;
    cabac_pulse_ccd(s)  <=     sequencer_outputs(s).cabac_pulse;

    adc_buff_pd_ccd(s)     <= '1';

    --ASPIC_nap_ccd(s)       <= aspic_nap_mode_ccd(s); -- nap mode activated =1
    --ASPIC_spi_mosi_ccd(s)  <= ASPIC_mosi_int;
    --ASPIC_spi_sclk_ccd(s)  <= ASPIC_sclk_int;
    --ASPIC_spi_reset_ccd(s) <= ASPIC_spi_reset;

    --aspic_miso_sel_ccd(s) <= ASPIC_ss_t_ccd_int(s) and (not ASPIC_ss_b_ccd_int(s));
    --ASPIC_miso_ccd(s)     <= ASPIC_spi_miso_t_ccd(s) when ASPIC_miso_sel_ccd(s) = '0' else
    --                         ASPIC_spi_miso_b_ccd(s);

  end generate sequencer_connection;


  ASPIC_nap_ccd       <= aspic_nap_mode_ccd; -- nap mode activated =1
  ASPIC_spi_reset_ccd <= ASPIC_spi_reset_int;
  ASPIC_spi_miso_ccd  <= (ASPIC_spi_miso_t_ccd and ASPIC_ss_t_ccd_int) or (ASPIC_spi_miso_b_ccd and ASPIC_ss_b_ccd_int);
  ASPIC_ss_t_ccd      <= ASPIC_ss_t_ccd_int;
  ASPIC_ss_b_ccd      <= ASPIC_ss_b_ccd_int;

  ------------ assignment for test ------------
  gpio_0_int   <= sequencer_outputs(0).pattern_reset;
  gpio_2       <= sequencer_outputs(0).pattern_reset;
  gpio_1_int   <= sequencer_outputs(1).pattern_reset;
  test_port(2) <= sequencer_outputs(0).adc_trigger;

  ------------ misc ------------
  enable_io <= '0'; -- 1 = disable

  LTC2945_SDA <= LTC2945_SDA_int;
  LTC2945_SCL <= LTC2945_SCl_int;

  reb_sn_onewire <= reb_sn_onewire_int;

  aspic_t_v_mosi   <= aspic_t_v_mosi_int;
  aspic_t_v_ss_ccd <= aspic_t_v_ss_ccd_int;
  aspic_t_v_sclk   <= aspic_t_v_sclk_int;

  adc_cnv_ccd  <= adc_cnv_int;
  adc_sck_ccd  <= adc_sck_int;
  adc_data_int <= adc_data_ccd;

  --------------------------------------------------------------------------
  -- System Clock and Reset
  --------------------------------------------------------------------------
  U_LocRefClkIbufds : component IBUFDS_GTE2
    port map (
      I     => PgpRefClk_P,
      IB    => PgpRefClk_M,
      CEB   => '0',
      O     => PgpRefClk,
      ODIV2 => open
    );

  SystemClock_0 : entity lsst_reb.SystemClock
    generic map (
      SYS_CLK_PER_G => cfg.sysClkPer
    )
    port map (
      refClk        => pgpRefClk,
      usrClk        => usrClk,
      usrRst        => usrRst,
      stableClk     => stable_clk,
      stableRst     => stable_rst,
      stableSlowClk => multiboot_clk,
      stableSlowRst => open,
      stableLocked  => open,
      sysClk        => sys_clk,
      sysRst        => sys_rst
    );

  --------------------------------------------------------------------------
  -- Other Resets
  --------------------------------------------------------------------------
  Ureset : component IBUF
    port map (
      O => n_rst,
      I => Pwron_Rst_L
    );

  -- reset notice: this ff generates a signal for the reset notice
  reset_notice : component FDRE
    port map (
      C  => sys_clk,
      R  => sys_rst,
      CE => '1',
      D  => '1',
      Q  => fe_reset_notice
    );

  --------------------------------------------------------------------------
  -- LSST Source Communication Interface (DAQ)
  --------------------------------------------------------------------------
  LsstSci_0 : entity lsst_sci.LsstSci
    generic map (
      BUILD_INFO_G => BUILD_INFO_G
    )
    port map (
      -------------------------------------------------------------------------
      -- FPGA Interface
      -------------------------------------------------------------------------
      StableClk => stable_clk,
      StableRst => '0',
      FpgaRstL  => n_rst,
      PgpRefClk => PgpRefClk,
      PgpRxP    => PgpRx_P,
      PgpRxM    => PgpRx_M,
      PgpTxP    => PgpTx_P,
      PgpTxM    => PgpTx_M,
      -------------------------------------------------------------------------
      -- Clock/Reset Generator Interface
      -------------------------------------------------------------------------
      ClkOut => usrClk,
      RstOut => usrRst,
      ClkIn  => sys_clk,
      RstIn  => sys_rst,
      -------------------------------------------------------------------------
      -- SCI Register Encoder/Decoder Interface
      -------------------------------------------------------------------------
      RegAddr   => RegAddr,
      RegReq    => regReq,
      RegOp     => regOp,
      RegDataWr => RegDataWr,
      RegWrEn   => RegWrEn,
      RegAck    => regAck,
      RegFail   => regFail,
      RegDataRd => RegDataRd,
      -------------------------------------------------------------------------
      -- Data Encoder Interface
      -------------------------------------------------------------------------
      DataIn => SCI_DataIn,
      -------------------------------------------------------------------------
      -- Notification Interface
      -------------------------------------------------------------------------
      NoticeEn             => interrupt_en_out,
      Notice(59 downto 39) => (others => '0'),
      Notice(38 downto 36) => interrupt_bus_out(17 downto 15),
      Notice(35 downto 29) => (others => '0'),
      Notice(28 downto 24) => interrupt_bus_out(14 downto 10),
      Notice(23 downto 17) => (others => '0'),
      Notice(16 downto 12) => interrupt_bus_out(9 downto 5),
      Notice(11 downto 5)  => (others => '0'),
      Notice(4 downto 0)   => interrupt_bus_out(4 downto 0),
      -------------------------------------------------------------------------
      -- Synchronous Command Interface
      -------------------------------------------------------------------------
      SyncCmdEn => sync_cmd_en,
      SyncCmd   => sync_cmd_in,
      -------------------------------------------------------------------------
      -- Status Block Interface
      -------------------------------------------------------------------------
      StatusAddr => StatusAddr,
      StatusReg  => StatusReg,
      StatusRst  => StatusRst,
      -------------------------------------------------------------------------
      -- Debug Interface
      -------------------------------------------------------------------------
      PgpLocLinkReadyOut => pgpLocLinkReady,
      PgpRemLinkReadyOut => pgpRemLinkReady,
      PgpRxPhyReadyOut   => open,
      PgpTxPhyReadyOut   => open
    );

  --------------------------------------------------------------------------
  -- Command Interpreter
  --------------------------------------------------------------------------
  cmd_interpreter_0 : entity common.GREB_v2_cmd_interpeter
    generic map(
      --VERSION_G => VERSION_G,
      --NUM_SEQUENCERS_G => cfg.numSequencers,
      --CLK_PERIOD_G     => cfg.sysClkPer
      VERSION_G    => fwVersion,
      CONFIG_G     => CONFIG_G
    )
    port map (
      reset => sys_rst,
      clk   => sys_clk,
      -- signals from/to SCI
      regReq           => regReq,
      regOp            => regOp,
      regAddr          => RegAddr,
      statusReg        => StatusReg,
      regWrEn          => RegWrEn,
      regDataWr_masked => regDataWr_masked,
      regAck           => regAck,
      regFail          => regFail,
      regDataRd        => RegDataRd,
      StatusReset      => StatusRst,
      -- Base Register Set signals
      busy_bus               => busy_bus,
      time_base_actual_value => time_base_actual_value,
      trig_tm_value_SB       => trig_tm_value_SB,
      trig_tm_value_TB       => trig_tm_value_TB,
      trig_tm_value_seq      => trig_tm_value_seq,
      trig_tm_value_V_I      => trig_tm_value_V_I,
      trig_tm_value_pcb_t    => trig_tm_value_pcb_t,
      trigger_ce_bus         => trigger_ce_bus,
      trigger_val_bus        => trigger_val_bus,
      load_time_base_lsw     => load_time_base_lsw,
      load_time_base_MSW     => load_time_base_MSW,
      cnt_preset             => cnt_preset,
      Mgt_avcc_ok            => '0',
      Mgt_accpll_ok          => '0',
      Mgt_avtt_ok            => '0',
      V3_3v_ok               => '0',
      Switch_addr            => r_add,
      -- sync commands
      sync_cmd_delay_en   => sync_cmd_delay_en,
      sync_cmd_delay_read => sync_cmd_delay_read,
      -- interrupt commands
      interrupt_mask_wr_en => mask_bus_in_en,
      interrupt_mask_read  => mask_bus_out,
      -- Image parameters
      image_size         => x"00000000",
      image_pattern_read => image_pattern_read,
      ccd_sel_read       => "011",
      ccd_oe_en          => ccd_oe_en,
      ccd_oe_read        => ccd_oe,
      image_size_en      => open,
      image_pattern_en   => image_pattern_en,
      ccd_sel_en         => open,
      -- Sequencer
      seq_override_wr          => seq_override_we,
      seq_override_rd          => seq_override_rd,
      seq_time_mem_readbk      => seq_time_mem_readbk,
      seq_out_mem_readbk       => seq_out_mem_readbk,
      seq_prog_mem_readbk      => seq_prog_mem_readbk,
      seq_time_mem_w_en        => seq_time_mem_w_en,
      seq_out_mem_w_en         => seq_out_mem_w_en,
      seq_prog_mem_w_en        => seq_prog_mem_w_en,
      seq_step                 => seq_step_cmd,
      seq_stop                 => seq_stop_cmd,
      enable_conv_shift_in     => enable_conv_shift_out,
      enable_conv_shift        => enable_conv_shift,
      init_conv_shift          => init_conv_shift,
      start_add_prog_mem_en    => start_add_prog_mem_en,
      start_add_prog_mem_rbk   => start_add_prog_mem_rbk,
      seq_ind_func_mem_we      => seq_ind_func_mem_we,
      seq_ind_func_mem_rdbk    => seq_ind_func_mem_rdbk,
      seq_ind_rep_mem_we       => seq_ind_rep_mem_we,
      seq_ind_rep_mem_rdbk     => seq_ind_rep_mem_rdbk,
      seq_ind_sub_add_mem_we   => seq_ind_sub_add_mem_we,
      seq_ind_sub_add_mem_rdbk => seq_ind_sub_add_mem_rdbk,
      seq_ind_sub_rep_mem_we   => seq_ind_sub_rep_mem_we,
      seq_ind_sub_rep_mem_rdbk => seq_ind_sub_rep_mem_rdbk,
      seq_op_code_error        => seq_op_code_error,
      seq_op_code_error_add    => seq_op_code_error_add,
      seq_op_code_error_reset  => seq_op_code_error_reset,
      -- ASPIC
      aspic_config_r_ccd_1 => aspic_config_r_ccd(0),
      aspic_config_r_ccd_2 => aspic_config_r_ccd(1),
      aspic_config_r_ccd_3 => (others => '0'),
      aspic_op_end         => aspic_busy,
      aspic_start_trans    => aspic_start_trans,
      aspic_start_reset    => aspic_start_reset,
      aspic_nap_mode_en    => aspic_nap_mode_en,
      aspic_nap_ccd1_in    => aspic_nap_mode_ccd(0),
      aspic_nap_ccd2_in    => aspic_nap_mode_ccd(1),
      --  BIAS DAC (former CABAC bias DAC)
      c_bias_dac_cmd_err   => bias_dac_cmd_err,
      c_bias_v_undr_th     => bias_v_undr_th,
      c_bias_load_start    => bias_load_start,
      c_bias_ldac_start    => bias_ldac_start,
      ccd_1_bias_gd_thresh => bias_gd_thresh_ccd(0),
      ccd_1_bias_od_thresh => bias_od_thresh_ccd(0),
      ccd_1_bias_rd_thresh => bias_rd_thresh_ccd(0),
      ccd_2_bias_gd_thresh => bias_gd_thresh_ccd(1),
      ccd_2_bias_od_thresh => bias_od_thresh_ccd(1),
      ccd_2_bias_rd_thresh => bias_rd_thresh_ccd(1),
      -- CCD clock rails DAC
      clk_rail_load_start => clk_rail_load_start,
      clk_rail_ldac_start => clk_rail_ldac_start,
      -- DREB voltage and current sensors
      error_V_HTR_voltage   => error_V_HTR_voltage,
      V_HTR_voltage         => V_HTR_voltage,
      error_V_HTR_current   => error_V_HTR_current,
      V_HTR_current         => V_HTR_current,
      error_V_DREB_voltage  => error_V_DREB_voltage,
      V_DREB_voltage        => V_DREB_voltage,
      error_V_DREB_current  => error_V_DREB_current,
      V_DREB_current        => V_DREB_current,
      error_V_CLK_H_voltage => error_V_CLK_H_voltage,
      V_CLK_H_voltage       => V_CLK_H_voltage,
      error_V_CLK_H_current => error_V_CLK_H_current,
      V_CLK_H_current       => V_CLK_H_current,
      error_V_OD_voltage    => error_V_OD_voltage,
      V_OD_voltage          => V_OD_voltage,
      error_V_OD_current    => error_V_OD_current,
      V_OD_current          => V_OD_current,
      error_V_ANA_voltage   => error_V_ANA_voltage,
      V_ANA_voltage         => V_ANA_voltage,
      error_V_ANA_current   => error_V_ANA_current,
      V_ANA_current         => V_ANA_current,
      -- DREB temperature
      T1_dreb       => T1_dreb,
      T1_dreb_error => T1_dreb_error,
      T2_dreb       => T2_dreb,
      T2_dreb_error => T2_dreb_error,
      -- REB temperature gr1
      T1_reb_gr1       => T1_reb_gr(0),
      T1_reb_gr1_error => T1_reb_gr_error(0),
      T2_reb_gr1       => T2_reb_gr(0),
      T2_reb_gr1_error => T2_reb_gr_error(0),
      T3_reb_gr1       => T3_reb_gr(0),
      T3_reb_gr1_error => T3_reb_gr_error(0),
      T4_reb_gr1       => T4_reb_gr(0),
      T4_reb_gr1_error => T4_reb_gr_error(0),
      -- REB temperature gr2
      T1_reb_gr2       => T1_reb_gr(1),
      T1_reb_gr2_error => T1_reb_gr_error(1),
      T2_reb_gr2       => T2_reb_gr(1),
      T2_reb_gr2_error => T2_reb_gr_error(1),
      T3_reb_gr2       => T3_reb_gr(1),
      T3_reb_gr2_error => T3_reb_gr_error(1),
      T4_reb_gr2       => T4_reb_gr(1),
      T4_reb_gr2_error => T4_reb_gr_error(1),
      -- REB temperature gr3
      T1_reb_gr3       => x"0000",
      T1_reb_gr3_error => '0',
      -- ASPIC temp and voltage monitor
      aspic_t_v_data    => aspic_t_v_data,
      aspic_t_v_busy    => aspic_t_v_busy,
      aspic_t_v_start_r => aspic_t_v_start_r,
      -- CCD temperature
      ccd_temp_busy        => ccd_temp_busy,
      ccd_temp             => ccd_temp,
      ccd_temp_start       => ccd_temp_start,
      ccd_temp_start_reset => ccd_temp_start_reset,
      -- Bias slow ADC
      slow_adc_busy        => slow_adc_busy,
      ck_adc_conv_res      => ck_adc_conv_res,
      ccd1_adc_conv_res    => ccd1_adc_conv_res,
      ccd2_adc_conv_res    => ccd2_adc_conv_res,
      slow_adc_start_read  => slow_adc_start_read,
      slow_adc_start_write => slow_adc_start_write,
      -- REB 1wire serial number
      reb_onewire_reset => reb_onewire_reset,
      reb_sn_crc_ok     => reb_sn_crc_ok,
      reb_sn_dev_error  => reb_sn_dev_error,
      reb_sn            => reb_sn,
      reb_sn_timeout    => '0',
      -- CCD clock enable
      ccd1_clk_en_in => ccd_clk_en_out_int(0),
      ccd2_clk_en_in => ccd_clk_en_out_int(1),
      ccd_clk_en     => ccd_clk_en,
      -- ASPIC reference enable
      aspic_ref_en_in_ccd1 => aspic_ref_en_out_int_ccd(0),
      aspic_ref_en_in_ccd2 => aspic_ref_en_out_int_ccd(1),
      aspic_ref_en         => aspic_ref_en,
      -- ASPIC 5V enable
      aspic_5v_en_in_ccd1 => aspic_5v_en_out_int_ccd(0),
      aspic_5v_en_in_ccd2 => aspic_5v_en_out_int_ccd(1),
      aspic_5v_en         => aspic_5v_en,
      -- CABAC regulators enable
      CABAC_reg_in => CABAC_reg_in,
      CABAC_reg_en => CABAC_reg_en,
      -- back bias switch
      back_bias_sw_rb    => back_bias_sw_protected_int,
      back_bias_cl_rb    => back_bias_clamp_protected_int,
      back_bias_sw_error => back_bias_sw_error_int,
      en_back_bias_sw    => en_back_bias_sw,
      -- multiboot
      remote_update_reboot_status => ru_reboot_status,
      start_multiboot             => start_multiboot,
      -- remote update
      remote_update_fifo_full  => ru_bitstream_fifo_full,
      remote_update_status_reg => ru_satatus_reg,
      start_remote_update      => ru_start,
      remote_update_bitstrm_we => ru_bitstream_we,
      remote_update_daq_done   => ru_transfer_done
    );

  --------------------------------------------------------------------------
  -- Base Register Set
  --------------------------------------------------------------------------
  base_reg_set : entity lsst_reb.base_reg_set_top
    port map (
      clk                => sys_clk,
      reset              => sys_rst,
      en_time_base_cnt   => trigger_ce_bus(1),
      load_time_base_lsw => load_time_base_lsw,
      load_time_base_MSW => load_time_base_MSW,
      StatusReset        => StatusRst,
      trigger_TB         => trigger_val_bus(1),
      trigger_seq        => seq_start,
      trigger_V_I_read   => V_I_read_start,
      trigger_temp_pcb   => temp_read_start,
      trigger_fast_adc   => '0',
      cnt_preset         => cnt_preset,
      cnt_busy           => time_base_busy,
      cnt_actual_value   => time_base_actual_value,
      trig_tm_value_SB   => trig_tm_value_SB,
      trig_tm_value_TB   => trig_tm_value_TB,
      trig_tm_value_seq  => trig_tm_value_seq,
      trig_tm_value_V_I  => trig_tm_value_V_I,
      trig_tm_value_pcb  => trig_tm_value_pcb_t,
      trig_tm_value_adc  => open
    );

  --------------------------------------------------------------------------
  -- Synchronous Command Decoder
  --------------------------------------------------------------------------
  sync_cmd_decoder_top_1 : entity lsst_reb.sync_cmd_decoder_top
    port map (
      pgp_clk            => usrClk,
      pgp_reset          => usrRst,
      clk                => sys_clk,
      reset              => sys_rst,
      sync_cmd_en        => sync_cmd_en,
      delay_en           => sync_cmd_delay_en,
      delay_in           => regDataWr_masked(7 downto 0),
      delay_read         => sync_cmd_delay_read,
      sync_cmd           => sync_cmd_in,
      sync_cmd_start_seq => sync_cmd_start_seq,
      sync_cmd_step_seq  => sync_cmd_step_seq,
      sync_cmd_stop_seq  => sync_cmd_stop_seq,
      sync_cmd_main_add  => sync_cmd_main_add
    );

  --------------------------------------------------------------------------
  -- REB Interrupts (SCI Notices)
  --------------------------------------------------------------------------
  REB_interrupt_top_1 : entity lsst_reb.REB_interrupt_top
    generic map (
      interrupt_bus_width => 32
    )
    port map (
      clk               => sys_clk,
      reset             => usrRst,
      edge_en           => interrupt_edge_en,
      interrupt_bus_in  => interrupt_bus_in,
      mask_bus_in_en    => mask_bus_in_en,
      mask_bus_in       => regDataWr_masked(31 downto 0),
      mask_bus_out      => mask_bus_out,
      interrupt_en_out  => interrupt_en_out,
      interrupt_bus_out => interrupt_bus_out
    );

  --------------------------------------------------------------------------
  -- ADC Data Handlers
  --------------------------------------------------------------------------
  AdcDataHandlers : entity lsst_reb.AdcDataHandler
    generic map (
      NUM_SENSORS_G    => NUM_SENSORS_C,
      NUM_SEQUENCERS_G => cfg.numSequencers,
      CLK_PERIOD_G     => cfg.sysClkPer
    )
    port map (
      rst               => sys_rst,
      clk               => sys_clk,
      regDataWr         => regDataWr_masked,
      ccd_oe_we         => ccd_oe_en,
      ccd_oe_rd         => ccd_oe,
      testmode_rst      => pattern_reset,
      sequencer_outputs => sequencer_outputs,
      end_sequence      => end_sequence,
      trigger           => ADC_trigger,
      en_test_mode      => image_pattern_en,
      sci_data          => SCI_DataIn(NUM_SENSORS_C-1 downto 0),
      test_mode_enb_out => image_pattern_read,
      adc_data          => adc_data_int,
      adc_cnv           => adc_cnv_int,
      adc_sck           => adc_sck_int
    );

  --------------------------------------------------------------------------
  -- Sequencers
  --------------------------------------------------------------------------
  Sequencers : entity lsst_reb.Sequencer
    generic map (
      NUM_SENSORS_G    => NUM_SENSORS_C,
      NUM_SEQUENCERS_G => cfg.numSequencers
    )
    port map (
      clk => sys_clk,
      rst => sys_rst,
      regAddr => regAddr,
      regDataWr => regDataWr_masked,
      sync_cmd_start => sync_cmd_start_seq,
      sync_cmd_stop => sync_cmd_stop_seq,
      sync_cmd_step => sync_cmd_step_seq,
      reg_cmd_start => start_add_prog_mem_en,
      reg_cmd_stop  => seq_stop_cmd,
      reg_cmd_step  => seq_step_cmd,
      sync_cmd_main_addr => sync_cmd_main_add,
      sequencer_start_addr_rd => start_add_prog_mem_rbk,
      prog_mem_we => seq_prog_mem_w_en,
      prog_mem_rd => seq_prog_mem_readbk,
      ind_func_mem_we => seq_ind_func_mem_we,
      ind_func_mem_rd => seq_ind_func_mem_rdbk,
      ind_rep_mem_we => seq_ind_rep_mem_we,
      ind_rep_mem_rd => seq_ind_rep_mem_rdbk,
      ind_sub_add_mem_we => seq_ind_sub_add_mem_we,
      ind_sub_add_mem_rd => seq_ind_sub_add_mem_rdbk,
      ind_sub_rep_mem_we => seq_ind_sub_rep_mem_we,
      ind_sub_rep_mem_rd => seq_ind_sub_rep_mem_rdbk,
      time_mem_we => seq_time_mem_w_en,
      time_mem_rd => seq_time_mem_readbk,
      out_mem_we => seq_out_mem_w_en,
      out_mem_rd => seq_out_mem_readbk,
      op_code_error_reset => seq_op_code_error_reset,
      op_code_error => seq_op_code_error,
      op_code_error_add => seq_op_code_error_add,
      override_we => seq_override_we,
      override_rd => seq_override_rd,
      sequencer_busy => sequencer_busy,
      end_sequence => end_sequence,
      sequencer_out => sequencer_outputs,
      enable_conv_shift => enable_conv_shift,
      init_conv_shift => init_conv_shift,
      enable_conv_shift_out => enable_conv_shift_out
    );

  --------------------------------------------------------------------------
  -- ASPIC Control
  --------------------------------------------------------------------------
  aspic_spi_link_top_0 : entity lsst_reb.aspic_spi_link_top
    generic map (
      NUM_SENSORS_G => NUM_SENSORS_C,
      CLK_PERIOD_G  => cfg.sysClkPer
    )
    port map (
      clk                => sys_clk,
      reset              => sys_rst,
      start_trans        => aspic_start_trans,
      start_reset        => aspic_start_reset,
      data_in            => regDataWr_masked,
      aspic_miso         => ASPIC_spi_miso_ccd,
      aspic_mosi         => ASPIC_spi_mosi_ccd,
      ss_t_ccd           => ASPIC_ss_t_ccd_int,
      ss_b_ccd           => ASPIC_ss_b_ccd_int,
      aspic_sclk         => ASPIC_spi_sclk_ccd,
      aspic_reset        => ASPIC_spi_reset_int,
      busy               => aspic_busy,
      data_out           => aspic_config_r_ccd
    );

  --aspic_3_spi_link_top_mux_0 : entity lsst_reb.aspic_3_spi_link_top_mux
  --  port map (
  --    clk                => sys_clk,
  --    reset              => sys_rst,
  --    start_link_trans   => aspic_start_trans,
  --    start_reset        => aspic_start_reset,
  --    miso_ccd1          => ASPIC_miso_ccd(0),
  --    miso_ccd2          => ASPIC_miso_ccd(1),
  --    miso_ccd3          => '0',
  --    word2send          => regDataWr_masked,
  --    aspic_mosi         => ASPIC_mosi_int,
  --    ss_t_ccd1          => ASPIC_ss_t_ccd_int(0),
  --    ss_t_ccd2          => ASPIC_ss_t_ccd_int(1),
  --    ss_t_ccd3          => open,
  --    ss_b_ccd1          => ASPIC_ss_b_ccd_int(0),
  --    ss_b_ccd2          => ASPIC_ss_b_ccd_int(1),
  --    ss_b_ccd3          => open,
  --    aspic_sclk         => ASPIC_sclk_int,
  --    aspic_n_reset      => ASPIC_spi_reset,
  --    busy               => aspic_busy,
  --    d_slave_ready_ccd1 => open,
  --    d_slave_ready_ccd2 => open,
  --    d_slave_ready_ccd3 => open,
  --    d_from_slave_ccd1  => aspic_config_r_ccd(0),
  --    d_from_slave_ccd2  => aspic_config_r_ccd(1),
  --    d_from_slave_ccd3  => open
  --  );

  aspic_nap_mode : for s in 0 to NUM_SENSORS_C-1 generate
    aspic_nap_mode_ccd_ff : entity lsst_reb.ff_ce
      port map (
        reset    => sys_rst,
        clk      => sys_clk,
        data_in  => regDataWr_masked(s),
        ce       => aspic_nap_mode_en,
        data_out => aspic_nap_mode_ccd(s)
      );
  end generate aspic_nap_mode;

  --------------------------------------------------------------------------
  -- Bias DAC
  --------------------------------------------------------------------------
  bias_dac : entity lsst_reb.dual_ad53xx_DAC_protection_top
    generic map (
      CLK_PERIOD_G => cfg.sysClkPer,
      GD_add       => cfg.gdAddr,
      OD_add       => cfg.odAddr,
      RD_add       => cfg.rdAddr,
      GD_0_th      => cfg.gdThresh(0),
      OD_0_th      => cfg.odThresh(0),
      RD_0_th      => cfg.rdThresh(0),
      GD_1_th      => cfg.gdThresh(1),
      OD_1_th      => cfg.odThresh(1),
      RD_1_th      => cfg.rdThresh(1)
    )
    port map (
      clk             => sys_clk,
      reset           => sys_rst,
      start_write     => bias_load_start,
      start_ldac      => bias_ldac_start,
      bbs_switch_on   => back_bias_sw_protected_int,
      d_to_slave      => regDataWr_masked(16 downto 0),
      command_error   => bias_dac_cmd_err,
      values_under_th => bias_v_undr_th,
      mosi            => din_C_BIAS,
      ss_dac_0        => sync_C_BIAS(0),
      ss_dac_1        => sync_C_BIAS(1),
      sclk            => sclk_C_BIAS,
      ldac            => ldac_C_BIAS,
      gd_0_thresh     => bias_gd_thresh_ccd(0),
      od_0_thresh     => bias_od_thresh_ccd(0),
      rd_0_thresh     => bias_rd_thresh_ccd(0),
      gd_1_thresh     => bias_gd_thresh_ccd(1),
      od_1_thresh     => bias_od_thresh_ccd(1),
      rd_1_thresh     => bias_rd_thresh_ccd(1)
    );

  --------------------------------------------------------------------------
  -- Clock Rails DAC
  --------------------------------------------------------------------------
  clk_rails_dac : entity lsst_reb.dual_ad53xx_DAC_top
    generic map (
      CLK_PERIOD_G => cfg.sysClkPer
    )
    port map (
      clk         => sys_clk,
      reset       => sys_rst,
      start_write => clk_rail_load_start,
      start_ldac  => clk_rail_ldac_start,
      d_to_slave  => regDataWr_masked(16 downto 0),
      mosi        => din_RAILS,
      ss_dac_0    => sync_RAILS_dac(0),
      ss_dac_1    => sync_RAILS_dac(1),
      sclk        => sclk_RAILS,
      ldac        => ldac_RAILS
    );

  --------------------------------------------------------------------------
  -- Voltage, Current, and Temperature Monitors
  --------------------------------------------------------------------------
  ltc2945_V_I_sens : entity lsst_reb.ltc2945_multi_read_top_greb
    generic map (
      CLK_PERIOD_G => cfg.sysClkPer
    )
    port map (
      clk                   => sys_clk,
      reset                 => sys_rst,
      start_procedure       => V_I_read_start,
      busy                  => V_I_busy,
      error_V_HTR_voltage   => error_V_HTR_voltage,
      V_HTR_voltage_out     => V_HTR_voltage,
      error_V_HTR_current   => error_V_HTR_current,
      V_HTR_current_out     => V_HTR_current,
      error_V_DREB_voltage  => error_V_DREB_voltage,
      V_DREB_voltage_out    => V_DREB_voltage,
      error_V_DREB_current  => error_V_DREB_current,
      V_DREB_current_out    => V_DREB_current,
      error_V_CLK_H_voltage => error_V_CLK_H_voltage,
      V_CLK_H_voltage_out   => V_CLK_H_voltage,
      error_V_CLK_H_current => error_V_CLK_H_current,
      V_CLK_H_current_out   => V_CLK_H_current,
      error_V_OD_voltage    => error_V_OD_voltage,
      V_OD_voltage_out      => V_OD_voltage,
      error_V_OD_current    => error_V_OD_current,
      V_OD_current_out      => V_OD_current,
      error_V_ANA_voltage   => error_V_ANA_voltage,
      V_ANA_voltage_out     => V_ANA_voltage,
      error_V_ANA_current   => error_V_ANA_current,
      V_ANA_current_out     => V_ANA_current,
      sda                   => LTC2945_SDA_int,
      scl                   => LTC2945_SCl_int
    );

  DREB_temp_read : entity lsst_reb.adt7420_temp_multiread_2_top
    generic map (
      CLK_PERIOD_G => cfg.sysClkPer
    )
    port map (
      clk             => sys_clk,
      reset           => sys_rst,
      start_procedure => temp_read_start,
      busy            => DREB_temp_busy,
      error_T1        => T1_dreb_error,
      T1_out          => T1_dreb,
      error_T2        => T2_dreb_error,
      T2_out          => T2_dreb,
      sda             => DREB_temp_sda,
      scl             => DREB_temp_scl
    );

  temp_rd_gr_generate : for s in 0 to NUM_SENSORS_C-1 generate
    temp_rd_gr : entity lsst_reb.adt7420_temp_multiread_4_top
      generic map (
        CLK_PERIOD_G => cfg.sysClkPer
      )
      port map (
        clk             => sys_clk,
        reset           => sys_rst,
        start_procedure => temp_read_start,
        busy            => REB_temp_busy_gr(s),
        error_T1        => T1_reb_gr_error(s),
        T1_out          => T1_reb_gr(s),
        error_T2        => T2_reb_gr_error(s),
        T2_out          => T2_reb_gr(s),
        error_T3        => T3_reb_gr_error(s),
        T3_out          => T3_reb_gr(s),
        error_T4        => T4_reb_gr_error(s),
        T4_out          => T4_reb_gr(s),
        sda             => Temp_adc_sda_ccd(s),
        scl             => Temp_adc_scl_ccd(s)
      );
  end generate temp_rd_gr_generate;

  dual_ads1118_top_0 : entity lsst_reb.dual_ads1118_top
    generic map (
      CLK_PERIOD_G => cfg.sysClkPer
    )
    port map (
      clk           => sys_clk,
      reset         => sys_rst,
      start_read    => aspic_t_v_start_r,
      device_select => regDataWr_masked(0),
      miso          => aspic_t_v_miso,
      mosi          => aspic_t_v_mosi_int,
      ss_adc        => aspic_t_v_ss_ccd_int,
      sclk          => aspic_t_v_sclk_int,
      link_busy     => aspic_t_v_busy,
      data_from_adc => aspic_t_v_data
    );

  ccd_temperature_sensor : entity lsst_reb.ad7794_top
    generic map (
      CLK_PERIOD_G => cfg.sysClkPer
    )
    port map (
      clk             => sys_clk,
      reset           => sys_rst,
      start           => ccd_temp_start,
      start_reset     => ccd_temp_start_reset,
      read_dir        => regDataWr_masked(19),
      reg_add         => regDataWr_masked(18 downto 16),
      data_in         => regDataWr_masked(15 downto 0),
      ad7794_dout_rdy => dout_24ADC,
      ad7794_din      => din_24ADC,
      ad7794_cs       => csb_24ADC,
      ad7794_sclk     => sclk_24ADC,
      busy            => ccd_temp_busy,
      data_out        => ccd_temp
    );

  max_11046_multiple_top_1 : entity lsst_reb.max_11046_multiple_top
    generic map (
      num_adc_on_bus => 2,
      CLK_PERIOD_G   => cfg.sysClkPer
    )
    port map (
      clk              => sys_clk,
      reset            => sys_rst,
      start_write      => slow_adc_start_write,
      start_read       => slow_adc_start_read,
      EOC_ck           => ck_adc_EOC,
      EOC_ccd1         => ccd_adc_EOC(0),
      EOC_ccd2         => ccd_adc_EOC(1),
      data_to_adc      => regDataWr_masked(5 downto 0),
      data_from_adc    => slow_adc_data_from_adc_int,
      link_busy        => slow_adc_busy,
      CS_ck            => ck_adc_CS,
      CS_ccd1          => ccd_adc_CS(0),
      CS_ccd2          => ccd_adc_CS(1),
      RD               => slow_adc_RD,
      WR               => slow_adc_WR,
      CONVST_ck        => ck_adc_CONVST,
      CONVST_ccd1      => ccd_adc_CONVST(0),
      CONVST_ccd2      => ccd_adc_CONVST(1),
      SHDN_ck          => ck_adc_SHDN,
      SHDN_ccd1        => ccd_adc_SHDN(0),
      SHDN_ccd2        => ccd_adc_SHDN(1),
      write_en         => slow_adc_write_en,
      data_to_adc_out  => slow_adc_data_to_adc_out,
      cnv_results_ck   => ck_adc_conv_res,
      cnv_results_ccd1 => ccd1_adc_conv_res,
      cnv_results_ccd2 => ccd2_adc_conv_res
    );

  ------------------------------------------------------------------------------
  -- CCD Enables
  ------------------------------------------------------------------------------
  ccd_enables : for s in 0 to NUM_SENSORS_C-1 generate

    ccd_clk_enable_ff : entity lsst_reb.ff_ce
      port map (
        reset    => sys_rst,
        clk      => sys_clk,
        data_in  => regDataWr_masked(s),
        ce       => ccd_clk_en,
        data_out => ccd_clk_en_out_int(s)
      );

    ASPIC_ref_enable_ff_ccd : entity lsst_reb.ff_ce
      port map (
        reset    => sys_rst,
        clk      => sys_clk,
        data_in  => regDataWr_masked(s),
        ce       => aspic_ref_en,
        data_out => aspic_ref_en_out_int_ccd(s)
      );

    ASPIC_ref_sd_ccd(s) <= aspic_ref_en_out_int_ccd(s);

    ASPIC_5v_enable_ff_ccd : entity lsst_reb.ff_ce_pres
      port map (
        preset   => sys_rst,
        clk      => sys_clk,
        data_in  => regDataWr_masked(s),
        ce       => aspic_5v_en,
        data_out => aspic_5v_en_out_int_ccd(s)
      );

    ASPIC_5V_sd_ccd(s) <= aspic_5v_en_out_int_ccd(s);

  end generate ccd_enables;

  ------------------------------------------------------------------------------
  -- Board Serial Number
  ------------------------------------------------------------------------------
  onewire_master_1 : entity lsst_reb.onewire_master
    port map (
      dev_clk     => stable_clk,
      dev_rst     => stable_rst,
      sys_rst     => sys_rst,
      sys_clk     => sys_clk,
      start_acq   => reb_onewire_reset,
      dq          => reb_sn_onewire,
      d_from_chip => reb_sn_long,
      error_bus   => sn_error_bus
    );

  reb_sn           <= reb_sn_long(55 downto 8);
  reb_sn_dev_error <= sn_error_bus(0);
  reb_sn_crc_ok    <= not sn_error_bus(1);

  ------------------------------------------------------------------------------
  -- Back Bias switch
  ------------------------------------------------------------------------------
  U_backbias_switch : entity lsst_reb.backbias_switch
    port map (
      sys_clk            => sys_clk,
      sys_rst            => sys_rst,
      all_bias_v_undr_th => "000" & bias_v_undr_th,
      sw_wr_en           => en_back_bias_sw,
      sw_wr              => regDataWr_masked(0),
      sw_error           => back_bias_sw_error_int,
      sw_state           => back_bias_sw_protected_int,
      cl_state           => back_bias_clamp_protected_int,
      clamp              => backbias_clamp,
      ssbe               => backbias_ssbe
    );

  ------------------------------------------------------------------------------
  -- Remote Update
  ------------------------------------------------------------------------------
  ru_image_ID_we <= ru_start; -- this works because ru_start is internally delayed for sync.

  Remote_Update_top : entity lsst_reb.multiboot_top
    port map (
      inBitstreamClk       => sys_clk,
      inSpiClk             => multiboot_clk,
      inReset_EnableB      => sys_rst,
      inCheckIdOnly        => '0',
      inVerifyOnly         => '0',
      inStartProg          => ru_start,
      inDaqDone            => ru_transfer_done,
      inStartReboot        => start_multiboot,
      inImageSelWe         => ru_image_ID_we,
      inImageSel           => regDataWr_masked(1 downto 0),
      inBitstreamWe        => ru_bitstream_we,
      inBitstream32        => regDataWr_masked,
      outBitstreamFifoFull => ru_bitstream_fifo_full,
      outStarted           => ru_busy,
      outStatusReg         => ru_satatus_reg,
      outRebootStatus      => ru_reboot_status,
      outSpiCsB            => ru_outSpiCsB,
      outSpiMosi           => ru_outSpiMosi,
      inSpiMiso            => ru_inSpiMiso,
      outSpiWpB            => ru_outSpiWpB,
      outSpiHoldB          => ru_outSpiHoldB
    );

  ------------------------------------------------------------------------------
  -- CCD pin assignments
  ------------------------------------------------------------------------------
  sensor_pins : for s in 0 to NUM_SENSORS_C-1 generate
    U_ASPIC_r_up_ccd : component OBUFTDS
      port map (
        I  => ASPIC_r_up_ccd(s),
        T  => enable_io,
        O  => ASPIC_r_up_ccd_p(s),
        OB => ASPIC_r_up_ccd_n(s)
      );

    U_ASPIC_r_down_ccd : component OBUFTDS
      port map (
        I  => ASPIC_r_down_ccd(s),
        T  => enable_io,
        O  => ASPIC_r_down_ccd_p(s),
        OB => ASPIC_r_down_ccd_n(s)
      );

    U_ASPIC_clamp_ccd : component OBUFTDS
      port map (
        I  => ASPIC_clamp_ccd(s),
        T  => enable_io,
        O  => ASPIC_clamp_ccd_p(s),
        OB => ASPIC_clamp_ccd_n(s)
      );

    U_ASPIC_reset_ccd : component OBUFTDS
      port map (
        I  => ASPIC_reset_ccd(s),
        T  => enable_io,
        O  => ASPIC_reset_ccd_p(s),
        OB => ASPIC_reset_ccd_n(s)
      );

    par_clk_ccd_generate : for c in 0 to 3 generate
      U_par_clk_ccd : component OBUFTDS
        port map (
          I  => par_clk_ccd(s)(c),
          T  => enable_io,
          O  => par_clk_ccd_p(s)(c),
          OB => par_clk_ccd_n(s)(c)
        );
    end generate par_clk_ccd_generate;

    ser_clk_ccd_generate : for c in 0 to 2 generate
      U_ser_clk_ccd : component OBUFTDS
        port map (
          I  => ser_clk_ccd(s)(c),
          T  => enable_io,
          O  => ser_clk_ccd_p(s)(c),
          OB => ser_clk_ccd_n(s)(c)
        );
    end generate ser_clk_ccd_generate;

    U_reset_gate_ccd : component OBUFTDS
      port map (
        I  => reset_gate_ccd(s),
        T  => enable_io,
        O  => reset_gate_ccd_p(s),
        OB => reset_gate_ccd_n(s)
      );

    U_pulse_t_ccd : component OBUFTDS
      port map (
        I  => cabac_pulse_ccd(s),
        T  => enable_io,
        O  => pulse_ccd_p(s),
        OB => pulse_ccd_n(s)
      );

    CCD_clk_en_buffer : component OBUFDS
      port map (
        I  => ccd_clk_en_out_int(s),
        O  => ccd_clk_en_out_p(s),
        OB => ccd_clk_en_out_n(s)
      );

  end generate sensor_pins;

  -- slow slow adc tri state buffer
  slow_adc_iobuf_generate : for i in 0 to 3 generate
    bs_IOBF : component IOBUF
      port map (
        O  => slow_adc_data_from_adc_int(i),
        IO => slow_adc_data_from_adc_dcr(i),
        I  => slow_adc_data_to_adc_out(i),
        T  => slow_adc_write_en
      );
  end generate slow_adc_iobuf_generate;

  slow_adc_data_from_adc_int(15 downto 4) <= slow_adc_data_from_adc;

  gpio_0_buffer : component OBUFDS
    port map (
      I  => gpio_0_int,
      O  => gpio_0_p,
      OB => gpio_0_n
    );

  gpio_1_buffer : component OBUFDS
    port map (
      I  => gpio_1_int,
      O  => gpio_1_p,
      OB => gpio_1_n
    );

  gpio_0_dir <= '0'; -- must be 0 to work as receiver
  gpio_1_dir <= '0'; -- must be 0 to work as receiver

  -- test points
  Utest_points : for i in 0 to 3 generate
    Utest_point : component OBUF
      port map (
        O => TEST(i),
        I => test_port(i)
      );
  end generate Utest_points;

end architecture Behavioral;
