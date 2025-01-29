library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.memPkg.all;
--library work;
-- memory sim referenzen

-- logisches and oder or in dieser stufe recherchierena
-- kontroll signale in allen stufen überprüfen

entity MEM is 
    port (
        pc_in, adress_in: in std_logic_vector(31 downto 0);-- in der stufe auf 16 bit kürzen (hinten bleibt)
        write_data : in std_logic_vector(31 downto 0);
        clk, writeE, readE, mem_to_reg_in, reg_write_in, mem_to_reg_MEM, reg_write_MEM  : in std_logic;
        read_data, adress_out, pc_out: out std_logic_vector(31 downto 0);
        mem_to_reg_WB, reg_write_WB : out std_logic
    );
end entity MEM;

architecture behaviour of MEM is
    component ramIO is
    generic (
        addrWd	: integer range 2 to 16	:= 8;	-- #address bits
		dataWd	: integer range 2 to 32	:= 8;	-- #data    bits
		fileId	: string  := "memory.dat"
    );
    port (--	nCS	: in    std_logic;		-- not Chip   Select
		nWE	: in    std_logic;		-- not Write  Enable
        addr	: in    std_logic_vector(addrWd-1 downto 0);
        dataI	: in	std_logic_vector(dataWd-1 downto 0);
        dataO	: out	std_logic_vector(dataWd-1 downto 0);
        fileIO	: in	fileIoT	:= none);
    end component;

    signal nWE: STD_LOGIC := '1';
    signal read: std_logic_vector(31 downto 0);
    signal adress : std_logic_vector(15 downto 0);
    signal sel_alu_val, sel_reg_val : std_logic_vector(4 downto 0);
    signal fileIO_in: fileIoT := none;
    
    begin

        ramIOI: ramIO   generic map (addrWd => 16,
                                     dataWd => 32,
                                     fileID => "memoryram.dat")
                        port map (nWE, adress, write_data, read, fileIO_in);
        nWE <= writeE;
        mem_seg_process : process (clk) is
            begin
                if rising_edge(clk) then
                    adress_out <= adress_in;
                    adress <= adress_in(15 downto 0);
                    pc_out <= pc_in;
                    mem_to_reg_WB <= mem_to_reg_in;
                    reg_write_WB <= reg_write_in;
                    read_data <= std_logic_vector(read);
                    if writeE = '0' then
                        fileIO_in <= dump;
                    end if;
                else
                    fileIO_in <= none;
                end if;
        end process mem_seg_process;
end behaviour;
