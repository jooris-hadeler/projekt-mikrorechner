library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package funct_codes is
    constant funct_add: STD_LOGIC_VECTOR(5 downto 0) := "000000";
    constant funct_sub: STD_LOGIC_VECTOR(5 downto 0) := "000001";
    constant funct_and: STD_LOGIC_VECTOR(5 downto 0) := "000010";
    constant funct_or: STD_LOGIC_VECTOR(5 downto 0) := "000011";
    constant funct_xor: STD_LOGIC_VECTOR(5 downto 0) := "000100";
    constant funct_shl: STD_LOGIC_VECTOR(5 downto 0) := "000101";
    constant funct_sal: STD_LOGIC_VECTOR(5 downto 0) := "000110";
    constant funct_shr: STD_LOGIC_VECTOR(5 downto 0) := "000111";
    constant funct_sar: STD_LOGIC_VECTOR(5 downto 0) := "001000";
    constant funct_not: STD_LOGIC_VECTOR(5 downto 0) := "001001";
    constant funct_lts: STD_LOGIC_VECTOR(5 downto 0) := "001010";
    constant funct_gts: STD_LOGIC_VECTOR(5 downto 0) := "001011";
    constant funct_ltu: STD_LOGIC_VECTOR(5 downto 0) := "001100";
    constant funct_gtu: STD_LOGIC_VECTOR(5 downto 0) := "001101";
    constant funct_eq: STD_LOGIC_VECTOR(5 downto 0) := "001110";
    constant funct_ne: STD_LOGIC_VECTOR(5 downto 0) := "001111";
end funct_codes;