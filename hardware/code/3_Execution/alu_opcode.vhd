library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package alu_opcode is
    constant alu_mov: STD_LOGIC_VECTOR(4 downto 0) := "00000";
    constant alu_add: STD_LOGIC_VECTOR(4 downto 0) := "00001";
    constant alu_sub: STD_LOGIC_VECTOR(4 downto 0) := "00010";
    constant alu_lsl: STD_LOGIC_VECTOR(4 downto 0) := "00011";
    constant alu_lsr: STD_LOGIC_VECTOR(4 downto 0) := "00100";
    constant alu_asr: STD_LOGIC_VECTOR(4 downto 0) := "00101";
    constant alu_and: STD_LOGIC_VECTOR(4 downto 0) := "00110";
    constant alu_or: STD_LOGIC_VECTOR(4 downto 0) := "00111";
    constant alu_xor: STD_LOGIC_VECTOR(4 downto 0) := "01000";
    constant alu_not: STD_LOGIC_VECTOR(4 downto 0) := "01001";
    constant alu_cmpe: STD_LOGIC_VECTOR(4 downto 0) := "01010";
    constant alu_cmpne: STD_LOGIC_VECTOR(4 downto 0) := "01011";
    constant alu_cmpgt: STD_LOGIC_VECTOR(4 downto 0) := "01100";
    constant alu_cmpgt_u: STD_LOGIC_VECTOR(4 downto 0) := "01101";
    constant alu_cmplt: STD_LOGIC_VECTOR(4 downto 0) := "01110";
    constant alu_cmplt_u: STD_LOGIC_VECTOR(4 downto 0) := "01111";
end alu_opcode;