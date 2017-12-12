----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:24:22 09/17/2013 
-- Design Name: 
-- Module Name:    mux_4_1_clk - Behavioral 
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

entity mux_4_1_clk is

  port (
    reset    : in std_logic;            -- syncronus reset
    clk      : in std_logic;            -- clock
    selector : in std_logic_vector(1 downto 0);
    in_0     : in std_logic;
    in_1     : in std_logic;
    in_2     : in std_logic;
    in_3     : in std_logic;

    output : out std_logic
    );

end mux_4_1_clk;

architecture Behavioral of mux_4_1_clk is

begin


  process (clk)
  begin
    if clk'event and clk = '1' then     -- rising clock edge
      if reset = '1' then               -- synchronous reset 
        output <= in_0;
      else
        case selector is
          when "00" => output <= in_0;
          when "01" => output <= in_1;
          when "10" => output <= in_2;
          when "11" => output <= in_3;

          when others => output <= in_0;
                         
        end case;
      end if;
    end if;
  end process;


end Behavioral;

