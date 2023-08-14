TOP_DIR      = $(shell pwd)/..
SRC_DIR      = $(TOP_DIR)/src
INCLUDE_DIR  = $(TOP_DIR)/include
SUB_DIR      = $(TOP_DIR)/sub
SUB_SRC_DIR  = $(SUB_DIR)/src
PKG_DIR      = $(SUB_DIR)/include

FILES       += $(PKG_DIR)/alu_pkg.sv
FILES       += $(SUB_SRC_DIR)/alu.sv
FILES       += $(SUB_SRC_DIR)/pc.sv
FILES       += $(SUB_SRC_DIR)/rf.sv
FILES       += $(SRC_DIR)/if_stage.sv
FILES       += $(SRC_DIR)/id_stage.sv

TEST         = if_stage

ifeq ($(TEST), if_stage)
    TOPLEVEL = $(TEST)
    PARAMS   = -GDATA_WIDTH=32 -GIMEM_SZ_IN_KB=1
else ifeq ($(TEST), id_stage)
    TOPLEVEL = $(TEST)
    PARAMS   = -GDATA_WIDTH=32
endif

SIM_BUILD = build/build_$(TEST)
EXTRA_ARGS      = vconfig.vlt -I$(INCLUDE_DIR) $(PARAMS) --trace --trace-structs #--debug --gdbbt
MODULE          = pytests.test_$(TOPLEVEL)
VERILOG_SOURCES = $(FILES)
TOPLEVEL_LANG   = verilog
SIM             = verilator

include $(shell cocotb-config --makefiles)/Makefile.sim

clean_all: clean
	rm -f results.xml
	rm -f -r pytests/__pycache__
	cd gen_machine_codes && make clean
