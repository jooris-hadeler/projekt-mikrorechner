-- mehrerer prozesse
-- def mult integer values, set entsprechend clk [write log, bit muss true sein für access]
-- intra prozess: zwei prozesse für multiplexer, demultiplexer
-- intra prozess: write [vorerste auslassen, keep in mind tho]

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registerbank is 
    port(clk : in std_logic;
        dIn : in signed(31 downto 0); --input
        dOutA : out signed(31 downto 0); --outputA
        dOutB : out signed(31 downto 0); --outputB
        selA : in STD_LOGIC_VECTOR(4 downto 0); --Registernr für dOutA
        selB : in STD_LOGIC_VECTOR(4 downto 0); --Registernr für dOutB
        selD : in STD_LOGIC_VECTOR(4 downto 0); --Registernr für dIn
        wE : in std_logic);
end entity registerbank; 

architecture behaviour of registerbank is 
    type regArray is array(0 to 31) of signed(31 downto 0);
    signal registers : regArray;
begin
      reg_mult : process (selA, selB, registers) is
        begin 
            dOutA <= registers(to_integer(unsigned(selA)));
            dOutB <= registers(to_integer(unsigned(selB)));
    end process reg_mult;

      reg_demult : process (clk, dIn, selD, wE, registers) is
        begin 
            if rising_edge(clk) AND (wE = '1') then registers(to_integer(unsigned(selD))) <= dIn;
        end if;
    end process reg_demult;
    end architecture behaviour;


    --select register über name christopher ist switch hater