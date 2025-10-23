library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.memPkg.all;

entity ram_tb is
end ram_tb;

architecture test of ram_tb is
    -- Komponente des RAM-Moduls
    component ramIO
        generic (	addrWd	: integer range 2 to 16	:= 8;
		dataWd	: integer range 2 to 32	:= 32;
		fileId	: string  := "work/memoryram.dat"); 
    port ( --	nCS	: in    std_logic;
		nWE	: in    std_logic;
	        addr	: in    std_logic_vector(addrWd-1 downto 0);
	        dataI	: in	std_logic_vector(dataWd-1 downto 0);
	        dataO	: out	std_logic_vector(dataWd-1 downto 0);
	        fileIO	: in	fileIoT := none);
    end component;

signal nWE     : std_logic := '1';  
signal addr    : std_logic_vector(7 downto 0) := (others => '0');  
signal dataI   : std_logic_vector(31 downto 0) := (others => '0');  
signal dataO   : std_logic_vector(31 downto 0);  
signal fileIO  : fileIoT := none;  

begin
    -- Instanz des RAM-Moduls
    uut: ramIO
    generic map (
        addrWd => 8,  
        dataWd => 32,  
        fileId => "work/memoryram.dat"
    )
    port map (
        nWE   => nWE,       
        addr  => addr,
        dataI => dataI,  
        dataO => dataO,  
        fileIO => fileIO
    );

    -- Testprozess
    process
    begin
        -- ?? Warte auf Initialisierung
        wait for 20 ns;

        -- ?? Schreibe Wert 0x1234 an Adresse 0x05
        addr   <= "00000101";  
        dataI  <= std_logic_vector(to_unsigned(16#1234#, 32));  -- 32 Bit Wert (0x1234)
        nWE    <= '0';  -- Schreibmodus aktivieren
        wait for 10 ns;

        -- ?? Schreibmodus deaktivieren
        nWE    <= '1';
        wait for 10 ns;

        -- ?? Speicherinhalt in Datei `memoryram.dat` speichern
        fileIO <= dump;
        wait for 10 ns;
        fileIO <= none;  -- Zurücksetzen

        -- ?? Lese den gespeicherten Wert aus Adresse 0x05
        addr   <= "00000101";  
        wait for 10 ns;

        -- ?? Debugging-Ausgabe
        report "Daten an Adresse 0x05 = " & integer'image(to_integer(unsigned(dataO)));

        -- ?? Testende (Fehlerbehebung: `severity note` statt `failure`)
        wait for 50 ns;
        report "Test beendet." severity note;
        wait;
    end process;

end test;