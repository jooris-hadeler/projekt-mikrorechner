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
            imm, pc, alu_val, reg_val: in signed(31 downto 0); -- inputs ergänzen
            opcode, rt, rd: in signed(4 downto 0);
            clk_in, mux_sel, write_sel, wE, rE, mem_to_reg_EX, reg_write_EX: in std_logic; -- mux_sel für alu, write_sel für befehls_mux unten bild            
            pc_offs, out_result, data: out signed(31 downto 0);
            write_reg: out signed(4 downto 0); -- wird durchgereicht vom mux
            wE_out, rE_out, mem_to_reg_MEM, reg_write_MEM : out std_logic);
        
    end component EX;
    
    signal imm_in, pc_in, alu_val_in, reg_val_in: signed(31 downto 0);
    signal opcode_in, rt_in, rd_in:  signed(4 downto 0);
    signal clk, mux_sel_in, write_sel_in, wE_in, rE_in, mem_to_reg_EX_in, reg_write_EX_in: std_logic;
    signal pc_offs_out, out_result_out, data_out: signed(31 downto 0);
    signal write_reg_out: signed(4 downto 0); 
    signal wE_out_out, rE_out_out, mem_to_reg_MEM_out, reg_write_MEM_out : std_logic;

begin
    EXI: EX	port map (imm_in, pc_in, alu_val_in, reg_val_in, opcode_in, rt_in, rd_in, clk, mux_sel_in, write_sel_in, wE_in, rE_in, mem_to_reg_EX_in, reg_write_EX_in
        pc_offs_out, out_result_out, data_out, write_reg_out, wE_out_out. rE_out_out, mem_to_reg_MEM_out, reg_write_MEM_out);

    EXP: process is
    begin

    imm_in <= to_signed(1, 32);

    clk <= '0';
	wait for periodC;
    clk <= '1'; 
	wait for periodC;
    wait;
end process EXP;
end architecture testbench;		  


