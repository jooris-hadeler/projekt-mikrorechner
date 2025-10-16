GHDL = ghdl
TOP_ENTITY = ramIO_tb
WORKDIR = work

all: run

analyze:
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "references/memorySim/memPkg.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "references/memorySim/rom.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "references/memorySim/ramB.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "references/memorySim/ramIO.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/1_Instruction_Fetch/IF.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/1_Instruction_Fetch/IFTest.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/2_Instruction_Decode/funct_codes.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/2_Instruction_Decode/opcodes.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/2_Instruction_Decode/registerbank.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/2_Instruction_Decode/registerbankTest.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/2_Instruction_Decode/ID.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/2_Instruction_Decode/IDTest.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/3_Execution/alu_opcode.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/3_Execution/alu.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/3_Execution/aluTest.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/3_Execution/EX.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/3_Execution/EXTest.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/4_Memory_Access/MEM.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/4_Memory_Access/MEMTest.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/5_Write_Back/WB.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/5_Write_Back/WBTest.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/ram_tb.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "code/Prozessor.vhd"
elaborate:
	$(GHDL) -e -fsynopsys --workdir=$(WORKDIR) $(TOP_ENTITY)

run: analyze elaborate
	$(GHDL) -r  -fsynopsys $(TOP_ENTITY) --wave=simulation.ghw

