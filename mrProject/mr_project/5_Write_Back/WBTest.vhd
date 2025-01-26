library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alu_opcode.all;

entity WBTest is
    generic(	
        periodC	: time		:= 10 ns;
        cyclesC	: integer	:= 100);
    end entity WBTest;

architecture testbench of WBTest is
    component WB is
        port(
            data_val, alu_val : in signed(31 downto 0);
            clk, mem_to_reg_WB, reg_write_WB : in std_logic;
            write_reg_in : in signed(4 downto 0);
            write_reg_out : out signed(4 downto 0);
            write_enable_out : out std_logic;
            write_data : out signed(31 downto 0)
        );
    end component WB;

    signal data_val_in, alu_val_in: signed(31 downto 0);
    signal clk_in, mem_to_reg_WB_in, reg_write_WB_in: std_logic;
    signal write_reg_in: signed(4 downto 0);
begin
    WBI: WB port map(data_val_in, alu_val_in, clk_in, mem_to_reg_WB_in, reg_write_WB_in, write_reg_in);
    WBP: process is
    begin
        data_val_in <= to_signed(1, 32);
        alu_val_in <= to_signed(1, 32);

        mem_to_reg_WB_in <= '1';
        reg_write_WB_in <= '1';

        write_reg_in <= to_signed(1, 5);

        clk_in <= '0';
        wait for periodC;
        clk_in <= '1'; 
        wait for periodC;
        wait;
    end process WBP;
end architecture testbench;		  
