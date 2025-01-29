library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alu_opcode.all;

entity IDTest is
    generic(	
        periodC	: time		:= 10 ns;
        cyclesC	: integer	:= 100);
    end entity IDTest;

architecture testbench of IDTest is

    component ID is
        port (
            pc_in, instruction, write_data : in std_logic_vector(31 downto 0);
            clk, reg_wE :                         in std_logic;
            write_reg :                      in std_logic_vector(4 downto 0);
            pc_out, alu_val, reg_val, imm :  out std_logic_vector(31 downto 0);
            alu_op, rd, rt :                 out std_logic_vector(4 downto 0);
            alu_src, reg_dest, mem_to_reg_EX, reg_write_EX :              out std_logic -- weitere kontrollsignale hinzufügen
        );
    end component ID;
    
    signal pc_in_in, instruction_in, write_data_in: STD_LOGIC_VECTOR(31 downto 0);
    signal clk_in, reg_wE_in: std_logic;
    signal write_reg_in: STD_LOGIC_VECTOR(4 downto 0);
    signal pc_out_out, alu_val_out, reg_val_out, imm_out: STD_LOGIC_VECTOR(31 downto 0);
    signal alu_op_out, rd_out, rt_out: STD_LOGIC_VECTOR(4 downto 0);
    signal alu_src_out, reg_dest_out, mem_to_reg_EX_out, reg_write_EX_out: std_logic;
begin
    IDI: ID port map(pc_in_in, instruction_in, write_data_in, clk_in, reg_wE_in, write_reg_in,
        pc_out_out, alu_val_out, reg_val_out, imm_out, alu_op_out, rd_out, rt_out,
        alu_src_out, reg_dest_out, mem_to_reg_EX_out, reg_write_EX_out);

    IDP: process is
    begin
        pc_in_in <= "00000000000000000000000000000001";
        instruction_in <= "00000000000000000000000000000001";
        write_data_in <= "00000000000000000000000000000001";
        reg_wE_in <= '1';
        write_reg_in <= "00001";

        clk_in <= '0';
        wait for periodC;
        clk_in <= '1'; 
        wait for periodC;
        wait;
    end process IDP;
end architecture testbench;		  

