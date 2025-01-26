library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Prozessor is 
    port (
    );
end entity Prozessor;

architecture behaviour of Prozessor is
    component instF is -- IF schon belegt in vhdl
    port (
        pc_in : in signed(31 downto 0);
        pc_out, instruction : out signed(31 downto 0);
    );
    end component;

    component ID is
    port (
        pc_in, instruction, write_data : in signed(31 downto 0);
        reg_wE :                         in std_logic;
        write_reg :                      in signed(4 downto 0);
        pc_out, alu_val, reg_val, imm :  out signed(31 downto 0);
        alu_op, rd, rt :                 out signed(4 downto 0);
        alu_src, reg_dest, mem_to_reg_EX, reg_write_EX :              out std_logic; -- weitere kontrollsignale hinzufügen
    );
    end component;

    component EX is
    port (
        imm, pc, alu_val, reg_val: in signed(31 downto 0); -- inputs ergänzen
        opcode, rt, rd: in signed(4 downto 0);
        mux_sel, write_sel, wE, rE, mem_to_reg_EX, reg_write_EX: in std_logic; -- mux_sel für alu, write_sel für befehls_mux unten bild            
        pc_offs, out_result, data: out signed(31 downto 0);
        write_reg: out signed(4 downto 0); -- wird durchgereicht vom mux
        wE_out, rE_out, mem_to_reg_MEM, reg_write_MEM : out std_logic);
    end component;

    component MEM is
        port (
        pc_in, write_data, adress_in:             in signed(31 downto 0); -- in der stufe auf 16 bit kürzen (hinten bleibt)
        writeE, readE, mem_to_reg_MEM, reg_write_MEM : in std_logic;
        read_data, adress_out, pc_out: out signed(31 downto 0);
        mem_to_reg_WB, reg_write_WB : out std_logic;
        );
    end component;

    component WB is
        port (
        data_val, alu_val :                 in signed(31 downto 0);
        mem_to_reg_WB, reg_write_WB :    in std_logic;
        write_reg_in :                      in signed(4 downto 0);
        write_reg_out :                     out signed(4 downto 0);
        write_enable_out :                  out std_logic;
        write_data :                        out signed(31 downto 0);
        );
    end component;

    signal pc_IF, pc_ID, instruction : signed(31 downto 0); -- instF
    signal write_data_WB, pc_EX, alu_val, reg_val, imm : signed(31 downto 0); -- ID
    signal write_enable_WB, alu_src, reg_dest : std_logic; -- ID
    signal write_reg_WB, alu_op, rd, rt : signed(4 downto 0); -- ID
    signal pc_MEM, alu_result, write_data_EX, : signed(31 downto 0); -- EX
    signal write_reg_EX : signed(4 downto 0);
    signal write_enable_EX, read_enable_EX : std_logic;
    signal ; -- MEM
    signal write_enable_MEM, read_enable_MEM : std_logic; -- MEM
    signal ; -- WB

    begin

        instFI: instF   port map (pc_IF, pc_ID, instruction);

        IDI: ID   port map (pc_ID, instruction, write_data_WB, write_enable_WB, 
        write_reg_WB, pc_EX, alu_val, reg_val, imm, alu_op,rd, rt, alu_src, reg_dest);

        EXI: EX   port map (imm, pc_EX, alu_val, reg_val, alu_op,
         rt, rd, alu_src, reg_dest, write_enable_EX, read_enable_EX, pc_MEM, alu_result, write_data_EX, write_reg_EX, write_enable_MEM, read_enable_MEM ); -- imm als input hinzufügen

        MEMI: MEM   port map (pc_MEM, write_data_EX, alu_result, write_enable_MEM, read_enable_MEM, HIER GEHT ES WEITER);
        
        WBI: WB   port map (data_val, alu_val, mem_to_reg_in, write_enable_in, 
        write_reg_in, write_reg_out, write_enable_out, write_data);

        Prozessor_process : process (clk) is
            begin
                if rising_edge(clk) then

                    TODO !!!
                    
                end if;
        end process Prozessor_process; 
end behaviour;