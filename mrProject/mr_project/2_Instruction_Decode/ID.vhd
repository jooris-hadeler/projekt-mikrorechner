library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.opcodes.all;
use work.funct_codes.all;
use work.alu_opcode.all;


entity ID is 
    port (
        pc_in, instruction, write_data : in std_logic_vector(31 downto 0);
        clk, reg_wE :                         in std_logic;
        write_reg :                      in std_logic_vector(4 downto 0);
        pc_out, alu_val, reg_val, imm :  out std_logic_vector(31 downto 0);
        alu_op, rs, rd, rt :                 out std_logic_vector(4 downto 0);
        alu_src:                          out std_logic; -- zweiter operand = '0' aus register, '1' immediate wert
        reg_dest:                        out std_logic; -- zielregister = '0' rt, '1' rd
        mem_to_reg_EX:                out std_logic; -- zielregister wert = '0' alu ergebnis, '1' daten aus dem speicher (für load)
        reg_write_EX :              out std_logic -- '0' kein schreibvorgang, '1' schreiben in registerbank
    );
end entity ID;

architecture behaviour of ID

    is component registerbank is
    port(
        clk :   in std_logic;
        dIn :   in signed(31 downto 0); --input
        dOutA : out signed(31 downto 0); --outputA
        dOutB : out signed(31 downto 0); --outputB
        selA :  in unsigned(4 downto 0); --Registernr f�r dOutA
        selB :  in unsigned(4 downto 0); --Registernr f�r dOutB
        selD :  in unsigned(4 downto 0); --Registernr f�r dIn
        wE :    in std_logic
    );
    end component;

    signal sel_alu_val : std_logic_vector(4 downto 0); -- signal für die auswahl des ersten quellregisters (rs) für die alu
    signal sel_reg_val : std_logic_vector(4 downto 0); -- signal für die auswahl des zweiten quellregisters (rt) für die alu
    signal opcode, funct : STD_LOGIC_VECTOR(5 downto 0);
    signal dOutA_s, dOutB_s : signed(31 downto 0); -- signale für die ausgänge der registerbank, die als operanden für die alu dienen
    
    begin
        registerbankI: registerbank	port map (
            clk => clk,
            dIn => signed(write_data),
            dOutA => dOutA_s, -- mapping von dem signal der registerbank zu dem signal von ID
            dOutB => dOutB_s, -- mapping von dem signal der registerbank zu dem signal von ID
            selA => unsigned(sel_alu_val), -- die schnittstelle für das erste quellregister(rs) selA wird mit dem signal für die alu verbunden 
            selB => unsigned(sel_reg_val), -- die schnittstelle für das zweite quellregister(rt) selB wird mit dem signal für die alu verbunden
            selD => unsigned(write_reg), -- die schnittstelle der registerbank selD wird mit dem input port write_reg der ID architektur verbunden
            wE => reg_wE );
        
        alu_val <= std_logic_vector(dOutA_s); -- das signal des Outputs der registerbank wird dem port alu_val zugewiesen
        reg_val <= std_logic_vector(dOutB_s); -- das signal des Outputs der registerbank wird dem port reg_val zugewiesen

        id_seg_process : process (clk) is
            
            -- hier braucht man variable für opcode/funct, da bei <= diese erst im nächten takt gelten
            variable opcode_v : std_logic_vector(5 downto 0); 
            variable funct_v : std_logic_vector(5 downto 0);
        
        begin
            if rising_edge(clk) then

                --setzen der out-Schnittstelle für die ALU
                -- Defaults:
                alu_src <= '0'; -- default: 2. operand aus register
                reg_dest <= '0'; -- default: zielregister ist rt
                mem_to_reg_EX <= '0'; -- default: zielregister wert ist alu ergebnis
                reg_write_EX <= '0'; -- default: kein schreiben

                sel_alu_val <= instruction(25 downto 21); -- dem signal für das erste quellregister(rs) für den ersten opranden der alu wird der entsprechende teil der instruction zugewiesen
                sel_reg_val <= instruction(20 downto 16); -- dem signal für das zweite quellregister(rt) für den zweiten opranden der alu wird der entsprechende teil der instruction zugewiesen
                opcode_v := instruction(31 downto 26); -- zuweisung von opcode also 31-26 bit der instruction
                funct_v := instruction(5 downto 0); -- zuweisung von funct also 5-0 bit der instruction

                case opcode_v is -- je nach opcode type der instruction bestimmen
                    when opc_r =>
                        reg_dest <= '1'; -- zielregister ist rd
                        reg_write_EX <= '1'; -- schreiben in registerbank
                        case funct_v is 
                            when funct_add => alu_op <= alu_add;
                            when funct_sub => alu_op <= alu_sub;
                            when funct_and => alu_op <= alu_and;
                            when funct_or => alu_op <= alu_or;
                            when funct_xor => alu_op <= alu_xor;
                            when funct_shl => alu_op <= alu_lsl;
                            when funct_sal => alu_op <= alu_lsl;
                            when funct_shr => alu_op <= alu_lsr;
                            when funct_sar => alu_op <= alu_asr;
                            when funct_not => alu_op <= alu_not;
                            when funct_lts => alu_op <= alu_cmplt;
                            when funct_gts => alu_op <= alu_cmpgt;
                            when funct_ltu => alu_op <= alu_cmplt_u;
                            when funct_gtu => alu_op <= alu_cmpgt_u;
                            when funct_eq => alu_op <= alu_cmpe;
                            when funct_ne => alu_op <= alu_cmpne;
                            when others => null; 
                        end case;

                        rs <= instruction(25 downto 21);
                        rt <= instruction(20 downto 16);
                        rd <= instruction(15 downto 11);

                    when opc_shi => alu_op <= alu_add;
                    when opc_slo => alu_op <= alu_add;
                    when opc_load =>
                        alu_src <= '1'; -- für load adrr = base + immediate
                        mem_to_reg_EX <= '1'; -- zielregister wert = daten aus dem speicher
                        reg_write_EX <= '1'; -- schreiben in registerbank
                        alu_op <= alu_add;

                    when opc_store => alu_op <= alu_add;
                        alu_src <= '1'; -- für store adrr = base + immediate
                    when opc_br => alu_op <= alu_add;
                    when opc_jr => alu_op <= alu_add;
                    when opc_jmp => alu_op <= alu_add;
                    when opc_noop => alu_op <= alu_add;
                    when others => null;
                end case;
                pc_out  <= pc_in;

                if instruction(15) = '0' then -- implizites sign extend
                    imm <= "0000000000000000" & instruction(15 downto 0);
                    else 
                    imm <= "1111111111111111" & instruction(15 downto 0);
                end if;
            end if;    
        end process id_seg_process;
end behaviour;
