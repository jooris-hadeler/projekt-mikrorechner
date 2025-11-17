-- isa_pkg.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package isa_pkg is
  --------------------------------------------------------------------
  -- Grundtypen
  --------------------------------------------------------------------
  subtype reg_idx_t is std_logic_vector(4 downto 0);    -- 5 Bit Registerindex
  subtype opcode_t  is std_logic_vector(5 downto 0);    -- 6 Bit Opcode
  subtype funct_t   is std_logic_vector(5 downto 0);    -- 6 Bit Funct

  -- ALU-Op als (kleine) Kodierung nach außen (5 Bit reichen idR)
  type aluop_e is (
    ALU_NOP, ALU_ADD, ALU_SUB, ALU_AND, ALU_OR, ALU_XOR,
    ALU_LSL, ALU_LSR, ALU_ASR, ALU_NOT,
    ALU_CMPE, ALU_CMPNE, ALU_CMPLT, ALU_CMPGT, ALU_CMPLT_U, ALU_CMPGT_U
  );
  -- eine simple, feste Binärkodierung (an EX/ALU anpassen)
  function enc(a : aluop_e) return std_logic_vector;

  --------------------------------------------------------------------
  -- Feldpositionen (MIPS-ähnliches Default; später anpassen!)
  --------------------------------------------------------------------
  constant RS_HI  : natural := 25;  constant RS_LO  : natural := 21;
  constant RT_HI  : natural := 20;  constant RT_LO  : natural := 16;
  constant RD_HI  : natural := 15;  constant RD_LO  : natural := 11;
  constant SH_HI  : natural := 10;  constant SH_LO  : natural :=  6;
  constant IM_HI  : natural := 15;  constant IM_LO  : natural :=  0;
  constant OP_HI  : natural := 31;  constant OP_LO  : natural := 26;
  constant FN_HI  : natural :=  5;  constant FN_LO  : natural :=  0;

  --------------------------------------------------------------------
  -- Platzhalter-OPCODES/FUNCTS (später durch echte Codes ersetzen)
  --------------------------------------------------------------------
  constant OPC_RTYPE : opcode_t := "000000";
  constant OPC_LOAD  : opcode_t := "100011";
  constant OPC_STORE : opcode_t := "101011";
  constant OPC_ANDI  : opcode_t := "001100";
  constant OPC_ORI   : opcode_t := "001101";
  constant OPC_XORI  : opcode_t := "001110";
  constant OPC_BR    : opcode_t := "000100"; -- z.B. beq

  -- R-Type Funct Beispiele
  constant F_ADD : funct_t := "100000";
  constant F_SUB : funct_t := "100010";
  constant F_AND : funct_t := "100100";
  constant F_OR  : funct_t := "100101";
  constant F_XOR : funct_t := "100110";
  constant F_SLL : funct_t := "000000";
  constant F_SRL : funct_t := "000010";
  constant F_SRA : funct_t := "000011";
  constant F_NOT : funct_t := "101111"; -- frei gewählt als Platzhalter

end package;

package body isa_pkg is
  function enc(a : aluop_e) return std_logic_vector is
    variable v : std_logic_vector(4 downto 0);
  begin
    case a is
      when ALU_NOP     => v := "00000";
      when ALU_ADD     => v := "00001";
      when ALU_SUB     => v := "00010";
      when ALU_AND     => v := "00011";
      when ALU_OR      => v := "00100";
      when ALU_XOR     => v := "00101";
      when ALU_LSL     => v := "00110";
      when ALU_LSR     => v := "00111";
      when ALU_ASR     => v := "01000";
      when ALU_NOT     => v := "01001";
      when ALU_CMPE    => v := "01010";
      when ALU_CMPNE   => v := "01011";
      when ALU_CMPLT   => v := "01100";
      when ALU_CMPGT   => v := "01101";
      when ALU_CMPLT_U => v := "01110";
      when ALU_CMPGT_U => v := "01111";
    end case;
    return v;
  end;
end package body;
