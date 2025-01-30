library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alu_opcode.all;

entity aluTest is
    generic(	
        periodC	: time		:= 10 ns;
        cyclesC	: integer	:= 100);
    end entity aluTest;

architecture testbench of aluTest is

    component alu is
        port( opA, opB: in signed(31 downto 0);
         result: out  signed(31 downto 0);
		 op: in STD_LOGIC_VECTOR(4 downto 0));
    end component alu;   

    signal opA, opB, result	: signed(31 downto 0);
    signal op		: STD_LOGIC_VECTOR(4 downto 0);

    
begin
    aluI: alu	port map (opA, opB, result, op);

    aluP: process is
    begin
    opA <= to_signed(100, 32);
    opB <= to_signed(4, 32);
    
    op <= alu_mov;
	wait for periodC;
    op <= alu_add;
	wait for periodC;
    op <= alu_sub;
    wait for periodC;
    op <= alu_lsl;
	wait for periodC;
    op <= alu_lsr;
	wait for periodC;
    op <= alu_asr;
	wait for periodC;
    op <= alu_and;
	wait for periodC;
    op <= alu_or;
    wait for periodC;
    op <= alu_xor;
	wait for periodC;
    op <= alu_not;
	wait for periodC;
    op <= alu_cmpe;
	wait for periodC;
    op <= alu_cmpne;
	wait for periodC;
    op <= alu_cmpgt;
	wait for periodC;
    op <= alu_cmpgt_u;
	wait for periodC;
    op <= alu_cmplt;
	wait for periodC;
    op <= alu_cmplt_u;
	wait for periodC;
    wait;
end process aluP;
end architecture testbench;		  


