library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package alu_opcode is
    constant alu_mov: signed(4 downto 0) := "00000";
    constant alu_add: signed(4 downto 0) := "00001";
    constant alu_sub: signed(4 downto 0) := "00010";
    constant alu_lsl: signed(4 downto 0) := "00011";
    constant alu_lsr: signed(4 downto 0) := "00100";
    constant alu_asr: signed(4 downto 0) := "00101";
    constant alu_and: signed(4 downto 0) := "00110";
    constant alu_or: signed(4 downto 0) := "00111";
    constant alu_not: signed(4 downto 0) := "01000";
    constant alu_cmpe: signed(4 downto 0) := "01001";
    constant alu_cmpne: signed(4 downto 0) := "01010";
    constant alu_cmpgt: signed(4 downto 0) := "01011";
    constant alu_cmplt: signed(4 downto 0) := "01100";
end alu_opcode;