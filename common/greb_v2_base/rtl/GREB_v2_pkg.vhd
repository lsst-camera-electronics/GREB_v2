library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library surf;
use surf.StdRtlPkg.all;

package GREB_v2_pkg is

  constant NUM_SENSORS_C : integer := 2;

  type RebVersionType is record
    schema       : std_logic_vector(31 downto 0);
    board_type   : std_logic_vector( 3 downto 0);
    vhdl_version : std_logic_vector(15 downto 0);
    reserved_1   : std_logic_vector(31 downto 0);
    reserved_2   : std_logic_vector(31 downto 0);
    reserved_3   : std_logic_vector(31 downto 0);
  end record RebVersionType;

  -- this will get removed
  constant GREB_VERSION_C : RebVersionType := (
    schema        => x"00000001",
    board_type    => x"2",
    vhdl_version  => x"2110",
    reserved_1    => x"00000000",
    reserved_2    => x"00000000",
    reserved_3    => x"00000000"
  );

  type RebConfigType is record
    numSequencers : integer range 1 to NUM_SENSORS_C;
    gdAddr        : std_logic_vector(3 downto 0);
    odAddr        : std_logic_vector(3 downto 0);
    rdAddr        : std_logic_vector(3 downto 0);
    gdThresh      : IntegerArray(0 to NUM_SENSORS_C-1);  -- Fixed size for simplicity
    odThresh      : IntegerArray(0 to NUM_SENSORS_C-1);
    rdThresh      : IntegerArray(0 to NUM_SENSORS_C-1);
  end record RebConfigType;

  constant GREB_CONFIG_DEFAULT_C : RebConfigType := (
    numSequencers => 1,
    gdAddr   => x"0",
    odAddr   => x"5",
    rdAddr   => x"1",
    gdThresh => (1138, 1138),
    odThresh => (2275, 2275),
    rdThresh => (1632, 1632)
    --    Sensor(   0,    1)
  );

end package GREB_v2_pkg;
