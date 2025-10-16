library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity instF_tb is
-- Testbench hat keine Ports
end instF_tb;

architecture Behavioral of instF_tb is
    -- Komponente instf_seg instanziieren
    component instf_seg
        Port (
            pc_in       : in  std_logic_vector(31 downto 0);
            pc_out      : out std_logic_vector(31 downto 0);
            instruction : out std_logic_vector(31 downto 0);
            clk         : in  std_logic
        );
    end component;

    -- Signale für die Testbench
    signal clk         : std_logic := '0';
    signal pc_in       : std_logic_vector(31 downto 0) := (others => '0');
    signal pc_out      : std_logic_vector(31 downto 0);
    signal instruction : std_logic_vector(31 downto 0);

    -- Taktgenerator
    constant clk_period : time := 10 ns;
begin
    -- Instanz des zu testenden Moduls
    uut: instf_seg
        Port map (
            clk         => clk,
            pc_in       => pc_in,
            pc_out      => pc_out,
            instruction => instruction
        );

    -- Taktprozess
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Testszenarien
    stimulus_process: process
    begin
        -- Initialisierung
        pc_in <= x"00000000";
        wait for 20 ns;

        -- PC erhöhen und prüfen
        pc_in <= x"00000004";
        wait for 20 ns;

        -- Weitere Tests
        pc_in <= x"00000008";
        wait for 20 ns;

        -- Testende
        wait;
    end process;
end Behavioral;
