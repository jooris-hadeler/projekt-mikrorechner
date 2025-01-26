library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alu_opcode.all;

entity EXTest is
    generic(	
        periodC	: time		:= 10 ns;
        cyclesC	: integer	:= 100);
    end entity EXTest;

architecture testbench of EXTest is

    component EX is
        port (
            imm, pc, alu_val, reg_val: in signed(31 downto 0);
            opcode, rt, rd: in signed(4 downto 0);
            clk, mux_sel, write_sel, wE, rE, mem_to_reg_EX, reg_write_EX: in std_logic;        
            pc_offs, out_result, data: out signed(31 downto 0);
            write_reg: out signed(4 downto 0);
            wE_out, rE_out, mem_to_reg_MEM, reg_write_MEM : out std_logic);
    end component EX;
    
    signal imm_in, pc_in, alu_val_in, reg_val_in: signed(31 downto 0);
    signal opcode_in, rt_in, rd_in:  signed(4 downto 0);
    signal clk_in, mux_sel_in, write_sel_in, wE_in, rE_in, mem_to_reg_EX_in, reg_write_EX_in: std_logic;
    signal pc_offs_out, out_result_out, data_out: signed(31 downto 0);
    signal write_reg_out: signed(4 downto 0); 
    signal wE_out_out, rE_out_out, mem_to_reg_MEM_out, reg_write_MEM_out : std_logic;

begin
    EXI: EX	port map (imm_in, pc_in, alu_val_in, reg_val_in, opcode_in, rt_in, rd_in, clk_in, mux_sel_in, write_sel_in, wE_in, rE_in, mem_to_reg_EX_in, reg_write_EX_in,
        pc_offs_out, out_result_out, data_out, write_reg_out, wE_out_out, rE_out_out, mem_to_reg_MEM_out, reg_write_MEM_out);

    EXPr: process is
    begin

        imm_in <= to_signed(1, 32);
        pc_in <= to_signed(1, 32);
        alu_val_in <= to_signed(1, 32);
        reg_val_in <= to_signed(1, 32);

        opcode_in <= to_signed(1, 5);
        rt_in <= to_signed(1, 5);
        rd_in <= to_signed(1, 5);
        
        mux_sel_in <= '1';
        write_sel_in <= '1';
        wE_in <= '1';
        rE_in <= '1';
        mem_to_reg_EX_in <= '1';
        reg_write_EX_in <= '1';

        clk_in <= '0';
        wait for periodC;
        clk_in <= '1'; 
        wait for periodC;
        wait;
    end process EXPr;
end architecture testbench;		  


