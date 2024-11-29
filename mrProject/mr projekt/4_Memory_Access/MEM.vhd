library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- memory sim referenzen

-- logisches and oder or in dieser stufe recherchierena
-- kontroll signale in allen stufen überprüfen

entity mem_seg is 
    port (
        pc_in, write_data : in signed(31 downto 0);-- in der stufe auf 16 bit kürzen (hinten bleibt)
        writeE, readE, mem_to_reg_in, reg_write_in, mem_to_reg_MEM, reg_write_MEM  : in std_logic;
        read_data, adress_out, pc_out: out signed(31 downto 0);
        mem_to_reg_WB, reg_write_WB : out std_logic;
    );
end entity mem_seg;

architecture behaviour of mem_seg
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

    signal address, read : signed(31 downto 0);

    begin

        ramIOI: ramIO   generic map (addrWd => 16,
                                     dataWd => 32)
                        port map (writeE, adress, write_data, read);
        signal sel_alu_val, sel_reg_val : signed(4 downto 0);
        mem_seg_process : process (clk) is
            begin
                if rising_edge(clk) then
                    adress_out <= adress_in;;
                    adress <= adress_in(15 downto 0);
                    pc_out <= pc_in;
                    mem_to_reg_out <= mem_to_reg_in;
                    reg_write_out <= reg_write_in;
                    read_data <= read;
            end if;
        end process mem_seg_process;
end behaviour;
