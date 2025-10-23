library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.env.all;

entity registerbank_tb is 
    generic(	periodC	: time		:= 10 ns;
            cyclesC	: integer	:= 100);
end entity registerbank_tb; 


architecture testbench of registerbank_tb is

    component registerbank is
        port(clk : in std_logic;
            dIn : in signed(31 downto 0); --input
            dOutA : out signed(31 downto 0); --outputA
            dOutB : out signed(31 downto 0); --outputB
            selA : in unsigned(4 downto 0); --Registernr für dOutA
            selB : in unsigned(4 downto 0); --Registernr für dOutB
            selD : in unsigned(4 downto 0); --Registernr für dIn
            wE : in std_logic);
    end component registerbank; 
    
    signal clk : std_logic := '0';
    signal wE  : std_logic := '0';

    signal dIn   : signed(31 downto 0) := (others => '0');
    signal dOutA : signed(31 downto 0);
    signal dOutB : signed(31 downto 0);

    signal selA  : unsigned(4 downto 0) := (others => '0');
    signal selB  : unsigned(4 downto 0) := (others => '0');
    signal selD  : unsigned(4 downto 0) := (others => '0');

begin
    registerbankI: registerbank	port map (clk, dIn, dOutA, dOutB, selA, selB, selD, wE);
    
    -- sauberer Takt
    clk_proc : process
    begin
        clk <= '0';
        wait for periodC/2;
        clk <= '1';
        wait for periodC/2;
    end process;
    
    registerbankP: process is
    
    begin
        -- Startwerte
        wE   <= '0';
        dIn  <= (others => '0');
        selA <= (others => '0');  -- wichtig gegen die Warnung
        selB <= (others => '0');  -- wichtig gegen die Warnung
        selD <= (others => '0');

        -- 2 Takte warten, dann schreiben
        wait for 2*periodC;
        wE <= '1';

        for i in 0 to 31 loop
            selD <= to_unsigned(i, 5);
            dIn <= to_signed(i, 32);
            wait until rising_edge(clk);
        end loop;
           
        --Lese-/Schreibzugriffe testen
        wE <= '1';
        selA <= to_unsigned(0, 5);
        selB <= to_unsigned(10, 5);
        
        dIn <= signed'("10101010101010101010101010101010");
        selD <= to_unsigned(0, 5);
        wait until rising_edge(clk);

        dIn <= signed'("01010101010101010101010101010101");
        selD <= to_unsigned(10, 5);
        wait until rising_edge(clk); 
        
        -- Optional: kurze Checks
        wait for periodC;
        assert dOutA = signed'("10101010101010101010101010101010") 
            report "Reg[0] unerwartet" severity failure;
        assert dOutB = signed'("01010101010101010101010101010101")
            report "Reg[10] unerwartet" severity failure;
	    
        finish;
        end process registerbankP;
    end architecture testbench;		


