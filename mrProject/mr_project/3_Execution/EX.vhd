library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity EX is 
    port (
        imm, pc, alu_val, reg_val: in std_logic_vector(31 downto 0); -- inputs ergänzen
        opcode, rt, rd: in std_logic_vector(4 downto 0);
        clk, mux_sel, write_sel, wE, rE, mem_to_reg_EX, reg_write_EX: in std_logic; -- mux_sel für alu, write_sel für befehls_mux unten bild            
        pc_offs, out_result, data: out std_logic_vector(31 downto 0);
        write_reg: out std_logic_vector(4 downto 0); -- wird durchgereicht vom mux
        wE_out, rE_out, mem_to_reg_MEM, reg_write_MEM : out std_logic);
end entity EX;

architecture behaviour of EX is
    component alu is
    port(
        opA, opB: in signed(31 downto 0);
        result: out  signed(31 downto 0);
		op: in signed(4 downto 0));
    end component;

    signal alu_result, mux_var: signed(31 downto 0);
    signal imm_signed : signed(31 downto 0);

    begin
        aluI: alu	port map (signed(alu_val), mux_var, alu_result, signed(opcode));

        mux_var <= signed(reg_val) when mux_sel = '1' else signed(imm);

        ex_seg_process : process (clk) is
            begin 
            if rising_edge(clk) then

                if mux_sel = '1' then 
                imm_signed <= signed(imm);
                pc_offs <= std_logic_vector(signed(pc) + (imm_signed(29 downto 0) & "00")); -- adder und shifter (imm -> offset)
                else pc_offs <= pc;
                end if;

                if write_sel = '1' then
                    write_reg <= rd;
                else 
                    write_reg <= rt;
                end if;
                
                reg_write_MEM <= reg_write_EX;
                mem_to_reg_MEM <= mem_to_reg_EX;
                rE_out <= rE;
                wE_out <= wE;
                data <= reg_val;
                out_result <= std_logic_vector(alu_result); -- ergebnis der alu wird 'ausgegeben'
                
            end if; --weitere speicherwerte einfach mit in process integrieren
        end process ex_seg_process;

end behaviour;
