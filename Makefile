# Pfade, Variblen
STD := --std=08
GHDL ?= ghdl
PROJECT_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))#pfad zum ordner mit makefile ohne / am ende	
WORK_DIR := $(PROJECT_DIR)mrProject/work
DEC_DIR  := $(PROJECT_DIR)mrProject/mr_project/2_Instruction_Decode
EXEC_DIR := $(PROJECT_DIR)mrProject/mr_project/3_Execution
MEM_DIR := $(PROJECT_DIR)mrProject/memorySim
MEM_VHD := $(wildcard $(MEM_DIR)/*.vhd)# liste aller .vhd dateien im memorySim ordner
MEM_VHD := $(filter-out $(MEM_DIR)/procTest.vhd, $(MEM_VHD))#entfernt procTest.vhd aus der Liste
INSTF_DIR := $(PROJECT_DIR)mrProject/mr_project/1_Instruction_Fetch
INSTF_VHD := $(wildcard $(INSTF_DIR)/*.vhd)
TEST_TARGETS := analyze_Memory analyze_InstF
MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFLAGS += -f$(MAKEFILE_PATH)
WORKDIR := $(WORK_DIR)

#Direktory work
$(WORK_DIR):
	@mkdir -p "$(WORK_DIR)"

# basics:
# 	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "/mnt/d/Uni/ProjektMikrorechner/projekt-mikrorechner/mrProject/memorySim/ramb.vhd"
# 	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "/mnt/d/Uni/ProjektMikrorechner/projekt-mikrorechner/mrProject/memorySim/memPkg.vhd"
# 	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "/mnt/d/Uni/ProjektMikrorechner/projekt-mikrorechner/mrProject/memorySim/romIO.vhd"
# 	$(GHDL) -a -fsynopsys --workdir=$(WORKDIR) "/mnt/d/Uni/ProjektMikrorechner/projekt-mikrorechner/mrProject/memorySim/rom.vhd"

# 	$(GHDL) -a --workdir=$(WORKDIR) "$(PROJECT_DIR)/mrProject/mr_project/2_Instruction_Decode/funct_codes.vhd"
# 	$(GHDL) -a --workdir=$(WORKDIR) "$(PROJECT_DIR)/mrProject/mr_project/2_Instruction_Decode/opcodes.vhd"
# 	$(GHDL) -a --workdir=$(WORKDIR) "$(PROJECT_DIR)/mrProject/mr_project/2_Instruction_Decode/registerbank.vhd"
# 	$(GHDL) -a --workdir=$(WORKDIR) "$(PROJECT_DIR)/mrProject/mr_project/2_Instruction_Decode/registerbankTest.vhd"
# 	$(GHDL) -e --workdir=$(WORKDIR) "registerbankTest"
# 	$(GHDL) -r --workdir=$(WORKDIR) "registerbankTest" --vcd=work/registerbankTest.vcd

# 	$(GHDL) -a --workdir=$(WORKDIR) "$(PROJECT_DIR)/mrProject/mr_project/3_Execution/alu_opcode.vhd"
# 	$(GHDL) -a --workdir=$(WORKDIR) "$(PROJECT_DIR)/mrProject/mr_project/3_Execution/alu.vhd"
# 	$(GHDL) -a --workdir=$(WORKDIR) "$(PROJECT_DIR)/mrProject/mr_project/3_Execution/aluTest.vhd"
# 	$(GHDL) -e --workdir=$(WORKDIR) "aluTest"
# 	$(GHDL) -r --workdir=$(WORKDIR) "aluTest" --vcd=work/aluTest.vcd
	
# kompiliert die ROM/RAM
analyze_Memory: $(WORK_DIR)
	@ghdl -a $(STD) --work=work --workdir=$(WORK_DIR) $(MEM_VHD)
	@echo "MEM analysiert"

# kompiliert pakete für Decode und Execute
decode_packages: | $(WORK_DIR)
	@ghdl -a $(STD) --work=work --workdir="$(WORK_DIR)" "$(DEC_DIR)/opcodes.vhd"
	@ghdl -a $(STD) --work=work --workdir="$(WORK_DIR)" "$(DEC_DIR)/funct_codes.vhd"
	@ghdl -a $(STD) --work=work --workdir="$(WORK_DIR)" "$(EXEC_DIR)/alu_opcode.vhd"
	@echo "Decode & ALU Packages kompiliert."

#analyze_InstF:
analyze_InstF: $(WORK_DIR)
	@ghdl -a $(STD) --work=work --workdir=$(WORK_DIR) $(INSTF_VHD)
	@echo "InstF analysiert"

#kompiliert, elaboriert und simuliert InstF_tb
run_InstF: analyze_Memory analyze_InstF
	@ghdl -e $(STD) --work=work --workdir=$(WORK_DIR) instF_tb
	@ghdl -r $(STD) --work=work --workdir=$(WORK_DIR) instF_tb --vcd=$(WORK_DIR)/InstF_tb.vcd
	@echo "InstF_tb simuliert"

# öffnet die Wellenform in GTKWave
waves_InstF: run_InstF
	@( gtkwave "$(WORK_DIR)/instF_tb.vcd" >/dev/null 2>&1 & ) || true
	@echo "GTKWave gestartet"

registerbanktest: analyze_Memory analyze_InstF
	@ghdl -a $(STD) --work=work --workdir=$(WORK_DIR) $(PROJECT_DIR)mrProject/mr_project/2_Instruction_Decode/registerBank.vhd
	@ghdl -a $(STD) --work=work --workdir=$(WORK_DIR) $(PROJECT_DIR)mrProject/mr_project/2_Instruction_Decode/registerBank_tb.vhd
	@ghdl -e $(STD) --work=work --workdir=$(WORK_DIR) registerBank_tb
	@ghdl -r $(STD) --work=work --workdir=$(WORK_DIR) registerBank_tb --vcd=$(WORK_DIR)/registerBank_tb.vcd
	@( gtkwave "$(WORK_DIR)/registerBank_tb.vcd" >/dev/null 2>&1 & ) || true
	@echo "Register Bank Test abgeschlossen"

ID: analyze_Memory decode_packages | $(WORK_DIR)
	@ghdl -a $(STD) --work=work --workdir="$(WORK_DIR)" \
		"$(DEC_DIR)/ID.vhd"
#	@ghdl -a $(STD) --work=work --workdir="$(WORK_DIR)" \
		"$(PROJECT_DIR)mrProject/mr_project/2_Instruction_Decode/IDTest.vhd"
#	@ghdl -e $(STD) --work=work --workdir="$(WORK_DIR)" IDTest
#	@ghdl -r --work=work --workdir="$(WORK_DIR)" IDTest \
		--vcd="$(WORK_DIR)/IDTest.vcd"

# löscht das work dir
clean:
	@if [ -n "$(WORK_DIR)" ] && [ -d "$(WORK_DIR)" ]; then \
		rm -rf "$(WORK_DIR)"; \
		echo "WORK_DIR gelöscht."; \
	else \
		echo "WORK_DIR ist leer oder existiert nicht! Abbruch."; \
	fi

.PHONY: clean analyze_Memory analyze_InstF test waves_InstF run_InstF

test:
	@echo $(PROJECT_DIR)
	@echo $(WORK_DIR)