library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity WB is 
    port(
        data_val, alu_val : in std_logic_vector(31 downto 0);
        clk, mem_to_reg_WB, reg_write_WB : in std_logic;
        write_reg_in : in std_logic_vector(4 downto 0);
        write_reg_out : out std_logic_vector(4 downto 0);
        write_enable_out : out std_logic;
        write_data : out std_logic_vector(31 downto 0)
    );
end entity WB;

architecture behaviour of WB is
    begin 
        write_data <= alu_val when mem_to_reg_WB = '1' else data_val;
        write_reg_out <= write_reg_in; 
        write_enable_out <= reg_write_WB; 
end behaviour; 
