library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity wb_seg is 
    port(
        data_val, alu_val : in signed(31 downto 0);
        mem_to_reg_WB, reg_write_WB : in std_logic;
        write_reg_in : in signed(4 downto 0);
        write_reg_out : out signed(4 downto 0);
        write_enable_out : out std_logic;
        write_data : out signed(31 downto 0);
    );
end entity wb_seg;

architecture behaviour of wb_seg
    begin 

    write_data <= alu_val when mem_to_reg_in = '1' else reg_val;

    write_reg_out <= write_reg_in; 
    write_enable_out <= write_enable_in; 
end behaviour; 
