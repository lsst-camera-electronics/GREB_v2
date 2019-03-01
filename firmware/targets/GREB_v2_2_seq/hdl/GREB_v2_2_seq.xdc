



#### Timing constraints ####

#### Define input clocks ####

# clock from the quartz (250 MHz)
create_clock -period 4.000 -name PgpRefClk_P -waveform {0.000 2.000} [get_ports PgpRefClk_P]

# GTX RX reconstructed clock (156.25 MHz)
create_clock -period 6.400 -name RXOUTCLK_0 -waveform {0.000 3.200} [get_pins LsstSci_0/LsstPgpFrontEnd_Inst/Pgp2bGtx7Fixedlat_Inst/Gtx7Core_1/gtxe2_i/RXOUTCLK]

# GTX TX reconstructed clock (156.25 MHz)
create_clock -period 6.400 -name TXOUTCLK_0 -waveform {0.000 3.200} [get_pins LsstSci_0/LsstPgpFrontEnd_Inst/Pgp2bGtx7Fixedlat_Inst/Gtx7Core_1/gtxe2_i/TXOUTCLK]

#### Renaming Generated clocks (report clock network to see unconstrained clk) ####

# local clock for front end (100 MHz from RX reconstructed clock)
create_generated_clock -name clk_100_Mhz -master_clock RXOUTCLK_0 [get_pins dcm_user_clk_0/inst/mmcm_adv_inst/CLKOUT0]

# local clock for front end (25 MHz from RX reconstructed clock)
create_generated_clock -name clk_25_Mhz -master_clock RXOUTCLK_0 [get_pins dcm_user_clk_0/inst/mmcm_adv_inst/CLKOUT1]

#### set clocks interactions ####

#set asynchronous clocks

set_clock_groups -asynchronous -group [get_clocks PgpRefClk_P -include_generated_clocks] -group RXOUTCLK_0 -group TXOUTCLK_0 -group {clk_100_Mhz clk_25_Mhz}

### Pin Assignment ###

## pgp reference clock 
set_property PACKAGE_PIN F6 [get_ports PgpRefClk_P]
set_property PACKAGE_PIN F5 [get_ports PgpRefClk_M]


## PGP serial com lines (Bank 116)
#pgp link 0
set_property PACKAGE_PIN E4 [get_ports PgpRx_p]
set_property PACKAGE_PIN E3 [get_ports PgpRx_m]
set_property PACKAGE_PIN D2 [get_ports PgpTx_p]
set_property PACKAGE_PIN D1 [get_ports PgpTx_m]

#pgp link 1
#set_property PACKAGE_PIN B5 [get_ports PgpRx_m]
#set_property PACKAGE_PIN B6 [get_ports PgpRx_p]
#set_property PACKAGE_PIN A3 [get_ports PgpTx_m]
#set_property PACKAGE_PIN A4 [get_ports PgpTx_p]


#### signals for CCD 1 ####
#CCD1 ADC (Bank 13)
set_property PACKAGE_PIN K26 [get_ports {adc_data_ccd_1[0]}]
set_property PACKAGE_PIN P26 [get_ports {adc_data_ccd_1[1]}]
set_property PACKAGE_PIN L25 [get_ports {adc_data_ccd_1[2]}]
set_property PACKAGE_PIN N24 [get_ports {adc_data_ccd_1[3]}]
set_property PACKAGE_PIN M26 [get_ports {adc_data_ccd_1[4]}]
set_property PACKAGE_PIN P25 [get_ports {adc_data_ccd_1[5]}]
set_property PACKAGE_PIN M20 [get_ports {adc_data_ccd_1[6]}]
set_property PACKAGE_PIN L24 [get_ports {adc_data_ccd_1[7]}]
set_property PACKAGE_PIN R26 [get_ports {adc_data_ccd_1[8]}]
set_property PACKAGE_PIN M25 [get_ports {adc_data_ccd_1[9]}]
set_property PACKAGE_PIN P24 [get_ports {adc_data_ccd_1[10]}]
set_property PACKAGE_PIN N26 [get_ports {adc_data_ccd_1[11]}]
set_property PACKAGE_PIN R25 [get_ports {adc_data_ccd_1[12]}]
set_property PACKAGE_PIN N19 [get_ports {adc_data_ccd_1[13]}]
set_property PACKAGE_PIN M24 [get_ports {adc_data_ccd_1[14]}]
set_property PACKAGE_PIN P19 [get_ports {adc_data_ccd_1[15]}]
set_property PACKAGE_PIN N16 [get_ports adc_cnv_ccd_1]
set_property PACKAGE_PIN K25 [get_ports adc_sck_ccd_1]

#(Bank 13)
set_property PACKAGE_PIN N22 [get_ports adc_buff_pd_ccd_1]

#ASPIC signals (Bank 32)
set_property PACKAGE_PIN Y15 [get_ports ASPIC_r_up_ccd_1_p]
set_property PACKAGE_PIN Y16 [get_ports ASPIC_r_up_ccd_1_n]
set_property PACKAGE_PIN AB14 [get_ports ASPIC_r_down_ccd_1_p]
set_property PACKAGE_PIN AB15 [get_ports ASPIC_r_down_ccd_1_n]
set_property PACKAGE_PIN AC19 [get_ports ASPIC_clamp_ccd_1_p]
set_property PACKAGE_PIN AD19 [get_ports ASPIC_clamp_ccd_1_n]
set_property PACKAGE_PIN AA17 [get_ports ASPIC_reset_ccd_1_p]
set_property PACKAGE_PIN AA18 [get_ports ASPIC_reset_ccd_1_n]

#CCD Clocks signals (Bank 32)
#parallels
set_property PACKAGE_PIN AC14 [get_ports {par_clk_ccd_1_p[0]}]
set_property PACKAGE_PIN AD14 [get_ports {par_clk_ccd_1_n[0]}]
set_property PACKAGE_PIN AA14 [get_ports {par_clk_ccd_1_p[1]}]
set_property PACKAGE_PIN AA15 [get_ports {par_clk_ccd_1_n[1]}]
set_property PACKAGE_PIN AD16 [get_ports {par_clk_ccd_1_p[2]}]
set_property PACKAGE_PIN AE16 [get_ports {par_clk_ccd_1_n[2]}]
set_property PACKAGE_PIN AF19 [get_ports {par_clk_ccd_1_p[3]}]
set_property PACKAGE_PIN AF20 [get_ports {par_clk_ccd_1_n[3]}]
#serials
set_property PACKAGE_PIN AD15 [get_ports {ser_clk_ccd_1_p[0]}]
set_property PACKAGE_PIN AE15 [get_ports {ser_clk_ccd_1_n[0]}]
set_property PACKAGE_PIN AE18 [get_ports {ser_clk_ccd_1_p[1]}]
set_property PACKAGE_PIN AF18 [get_ports {ser_clk_ccd_1_n[1]}]
set_property PACKAGE_PIN AF14 [get_ports {ser_clk_ccd_1_p[2]}]
set_property PACKAGE_PIN AF15 [get_ports {ser_clk_ccd_1_n[2]}]
set_property PACKAGE_PIN AE17 [get_ports reset_gate_ccd_1_p]
set_property PACKAGE_PIN AF17 [get_ports reset_gate_ccd_1_n]

# ASICs SPI control signals
#ASPIC signals  (Bank 13)
set_property PACKAGE_PIN M22 [get_ports ASPIC_spi_mosi_ccd_1]
set_property PACKAGE_PIN R23 [get_ports ASPIC_spi_sclk_ccd_1]
set_property PACKAGE_PIN M21 [get_ports ASPIC_spi_miso_t_ccd_1]
set_property PACKAGE_PIN P20 [get_ports ASPIC_spi_miso_b_ccd_1]
set_property PACKAGE_PIN T25 [get_ports ASPIC_ss_t_ccd_1]
set_property PACKAGE_PIN T20 [get_ports ASPIC_ss_b_ccd_1]
set_property PACKAGE_PIN T24 [get_ports ASPIC_spi_reset_ccd_1]
set_property PACKAGE_PIN R22 [get_ports ASPIC_nap_ccd_1]


##### CCD 2 #####

#CCD 2 ADC (Bank 15)
set_property PACKAGE_PIN B16 [get_ports {adc_data_ccd_2[0]}]
set_property PACKAGE_PIN A19 [get_ports {adc_data_ccd_2[1]}]
set_property PACKAGE_PIN A17 [get_ports {adc_data_ccd_2[2]}]
set_property PACKAGE_PIN B19 [get_ports {adc_data_ccd_2[3]}]
set_property PACKAGE_PIN C18 [get_ports {adc_data_ccd_2[4]}]
set_property PACKAGE_PIN D16 [get_ports {adc_data_ccd_2[5]}]
set_property PACKAGE_PIN G16 [get_ports {adc_data_ccd_2[6]}]
set_property PACKAGE_PIN F15 [get_ports {adc_data_ccd_2[7]}]
set_property PACKAGE_PIN A18 [get_ports {adc_data_ccd_2[8]}]
set_property PACKAGE_PIN B17 [get_ports {adc_data_ccd_2[9]}]
set_property PACKAGE_PIN C19 [get_ports {adc_data_ccd_2[10]}]
set_property PACKAGE_PIN C17 [get_ports {adc_data_ccd_2[11]}]
set_property PACKAGE_PIN D15 [get_ports {adc_data_ccd_2[12]}]
set_property PACKAGE_PIN H16 [get_ports {adc_data_ccd_2[13]}]
set_property PACKAGE_PIN G15 [get_ports {adc_data_ccd_2[14]}]
set_property PACKAGE_PIN J15 [get_ports {adc_data_ccd_2[15]}]
set_property PACKAGE_PIN K15 [get_ports adc_cnv_ccd_2]
set_property PACKAGE_PIN C16 [get_ports adc_sck_ccd_2]

#(Bank 13)
set_property PACKAGE_PIN R21 [get_ports adc_buff_pd_ccd_2]

#ASPIC signals (Bank 33)
set_property PACKAGE_PIN AB7  [get_ports ASPIC_r_up_ccd_2_p]
set_property PACKAGE_PIN AC7  [get_ports ASPIC_r_up_ccd_2_n]
set_property PACKAGE_PIN AA9  [get_ports ASPIC_r_down_ccd_2_p]
set_property PACKAGE_PIN AB9  [get_ports ASPIC_r_down_ccd_2_n]
set_property PACKAGE_PIN AB11 [get_ports ASPIC_clamp_ccd_2_p]
set_property PACKAGE_PIN AC11 [get_ports ASPIC_clamp_ccd_2_n]
set_property PACKAGE_PIN AC9  [get_ports ASPIC_reset_ccd_2_p]
set_property PACKAGE_PIN AD9  [get_ports ASPIC_reset_ccd_2_n]

#CCD Clocks signals (Bank 33)
#paralles
set_property PACKAGE_PIN AC8 [get_ports {par_clk_ccd_2_p[0]}]
set_property PACKAGE_PIN AD8 [get_ports {par_clk_ccd_2_n[0]}]
set_property PACKAGE_PIN AA8 [get_ports {par_clk_ccd_2_p[1]}]
set_property PACKAGE_PIN AA7 [get_ports {par_clk_ccd_2_n[1]}]
set_property PACKAGE_PIN AE7 [get_ports {par_clk_ccd_2_p[2]}]
set_property PACKAGE_PIN AF7 [get_ports {par_clk_ccd_2_n[2]}]
set_property PACKAGE_PIN V9  [get_ports {par_clk_ccd_2_p[3]}]
set_property PACKAGE_PIN W8  [get_ports {par_clk_ccd_2_n[3]}]
#serials
set_property PACKAGE_PIN Y11 [get_ports {ser_clk_ccd_2_p[0]}]
set_property PACKAGE_PIN Y10 [get_ports {ser_clk_ccd_2_n[0]}]
set_property PACKAGE_PIN Y8  [get_ports {ser_clk_ccd_2_p[1]}]
set_property PACKAGE_PIN Y7  [get_ports {ser_clk_ccd_2_n[1]}]
set_property PACKAGE_PIN W10 [get_ports {ser_clk_ccd_2_p[2]}]
set_property PACKAGE_PIN W9  [get_ports {ser_clk_ccd_2_n[2]}]
set_property PACKAGE_PIN V8  [get_ports reset_gate_ccd_2_p]
set_property PACKAGE_PIN V7  [get_ports reset_gate_ccd_2_n]

# ASICs SPI control signals
#ASPIC signals  (Bank )
set_property PACKAGE_PIN E16 [get_ports ASPIC_spi_mosi_ccd_2]
set_property PACKAGE_PIN N17 [get_ports ASPIC_spi_sclk_ccd_2]
set_property PACKAGE_PIN G17 [get_ports ASPIC_spi_miso_t_ccd_2]
set_property PACKAGE_PIN F18 [get_ports ASPIC_spi_miso_b_ccd_2]
set_property PACKAGE_PIN D19 [get_ports ASPIC_ss_t_ccd_2]
set_property PACKAGE_PIN D20 [get_ports ASPIC_ss_b_ccd_2]
set_property PACKAGE_PIN H18 [get_ports ASPIC_spi_reset_ccd_2]
set_property PACKAGE_PIN H17 [get_ports ASPIC_nap_ccd_2]

#(Bank15)
set_property PACKAGE_PIN J19 [get_ports backbias_clamp]
set_property PACKAGE_PIN L19 [get_ports backbias_ssbe]

#(Bank32)
set_property PACKAGE_PIN AB17 [get_ports pulse_ccd_1_p]
set_property PACKAGE_PIN AC17 [get_ports pulse_ccd_1_n]
set_property PACKAGE_PIN AB12 [get_ports pulse_ccd_2_p]
set_property PACKAGE_PIN AC12 [get_ports pulse_ccd_2_n]

# DREB V & I sensors (Bank 14)
set_property PACKAGE_PIN G24 [get_ports LTC2945_SCL]
set_property PACKAGE_PIN F24 [get_ports LTC2945_SDA]

#Temperature probes
# dreb temp sens (Bank 14)
set_property PACKAGE_PIN G26 [get_ports DREB_temp_sda]
set_property PACKAGE_PIN G25 [get_ports DREB_temp_scl]
# ccd1 PCB temp probes (Bank 13)
set_property PACKAGE_PIN R20 [get_ports Temp_adc_scl_ccd_1]
set_property PACKAGE_PIN T22 [get_ports Temp_adc_sda_ccd_1]
# ccd2 temp probes (Bank 15)
set_property PACKAGE_PIN K18 [get_ports Temp_adc_scl_ccd_2]
set_property PACKAGE_PIN M16 [get_ports Temp_adc_sda_ccd_2]

##CCD temperatures (Bank 14)
set_property PACKAGE_PIN B26 [get_ports csb_24ADC]
set_property PACKAGE_PIN A23 [get_ports sclk_24ADC]
set_property PACKAGE_PIN A24 [get_ports din_24ADC]
set_property PACKAGE_PIN D26 [get_ports dout_24ADC]

# ASPICs temp and voltage ADC
set_property PACKAGE_PIN H26 [get_ports aspic_t_v_miso]
set_property PACKAGE_PIN C26 [get_ports aspic_t_v_mosi]
set_property PACKAGE_PIN AE22 [get_ports aspic_t_v_ss_ccd1]
set_property PACKAGE_PIN AF22 [get_ports aspic_t_v_ss_ccd2]
set_property PACKAGE_PIN J24 [get_ports aspic_t_v_sclk]

##### DAC ####
##clock rails DAC (Bank 14)
set_property PACKAGE_PIN E21 [get_ports ldac_RAILS]
set_property PACKAGE_PIN E22 [get_ports din_RAILS]
set_property PACKAGE_PIN B21 [get_ports sclk_RAILS]
set_property PACKAGE_PIN C21 [get_ports sync_RAILS_dac0]
set_property PACKAGE_PIN D23 [get_ports sync_RAILS_dac1]

##clock rails DAC (Bank 14)
set_property PACKAGE_PIN J25 [get_ports sync_ccd1_C_BIAS]
set_property PACKAGE_PIN L22 [get_ports sync_ccd2_C_BIAS]
set_property PACKAGE_PIN J23 [get_ports din_C_BIAS]
set_property PACKAGE_PIN L23 [get_ports ldac_C_BIAS]
set_property PACKAGE_PIN K23 [get_ports sclk_C_BIAS]

### max 11056 bias slow adc
set_property PACKAGE_PIN Y26  [get_ports ck_adc_EOC]
set_property PACKAGE_PIN T18  [get_ports ccd1_adc_EOC]
set_property PACKAGE_PIN L18  [get_ports ccd2_adc_EOC]
set_property PACKAGE_PIN W23  [get_ports {slow_adc_data_from_adc_dcr[0]}]
set_property PACKAGE_PIN AB25 [get_ports {slow_adc_data_from_adc_dcr[1]}]
set_property PACKAGE_PIN AA25 [get_ports {slow_adc_data_from_adc_dcr[2]}]
set_property PACKAGE_PIN W21  [get_ports {slow_adc_data_from_adc_dcr[3]}]
set_property PACKAGE_PIN V21  [get_ports {slow_adc_data_from_adc[4]}]
set_property PACKAGE_PIN W26  [get_ports {slow_adc_data_from_adc[5]}]
set_property PACKAGE_PIN W25  [get_ports {slow_adc_data_from_adc[6]}]
set_property PACKAGE_PIN V26  [get_ports {slow_adc_data_from_adc[7]}]
set_property PACKAGE_PIN U26  [get_ports {slow_adc_data_from_adc[8]}]
set_property PACKAGE_PIN V24  [get_ports {slow_adc_data_from_adc[9]}]
set_property PACKAGE_PIN V23  [get_ports {slow_adc_data_from_adc[10]}]
set_property PACKAGE_PIN U25  [get_ports {slow_adc_data_from_adc[11]}]
set_property PACKAGE_PIN U24  [get_ports {slow_adc_data_from_adc[12]}]
set_property PACKAGE_PIN V22  [get_ports {slow_adc_data_from_adc[13]}]
set_property PACKAGE_PIN U22  [get_ports {slow_adc_data_from_adc[14]}]
set_property PACKAGE_PIN U21  [get_ports {slow_adc_data_from_adc[15]}]

set_property PACKAGE_PIN AC26 [get_ports ck_adc_CS]
set_property PACKAGE_PIN U19  [get_ports ccd1_adc_CS]
set_property PACKAGE_PIN K17  [get_ports ccd2_adc_CS]
set_property PACKAGE_PIN AB26 [get_ports slow_adc_RD]
set_property PACKAGE_PIN W24  [get_ports slow_adc_WR]
set_property PACKAGE_PIN Y25  [get_ports ck_adc_CONVST]
set_property PACKAGE_PIN U20  [get_ports ccd1_adc_CONVST]
set_property PACKAGE_PIN M17  [get_ports ccd2_adc_CONVST]
set_property PACKAGE_PIN AA23 [get_ports ck_adc_SHDN]
set_property PACKAGE_PIN T19  [get_ports ccd1_adc_SHDN]
set_property PACKAGE_PIN L17  [get_ports ccd2_adc_SHDN]

#### Remote Update
#Bank 14
set_property PACKAGE_PIN C23 [get_ports ru_outSpiCsB]
set_property PACKAGE_PIN B24 [get_ports ru_outSpiMosi]
set_property PACKAGE_PIN A25 [get_ports ru_inSpiMiso]
set_property PACKAGE_PIN B22 [get_ports ru_outSpiWpB]
set_property PACKAGE_PIN A22 [get_ports ru_outSpiHoldB]

### misc signals ###

#Resistors to define board address (Bank 13)
set_property PACKAGE_PIN R16 [get_ports {r_add[0]}]
set_property PACKAGE_PIN R17 [get_ports {r_add[1]}]
set_property PACKAGE_PIN N18 [get_ports {r_add[2]}]
set_property PACKAGE_PIN M19 [get_ports {r_add[3]}]
set_property PACKAGE_PIN T17 [get_ports {r_add[4]}]
set_property PACKAGE_PIN R18 [get_ports {r_add[5]}]
set_property PACKAGE_PIN P18 [get_ports {r_add[6]}]
set_property PACKAGE_PIN U16 [get_ports {r_add[7]}]

#(Bank 14)
set_property PACKAGE_PIN H21 [get_ports {TEST[0]}]
set_property PACKAGE_PIN G21 [get_ports {TEST[1]}]
set_property PACKAGE_PIN H23 [get_ports {TEST[2]}]
set_property PACKAGE_PIN H24 [get_ports {TEST[3]}]


# Power on reset (Bank 16)
set_property PACKAGE_PIN N21 [get_ports Pwron_Rst_L]

# CCD clocks enable (Bank 32)
set_property PACKAGE_PIN Y17  [get_ports ccd1_clk_en_out_p]
set_property IOSTANDARD LVDS [get_ports  ccd1_clk_en_out_p]
set_property PACKAGE_PIN Y18  [get_ports ccd1_clk_en_out_n]
set_property IOSTANDARD LVDS [get_ports  ccd1_clk_en_out_n]
set_property PACKAGE_PIN AD11 [get_ports ccd2_clk_en_out_p]
set_property IOSTANDARD LVDS [get_ports  ccd2_clk_en_out_p]
set_property PACKAGE_PIN AE11 [get_ports ccd2_clk_en_out_n]
7 gtx manualset_property IOSTANDARD LVDS [get_ports  ccd2_clk_en_out_n]

#ASPIC reference enable (Bank 14)
set_property PACKAGE_PIN D24 [get_ports ASPIC_ref_sd_ccd1]

#ASPIC 5V enable 
set_property PACKAGE_PIN E23 [get_ports ASPIC_5V_sd_ccd1]

#ASPIC reference enable (Bank 14)
set_property PACKAGE_PIN E25 [get_ports ASPIC_ref_sd_ccd2]

#ASPIC 5V enable 
set_property PACKAGE_PIN D25 [get_ports ASPIC_5V_sd_ccd2]

#REB serial number (Bank 16)
set_property PACKAGE_PIN N23 [get_ports reb_sn_onewire]

# GPIOs
set_property PACKAGE_PIN V16 [get_ports gpio_0_p]
set_property IOSTANDARD LVDS [get_ports gpio_0_p]
set_property PACKAGE_PIN V17 [get_ports gpio_0_n]
set_property IOSTANDARD LVDS [get_ports gpio_0_n]
set_property PACKAGE_PIN AD25 [get_ports gpio_0_dir]
set_property IOSTANDARD LVCMOS33 [get_ports gpio_0_dir]

set_property PACKAGE_PIN W18 [get_ports gpio_1_p]
set_property IOSTANDARD LVDS [get_ports gpio_1_p]
set_property PACKAGE_PIN W19 [get_ports gpio_1_n]
set_property IOSTANDARD LVDS [get_ports gpio_1_n]
set_property PACKAGE_PIN AE25 [get_ports gpio_1_dir]
set_property IOSTANDARD LVCMOS33 [get_ports gpio_1_dir]

set_property PACKAGE_PIN C24 [get_ports gpio_2]
set_property IOSTANDARD LVCMOS33 [get_ports gpio_2]

#### set voltages ####

set_property IOSTANDARD LVDS [get_ports ASPIC_r*]
set_property IOSTANDARD LVDS [get_ports ASPIC_clamp*]
set_property IOSTANDARD LVDS [get_ports par_clk*]
set_property IOSTANDARD LVDS [get_ports ser_clk*]
set_property IOSTANDARD LVDS [get_ports reset_gate*]
set_property IOSTANDARD LVDS [get_ports pulse_ccd*]
#set_property IOSTANDARD LVDS [get_ports ccd1_clk_en*]
#set_property IOSTANDARD LVDS [get_ports ccd2_clk_en*]



set_property IOSTANDARD LVCMOS33 [get_ports *adc_*]
set_property IOSTANDARD LVCMOS33 [get_ports ASPIC_spi*]
set_property IOSTANDARD LVCMOS33 [get_ports ASPIC_ss_*]
set_property IOSTANDARD LVCMOS33 [get_ports ASPIC_nap_ccd_*]
set_property IOSTANDARD LVCMOS33 [get_ports backbias*]
set_property IOSTANDARD LVCMOS33 [get_ports LTC2945*]
set_property IOSTANDARD LVCMOS33 [get_ports DREB*]
set_property IOSTANDARD LVCMOS33 [get_ports Temp_adc*]
set_property IOSTANDARD LVCMOS33 [get_ports *24ADC]
set_property IOSTANDARD LVCMOS33 [get_ports aspic_t*]
set_property IOSTANDARD LVCMOS33 [get_ports *RAILS*]
set_property IOSTANDARD LVCMOS33 [get_ports *C_BIAS]
set_property IOSTANDARD LVCMOS33 [get_ports r_add*]
set_property PULLUP true [get_ports r_add*]
set_property IOSTANDARD LVCMOS33 [get_ports TEST*]
set_property IOSTANDARD LVCMOS33 [get_ports Pwron_Rst_L]
set_property IOSTANDARD LVCMOS33 [get_ports ASPIC_ref*]
set_property IOSTANDARD LVCMOS33 [get_ports ASPIC_5*]
set_property IOSTANDARD LVCMOS33 [get_ports reb_sn_onewire]
set_property IOSTANDARD LVCMOS33 [get_ports ru_*]


#### set flash SPI speed ####
#more command options are in UG908 programming and debugging appendix A 

set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design] 

# set SPI bus width during boot 
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]

## set Flash SPI address width
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR YES [current_design]

## set multiboot config
#enalble fallback
set_property BITSTREAM.CONFIG.CONFIGFALLBACK ENABLE [current_design]

## watchdog for triggeringring the fallback reboot in  case of error 
set_property BITSTREAM.CONFIG.TIMER_CFG 0x4007A120 [current_design]

# set jump address at boot time. The FPGA duirng boot will jup to this address
#and load the image that starts form there 
#set_property BITSTREAM.CONFIG.NEXT_CONFIG_ADDR 32'h00800000 [current_design]

#### set hardware configuration ####
## setting to avoid warning CFGBVS in vivado DRC

set_property CFGBVS VCCO         [current_design]
set_property CONFIG_VOLTAGE 3.3  [current_design]