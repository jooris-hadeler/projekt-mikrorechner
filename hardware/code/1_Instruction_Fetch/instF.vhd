library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memPkg.all;        -- Import des gesamten Packages memPkg

entity instF is -- Schnittstelle des Instruction-Fetch
    port (
        pc_in : in std_logic_vector(31 downto 0); -- Eingabe des aktuellen PC Counts
        pc_out: out std_logic_vector(31 downto 0); -- Ausgabe des inkrementierten PC Counts
        instruction: out std_logic_vector (31 downto 0);-- Die gelesene Instruction aus dem ROM
        clk : in std_logic -- Takt-Signal
    );
end instF;

architecture behaviour of instF

is component rom is
    generic (
        addrWd	: integer range 2 to 16 := 16;	-- anzahl der speicher bereiche 2^16
		dataWd	: integer range 2 to 32 := 32;	-- bitbreite pro speicheradresse 32bit
		fileId	: string  := "memory.dat");	-- filename

    port (--	nCS	: in    std_logic;		-- not Chip Select 
	        addr	: in    std_logic_vector(15 downto 0);-- Eingabeadresse des ROMs
	        data	: out	std_logic_vector(31 downto 0);-- Ausgabeadresse des ROMs
	        fileIO	: in	fileIoT
         );
    end component;

    signal addrin : std_logic_vector(15 downto 0); --Leitung for pc_in zu ROM 
    signal instruction_mem : std_logic_vector(31 downto 0); --Leitung for ROM zu instruction
    
    begin
        romI: rom   
            generic map (
            addrWd => 16, --ROM Initialisierung 
            dataWd => 32) 
             
            port map (
                addr => addrin,              -- Adresseingang des ROMs
                data => instruction_mem,  -- Datenausgang des ROMs
                fileIO => none
            );
                                
        instf_seg_process : process (clk) is
        variable result : unsigned(31 downto 0);
        
        begin
            if rising_edge(clk) then --check ob Flanke von clk = 0 -> 1

                addrin <= pc_in(15 downto 0); --Nutzt die unteren 16 bits als adresse for pc 
                result := unsigned(pc_in) + 1;
                pc_out <= std_logic_vector(result); --increase pc count um 1
                instruction <= instruction_mem; --instruction wird auf den aus ROM geladenen Befehl gesetzt
                
        end if;
    end process instf_seg_process;
end behaviour;

