library ieee; 
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Prozessor is 
    port (
        clk : in std_logic -- Takt-Signal für die gesamte Architektur
    );
end entity Prozessor;

architecture behaviour of Prozessor is

    component instF is -- Schnittstelle des Instruction-Fetch
    port (
        pc_in : in std_logic_vector(31 downto 0); -- Eingabe des aktuellen PC Counts
        pc_out: out std_logic_vector(31 downto 0); -- Ausgabe des inkrementierten PC Counts
        instruction: out std_logic_vector (31 downto 0);-- Die gelesene Instruction aus dem ROM
        clk : in std_logic -- Takt-Signal
    );
    end component;

    component id_seg is 
    port (
        pc_in, instruction, write_data : in std_logic_vector(31 downto 0);
        reg_wE, clk :                         in std_logic;
        write_reg :                      in std_logic_vector(4 downto 0);
        pc_out, alu_val, reg_val, imm :  out std_logic_vector(31 downto 0);
        alu_op, rd, rt :                 out std_logic_vector(4 downto 0);
        alu_src, reg_dest, mem_to_reg_EX, reg_write_EX :    out std_logic -- weitere kontrollsignale hinzufügen
    );
    end component;

    component EX is
    port (
        imm, pc, alu_val, reg_val: in std_logic_vector(31 downto 0); -- inputs ergänzen
        opcode, rt, rd: in std_logic_vector(4 downto 0);
        mux_sel, write_sel, wE, rE, mem_to_reg_EX, reg_write_EX: in std_logic; -- mux_sel für alu, write_sel für befehls_mux unten bild            
        pc_offs, out_result, data: out std_logic_vector(31 downto 0);
        write_reg: out std_logic_vector(4 downto 0); -- wird durchgereicht vom mux
        wE_out, rE_out, mem_to_reg_MEM, reg_write_MEM : out std_logic);
    end component;

   component MEM is 
    port (
        pc_in, adress_in: in std_logic_vector(31 downto 0);-- in der stufe auf 16 bit kürzen (hinten bleibt)
        write_data : in std_logic_vector(31 downto 0);
        clk, writeE, readE, mem_to_reg_in, reg_write_in, mem_to_reg_MEM, reg_write_MEM  : in std_logic;
        read_data, adress_out, pc_out: out std_logic_vector(31 downto 0);
        mem_to_reg_WB, reg_write_WB : out std_logic
    );
    end component;

   component WB is 
    port(
        data_val, alu_val : in std_logic_vector(31 downto 0);
        clk, mem_to_reg_WB, reg_write_WB : in std_logic;
        write_reg_in : in std_logic_vector(4 downto 0);
        write_reg_out : out std_logic_vector(4 downto 0);
        write_enable_out : out std_logic;
        write_data : out std_logic_vector(31 downto 0)
    );
    end component;

    -- signal für instF
    signal pc_IF : std_logic_vector(31 downto 0);
    signal pc_ID : std_logic_vector(31 downto 0);
    signal instruction: std_logic_vector(31 downto 0);

    -- signal für instD
    signal write_data_WB_out, pc_EX, alu_val, reg_val, imm : std_logic_vector(31 downto 0); -- ID
    signal write_enable_WB_out, alu_src, reg_dest : std_logic; -- ID
    signal write_reg_WB_out, alu_op, rd, rt : std_logic_vector(4 downto 0); -- ID

    -- signal für EX
    signal pc_MEM, alu_result, write_data_EX : std_logic_vector(31 downto 0); -- EX
    signal write_reg_EX : std_logic_vector(4 downto 0);
    signal write_enable_EX, read_enable_EX : std_logic;

     -- Signale für MEM-Stufe
    signal pc_WB, adress_MEM, alu_result_MEM : std_logic_vector(31 downto 0);
    signal write_data_MEM : std_logic_vector(31 downto 0);
    signal write_enable_MEM, read_enable_MEM, mem_to_reg_MEM, reg_write_MEM : std_logic;
    
    -- Pipeline-Register MEM/WB
    signal read_data_WB_in, alu_result_WB : std_logic_vector(31 downto 0);
    signal write_enable_WB_in, mem_to_reg_WB, reg_write_WB : std_logic;
    signal write_reg_WB_in : std_logic_vector(4 downto 0);
    
    -- Signale für WB-Stufe
    signal write_data_WB : std_logic_vector(31 downto 0);
    signal write_enable_out : std_logic;

    begin

    instFI: instF 
    port map (
        pc_in => pc_IF,
        pc_out => pc_ID,
        instruction => instruction,
        clk =>  clk
    );
    
    instDI: id_seg
    port map(
        pc_in => pc_ID,
        instruction => instruction,
        write_data => write_data_WB_out,
        reg_wE =>  write_enable_WB_out,                   
        write_reg => write_reg_WB_out,                
        pc_out => pc_EX,
        alu_val => alu_val,
        reg_val => reg_val,
        imm => imm,
        alu_op => alu_op,
        rd => rd,
        rt => rt,
        alu_src => alu_src,
        reg_dest => reg_dest,
        --mem_to_reg_EX => ?,
        --reg_write_EX =>  ?,         
        clk => clk
    );

    EXI: EX
    port map (
        imm         => std_logic_vector(imm),       
        pc          => std_logic_vector(pc_EX),     -- aus ID
        alu_val     => std_logic_vector(alu_val),   -- aus ID
        reg_val     => std_logic_vector(reg_val),   -- aus ID
        opcode      => std_logic_vector(alu_op),    -- aus ID
        rt          => std_logic_vector(rt),        -- aus ID
        rd          => std_logic_vector(rd),        -- aus ID
        mux_sel     => alu_src,           -- Steuerleitung aus ID
        write_sel   => reg_dest,          -- Steuerleitung aus ID
        wE          => write_enable_EX,   -- Steuerleitung
        rE          => read_enable_EX,    -- Steuerleitung
        --mem_to_reg_EX => mem_to_reg_EX,   -- Steuerleitung aus ID
        --reg_write_EX  => reg_write_EX,    -- Steuerleitung aus ID
        pc_offs     => pc_MEM,            -- Ausgabe
        out_result  => alu_result,        -- Ausgabe
        data        => write_data_EX,     
        write_reg   => write_reg_EX,      
        wE_out      => write_enable_MEM,  
        rE_out      => read_enable_MEM  
        --mem_to_reg_MEM => mem_to_reg_MEM, 
        --reg_write_MEM  => reg_write_MEM   
    );

    MEMI: MEM
        port map (
            pc_in          => pc_MEM,        -- PC aus EX-Stufe
            adress_in      => alu_result_MEM, -- Speicheradresse aus ALU-Ergebnis (EX)
            write_data     => write_data_MEM, -- Daten für Speicher (EX-Ergebnis)
            clk            => clk,           -- Takt-Signal
            writeE         => write_enable_MEM,  -- Speicher-Schreibsignal
            readE          => read_enable_MEM,   -- Speicher-Lesesignal
            mem_to_reg_in  => mem_to_reg_MEM,    -- Steuersignal für WB-Stufe
            reg_write_in   => reg_write_MEM,     -- Register Write Enable Signal
            mem_to_reg_MEM => mem_to_reg_WB,     -- Weitergabe an WB
            reg_write_MEM  => reg_write_WB,      -- Weitergabe an WB
            read_data      => read_data_WB,      -- Gelesene Daten für WB
            adress_out     => open,              -- Falls nicht benötigt
            pc_out         => pc_WB              -- PC für WB
        );

    WBI: WB
    port map (
        data_val       => read_data_WB,   -- Speicherwert aus MEM-Stufe
        alu_val        => alu_result_WB,  -- ALU-Ergebnis für WB
        clk            => clk,            -- Takt-Signal
        mem_to_reg_WB  => mem_to_reg_WB,  -- Steuersignal zur Auswahl des WB-Werts
        reg_write_WB   => reg_write_WB,   -- Schreibsignal für Register
        write_reg_in   => write_reg_WB,   -- Zielregister für WB
        write_reg_out  => write_reg_WB,   -- Zielregister bleibt gleich
        write_enable_out => write_enable_out, -- Finales Write-Enable-Signal für Register
        write_data     => write_data_WB   -- Finaler Wert für Register-Write
    );

    -- process für IF/ID
        process (clk)
            begin
                if rising_edge(clk) then
                pc_ID <= pc_IF;
                instruction_ID <= instruction_IF;
                end if;
            end process;

    -- process für ID/EX
        process (clk)
    begin
        if rising_edge(clk) then
            pc_EX <= std_logic_vector(pc_ID);   -- PC weiterleiten
            alu_val <= std_logic_vector(alu_val); -- ALU-Wert aus Registerbank
            reg_val <= std_logic_vector(reg_val); -- Registerwert weiterleiten
            imm <= std_logic_vector(imm);         -- Immediate-Wert weitergeben
            alu_op <= std_logic_vector(alu_op);   -- ALU-Opcode
            rd <= std_logic_vector(rd);           -- Zielregister
            rt <= std_logic_vector(rt);           -- Quellregister
            alu_src <= alu_src;         -- Steuerleitung
            reg_dest <= reg_dest;       -- Steuerleitung
            write_enable_EX <= write_enable_WB; -- Steuerleitung für Register-Write
            read_enable_EX <= read_enable_MEM;  -- Speicherlesesteuerung
            mem_to_reg_EX <= mem_to_reg_EX;
            reg_write_EX <= reg_write_EX;
        end if;
    end process;

    -- process für EX/MEM
    process (clk)
    begin
        if rising_edge(clk) then
            pc_MEM <= pc_EX;            -- PC weitergeben
            alu_result_MEM <= alu_result; -- ALU-Ergebnis an Speicher übergeben
            write_data_MEM <= std_logic_vector(write_data_EX); -- Speicher-Wert
            write_enable_MEM <= write_enable_EX; -- Schreibsteuerung
            read_enable_MEM <= read_enable_EX;  -- Lese-Steuerleitung
            mem_to_reg_MEM <= mem_to_reg_EX;    -- Speicher-zu-Register-Steuerleitung
            reg_write_MEM <= reg_write_EX;      -- Steuerbit für Register-Write
        end if;
    end process;

    -- process für /WBMEM
    process (clk)
    begin
        if rising_edge(clk) then
            alu_result_WB <= alu_result_MEM; -- ALU-Ergebnis für WB
            read_data_WB <= read_data_WB;   -- Daten aus Speicher
            write_reg_WB <= write_reg_EX;   -- Zielregister für WB
            write_enable_WB <= reg_write_MEM; -- Steuerleitung für Register-Write
            mem_to_reg_WB <= mem_to_reg_MEM; -- Speicher-zu-Register-Steuerleitung
        end if;
    end process;
     
end behaviour;