library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package opcodes is
    constant opc_r: STD_LOGIC_VECTOR(5 downto 0) := "000000";
    constant opc_shi: STD_LOGIC_VECTOR(5 downto 0) := "000001";
    constant opc_slo: STD_LOGIC_VECTOR(5 downto 0) := "000010";
    constant opc_load: STD_LOGIC_VECTOR(5 downto 0) := "000011";
    constant opc_store: STD_LOGIC_VECTOR(5 downto 0) := "000100";
    constant opc_br: STD_LOGIC_VECTOR(5 downto 0) := "000101";
    constant opc_jr: STD_LOGIC_VECTOR(5 downto 0) := "000110";
    constant opc_jmp: STD_LOGIC_VECTOR(5 downto 0) := "000111";
    constant opc_noop: STD_LOGIC_VECTOR(5 downto 0) := "001000";
end opcodes;