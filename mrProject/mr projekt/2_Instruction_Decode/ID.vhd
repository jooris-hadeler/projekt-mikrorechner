library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity id_seg is 
    port (
        pc_in, instruction, write_data : in signed(31 downto 0);
        reg_wE :                         in std_logic;
        write_reg :                      in signed(4 downto 0);
        pc_out, alu_val, reg_val, imm :  out signed(31 downto 0);
        alu_op, rd, rt :                 out signed(4 downto 0);
        alu_src, reg_dest, mem_to_reg_EX, reg_write_EX :              out std_logic; -- weitere kontrollsignale hinzufügen
    );
end entity id_seg;

architecture behaviour of id_seg
    component registerbank is
    port(
        clk :   in std_logic;
        dIn :   in signed(31 downto 0); --input
        dOutA : out signed(31 downto 0); --outputA
        dOutB : out signed(31 downto 0); --outputB
        selA :  in std_logic_vector(5 downto 1); --Registernr für dOutA
        selB :  in std_logic_vector(5 downto 1); --Registernr für dOutB
        selD :  in std_logic_vector(5 downto 1); --Registernr für dIn
        wE :    in std_logic
    );
    end component;

    signal sel_alu_val, sel_reg_val : signed(4 downto 0);

    begin

        registerbankI: registerbank	port map (clk, write_data, dOutA, dOutB, selA, selB, write_reg, reg_wE);
        id_seg_process : process (clk) is
            begin
            sel_alu_val <= instruction(27 downto 23);
            sel_reg_val <= instruction(22 downto 18);
            if rising_edge(clk) then
                pc_out  <= pc_in;
                alu_val <= dOutA;
                reg_val <= dOutB;
                rd <= instruction(22 downto 18);
                rt <= instruction(17 downto 13);

                if instruction(15) = 0 then -- implizites sign extend
                    imm <= '000000000000000' + instruction(15 downto 0);
                    else 
                    imm <= '1111111111111111' + instruction(15 downto 0);
                end if;
        end process id_seg_process;
_end behaviour;
