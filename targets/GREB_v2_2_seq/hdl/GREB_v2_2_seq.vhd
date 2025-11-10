library IEEE;
use IEEE.STD_LOGIC_1164.all;

library surf;
use surf.StdRtlPkg.all;

library common;
use common.GREB_v2_pkg.all;

entity GREB_v2_2_seq is
  generic (
    BUILD_INFO_G : BuildInfoType
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
    sync_C_BIAS : out   std_logic_vector(NUM_SENSORS_C-1 downto 0);
    ldac_C_BIAS : out   std_logic;
    din_C_BIAS  : out   std_logic;
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
end entity GREB_v2_2_seq;

architecture Behavioral of GREB_v2_2_seq is

  constant TARGET_CONFIG : RebConfigType := (
    numSequencers => 2,
    sysClkPer     => 10.0E-9,
    gdAddr        => x"0",
    odAddr        => x"5",
    rdAddr        => x"1",
    gdThresh      => (1138, 1138),
    odThresh      => (2275, 2275),
    rdThresh      => (1632, 1632)
    --         Sensor(   0,    1)
  );

  constant VERSION : RebVersionType := (
    schema        => x"00000001",
    board_type    => x"2",
    vhdl_version  => x"2111",
    reserved_1    => x"00000000",
    reserved_2    => x"00000000",
    reserved_3    => x"00000000"
  );

begin

  U_GREB_v2 : entity common.GREB_v2_base
    generic map (
      BUILD_INFO_G => BUILD_INFO_G,
      VERSION_G    => VERSION,
      CONFIG_G     => TARGET_CONFIG
    )
    port map (
      PgpRefClk_P                => PgpRefClk_P,
      PgpRefClk_M                => PgpRefClk_M,
      PgpRx_P                    => PgpRx_P,
      PgpRx_M                    => PgpRx_M,
      PgpTx_P                    => PgpTx_P,
      PgpTx_M                    => PgpTx_M,
      adc_data_ccd               => adc_data_ccd,
      adc_cnv_ccd                => adc_cnv_ccd,
      adc_sck_ccd                => adc_sck_ccd,
      adc_buff_pd_ccd            => adc_buff_pd_ccd,
      ASPIC_r_up_ccd_p           => ASPIC_r_up_ccd_p,
      ASPIC_r_up_ccd_n           => ASPIC_r_up_ccd_n,
      ASPIC_r_down_ccd_p         => ASPIC_r_down_ccd_p,
      ASPIC_r_down_ccd_n         => ASPIC_r_down_ccd_n,
      ASPIC_clamp_ccd_p          => ASPIC_clamp_ccd_p,
      ASPIC_clamp_ccd_n          => ASPIC_clamp_ccd_n,
      ASPIC_reset_ccd_p          => ASPIC_reset_ccd_p,
      ASPIC_reset_ccd_n          => ASPIC_reset_ccd_n,
      par_clk_ccd_p              => par_clk_ccd_p,
      par_clk_ccd_n              => par_clk_ccd_n,
      ser_clk_ccd_p              => ser_clk_ccd_p,
      ser_clk_ccd_n              => ser_clk_ccd_n,
      reset_gate_ccd_p           => reset_gate_ccd_p,
      reset_gate_ccd_n           => reset_gate_ccd_n,
      ASPIC_spi_mosi_ccd         => ASPIC_spi_mosi_ccd,
      ASPIC_spi_sclk_ccd         => ASPIC_spi_sclk_ccd,
      ASPIC_spi_miso_t_ccd       => ASPIC_spi_miso_t_ccd,
      ASPIC_spi_miso_b_ccd       => ASPIC_spi_miso_b_ccd,
      ASPIC_ss_t_ccd             => ASPIC_ss_t_ccd,
      ASPIC_ss_b_ccd             => ASPIC_ss_b_ccd,
      ASPIC_spi_reset_ccd        => ASPIC_spi_reset_ccd,
      ASPIC_nap_ccd              => ASPIC_nap_ccd,
      backbias_clamp             => backbias_clamp,
      backbias_ssbe              => backbias_ssbe,
      pulse_ccd_p                => pulse_ccd_p,
      pulse_ccd_n                => pulse_ccd_n,
      LTC2945_SCL                => LTC2945_SCL,
      LTC2945_SDA                => LTC2945_SDA,
      DREB_temp_sda              => DREB_temp_sda,
      DREB_temp_scl              => DREB_temp_scl,
      Temp_adc_scl_ccd           => Temp_adc_scl_ccd,
      Temp_adc_sda_ccd           => Temp_adc_sda_ccd,
      csb_24ADC                  => csb_24ADC,
      sclk_24ADC                 => sclk_24ADC,
      din_24ADC                  => din_24ADC,
      dout_24ADC                 => dout_24ADC,
      aspic_t_v_miso             => aspic_t_v_miso,
      aspic_t_v_mosi             => aspic_t_v_mosi,
      aspic_t_v_ss_ccd           => aspic_t_v_ss_ccd,
      aspic_t_v_sclk             => aspic_t_v_sclk,
      ldac_RAILS                 => ldac_RAILS,
      din_RAILS                  => din_RAILS,
      sclk_RAILS                 => sclk_RAILS,
      sync_RAILS_dac             => sync_RAILS_dac,
      sync_C_BIAS                => sync_C_BIAS,
      din_C_BIAS                 => din_C_BIAS,
      ldac_C_BIAS                => ldac_C_BIAS,
      sclk_C_BIAS                => sclk_C_BIAS,
      ck_adc_EOC                 => ck_adc_EOC,
      ccd_adc_EOC                => ccd_adc_EOC,
      slow_adc_data_from_adc_dcr => slow_adc_data_from_adc_dcr,
      slow_adc_data_from_adc     => slow_adc_data_from_adc,
      ck_adc_CS                  => ck_adc_CS,
      ccd_adc_CS                 => ccd_adc_CS,
      slow_adc_RD                => slow_adc_RD,
      slow_adc_WR                => slow_adc_WR,
      ck_adc_CONVST              => ck_adc_CONVST,
      ccd_adc_CONVST             => ccd_adc_CONVST,
      ck_adc_SHDN                => ck_adc_SHDN,
      ccd_adc_SHDN               => ccd_adc_SHDN,
      ru_outSpiCsB               => ru_outSpiCsB,
      ru_outSpiMosi              => ru_outSpiMosi,
      ru_inSpiMiso               => ru_inSpiMiso,
      ru_outSpiWpB               => ru_outSpiWpB,
      ru_outSpiHoldB             => ru_outSpiHoldB,
      r_add                      => r_add,
      TEST                       => TEST,
      Pwron_Rst_L                => Pwron_Rst_L,
      ccd_clk_en_out_p           => ccd_clk_en_out_p,
      ccd_clk_en_out_n           => ccd_clk_en_out_n,
      ASPIC_ref_sd_ccd           => ASPIC_ref_sd_ccd,
      ASPIC_5V_sd_ccd            => ASPIC_5V_sd_ccd,
      gpio_0_p                   => gpio_0_p,
      gpio_0_n                   => gpio_0_n,
      gpio_0_dir                 => gpio_0_dir,
      gpio_1_p                   => gpio_1_p,
      gpio_1_n                   => gpio_1_n,
      gpio_1_dir                 => gpio_1_dir,
      gpio_2                     => gpio_2,
      reb_sn_onewire             => reb_sn_onewire
    );

end architecture Behavioral;

