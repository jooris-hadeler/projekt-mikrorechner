GHDL = ghdl
TOP_ENTITY = registerbankTest
WORKDIR = work

all: run

analyze:
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "mrProject/memorySim/memPkg.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "mrProject/memorySim/rom.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "mrProject/mr_project/1_Instruction_Fetch/instF.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "mrProject/mr_project/1_Instruction_Fetch/instF_tb.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "mrProject/mr_project/2_Instruction_Decode/ID.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "mrProject/mr_project/2_Instruction_Decode/registerbank.vhd"
	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "mrProject/mr_project/2_Instruction_Decode/registerbankTest.vhd"

elaborate:
	$(GHDL) -e -fsynopsys --workdir=$(WORKDIR) $(TOP_ENTITY)

run: analyze elaborate
	$(GHDL) -r  -fsynopsys $(TOP_ENTITY) --wave=simulation.ghw

