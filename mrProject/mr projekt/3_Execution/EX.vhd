library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ex_seg is 
    port (
        imm, pc, alu_val, reg_val: in signed(31 downto 0); -- inputs ergänzen
        opcode, rt, rd: in signed(4 downto 0);
        mux_sel, write_sel, wE, rE, mem_to_reg_EX, reg_write_EX: in std_logic; -- mux_sel für alu, write_sel für befehls_mux unten bild            
        pc_offs, out_result, data: out signed(31 downto 0);
        write_reg: out signed(4 downto 0); -- wird durchgereicht vom mux
        wE_out, rE_out, mem_to_reg_MEM, reg_write_MEM : out std_logic);
end entity ex_seg;

architecture behaviour of ex_seg
    component alu is
    port(
        opA, opB: in signed(31 downto 0);
        result: out  signed(31 downto 0);
		op: in signed(4 downto 0));
    end component;

    signal result, mux_var: signed(31 downto 0);

    begin
        aluI: alu	port map (alu_val, mux_var, alu_result, opcode);

        mux_var <= reg_val when mux_sel = '1' else imm;

        ex_seg_process : process (clk) is
            begin 
            if rising_edge(clk) then
                out_result <= alu_result; -- ergebnis der alu wird 'ausgegeben'
                
                if mux_sel = '1' then 
                    pc_offs <= pc + (imm(29 downto 0) & "00"); -- adder und shifter (imm -> offset)
                    else pc_offs <= pc;
                end if;

                write_reg <= rd when write_sel = '1' else rt;

                data <= reg_val;
            end if; --weitere speicherwerte einfach mit in process integrieren
        end process ex_seg_process;

end behaviour;
