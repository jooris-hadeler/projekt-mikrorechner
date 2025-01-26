GHDL = ghdl
TOP_ENTITY = instF_tb
WORKDIR = ghdl_dateien

all: run

analyze:
	$(GHDL) -a --workdir=$(WORKDIR) "./mrProject/mr project/1_Instruction_Fetch/instF.vhd"
	$(GHDL) -a --workdir=$(WORKDIR) "./mrProject/mr project/1_Instruction_Fetch/instF_tb.vhd"

elaborate:
	$(GHDL) -e --workdir=$(WORKDIR) $(TOP_ENTITY)

run: analyze elaborate
	$(GHDL) -r $(TOP_ENTITY) --wave=simulation.ghw
