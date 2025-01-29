library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reg is 
  port (clk : in std_logic; --takt
        dIn : in signed(31 downto 0); --input (data)
        dOut : out signed(31 downto 0)); --output (data)
end entity reg;

architecture behaviour of reg is 
  begin 
    reg_p: process (clk) is
      begin 
        if rising_edge(clk) then dOut <= dIn;                                
      end if;
    end process reg_p;
  end architecture behaviour;

