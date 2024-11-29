library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instf_seg is 
    port (
        pc_in : in signed(31 downto 0);
        pc_out, instruction : out signed(31 downto 0);
    );
end entity instf_seg;

architecture behaviour of instf_seg
    component rom is
    generic (	addrWd	: integer range 2 to 16	:= 8;	-- #address bits
		dataWd	: integer range 2 to 32	:= 8;	-- #data    bits
		fileId	: string  := "memory.dat");	-- filename
    port (--	nCS	: in    std_logic;		-- not Chip   Select
	        addr	: in    std_logic_vector(addrWd-1 downto 0);
	        data	: out	std_logic_vector(dataWd-1 downto 0);
	        fileIO	: in	fileIoT	:= none);
    end component;

    signal pc : signed(15 downto 0);
    signal instruction_mem : signed(31 downto 0);

    begin
        romI: rom   generic map (addrWd => 16,
                                     dataWd => 32)
                        port map (pc, instruction_mem);
        
        instf_seg_process : process (clk) is
            begin
                if rising_edge(clk) then
                    pc <= pc_in(15 downto 0);
                    pc_out <= pc_in + 1;
                    instruction <= instruction_mem;
            end if;
        end process instf_seg_process;
end behaviour;

