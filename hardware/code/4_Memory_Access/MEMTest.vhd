library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alu_opcode.all;

entity MEMTest is
    generic(	
        periodC	: time		:= 20 ns;
        cyclesC	: integer	:= 100);
    end entity MEMTest;

architecture testbench of MEMTest is
    component MEM is
        port (
            pc_in, adress_in: in std_logic_vector(31 downto 0);-- in der stufe auf 16 bit kürzen (hinten bleibt)
            write_data : in std_logic_vector(31 downto 0);
            clk, writeE, readE, mem_to_reg_in, reg_write_in, mem_to_reg_MEM, reg_write_MEM  : in std_logic;
            read_data, adress_out, pc_out: out std_logic_vector(31 downto 0);
            mem_to_reg_WB, reg_write_WB : out std_logic
        );
    end component MEM;

    signal pc_in_in, adress_in_in: std_logic_vector(31 downto 0);
    signal write_data_in: std_logic_vector(31 downto 0);
    signal clk_in, readE_in, mem_to_reg_in_in, reg_write_in_in, mem_to_reg_MEM_in, reg_write_MEM_in : std_logic;
    signal writeE_in: STD_LOGIC := '1';
    signal read_data_out, adress_out_out, pc_out_out: std_logic_vector(31 downto 0);
    signal mem_to_reg_WB_out, reg_write_WB_out: std_logic;
begin
    MEMI: MEM port map (pc_in_in, adress_in_in, write_data_in, clk_in, writeE_in, readE_in, mem_to_reg_in_in, reg_write_in_in, mem_to_reg_MEM_in, reg_write_MEM_in,
        read_data_out, adress_out_out, pc_out_out, mem_to_reg_WB_out, reg_write_WB_out);
    MEMP: process is
    begin
        pc_in_in <= STD_LOGIC_VECTOR(to_signed(1, 32));
        adress_in_in <= STD_LOGIC_VECTOR(to_signed(1, 32));

        write_data_in <= "00000000000000000000000000000001";

        readE_in <= '1';
        mem_to_reg_in_in <= '1';
        reg_write_in_in <= '1';
        mem_to_reg_MEM_in <= '1';
        reg_write_MEM_in <= '1';
        
        clk_in <= '0';
        wait for periodC;
        writeE_in <= '0';
        clk_in <= '1'; 
        wait for periodC;
        clk_in <= '0';
        wait for periodC;
        clk_in <= '1'; 
        wait for periodC;
        writeE_in <= '1';
        wait;
    end process MEMP;
end architecture testbench;		  
