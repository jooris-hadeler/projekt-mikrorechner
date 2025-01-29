library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity registerbankTest is 
    generic(	periodC	: time		:= 10 ns;
            cyclesC	: integer	:= 100);
end entity registerbankTest; 


architecture testbench of registerbankTest is

    component registerbank is
        port(clk : in std_logic;
            dIn : in signed(31 downto 0); --input
            dOutA : out signed(31 downto 0); --outputA
            dOutB : out signed(31 downto 0); --outputB
            selA : in STD_LOGIC_VECTOR(4 downto 0); --Registernr für dOutA
            selB : in STD_LOGIC_VECTOR(4 downto 0); --Registernr für dOutB
            selD : in STD_LOGIC_VECTOR(4 downto 0); --Registernr für dIn
            wE : in std_logic);
    end component registerbank; 
    
    signal clk, wE : std_logic;
    signal dIn, dOutA, dOutB : signed(31 downto 0);
    signal selA, selB, selD : STD_LOGIC_VECTOR(4 downto 0);
begin
    registerbankI: registerbank	port map (clk, dIn, dOutA, dOutB, selA, selB, selD, wE);

    registerbankP: process is
        begin
            wE <= '1';
            selA <= STD_LOGIC_VECTOR(to_signed(0, 5));
            selB <= STD_LOGIC_VECTOR(to_signed(10, 5));
            for i in 0 to 31 loop
                selD <= STD_LOGIC_VECTOR(to_signed(i, 5));
                dIn <= to_signed(i, 32);
                clk <= '0';
                wait for periodC;
                clk <= '1'; 
                wait for periodC;
            end loop; 
            
            clk <= '0';
            dIn <= "10101010101010101010101010101010";
            selD <= STD_LOGIC_VECTOR(to_signed(0, 5));
            wE <= '1';
	        wait for periodC;
            clk <= '1';
	        wait for periodC;
            clk <= '0';
            dIn <= "01010101010101010101010101010101";
            selD <= STD_LOGIC_VECTOR(to_signed(10, 5));
            wE <= '1';
	        wait for periodC;
            clk <= '1';
	        wait for periodC;
            wait;
        end process registerbankP;
    end architecture testbench;		


