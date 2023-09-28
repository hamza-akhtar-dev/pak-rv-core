# design under test
DUT = core

# directory paths
TOP_DIR         = $(shell pwd)/..
SRC_DIR         = $(TOP_DIR)/src
INCLUDE_DIR     = $(TOP_DIR)/include

# sub directory paths
SUB_DIR         = $(TOP_DIR)/sub
SUB_SRC_DIR     = $(SUB_DIR)/src
SUB_INCLUDE_DIR = $(SUB_DIR)/include

# dut parameters
ifeq ($(DUT), core)
	TOPLEVEL  = $(DUT)_top
	PARAMS    = -GDATA_WIDTH=32
	MODULE    = pytests.test_core
	_SRCS     = ctrl_unit.sv if_stage.sv id_stage.sv ex_stage.sv mem_stage.sv wb_stage.sv core.sv core_top.sv mem.sv
	_SRCS_SUB = cfu.sv alu.sv dmem.sv pc.sv rf.sv lsu.sv fu.sv hdu.sv
	SIM_BUILD = build/build_$(TOPLEVEL)
endif

# path substitution
SRCS     = $(patsubst %,$(SRC_DIR)/%,$(_SRCS))
SRCS_SUB = $(patsubst %,$(SUB_SRC_DIR)/%,$(_SRCS_SUB))

# debug/trace settings
ifeq ($(DEBUG), on)
	SETTINGS = --trace --trace-structs --timing
endif

# cocotb variables
EXTRA_ARGS      = vconfig.vlt -I$(INCLUDE_DIR) -I$(SUB_INCLUDE_DIR) $(PARAMS) $(SETTINGS)
VERILOG_SOURCES = $(SRCS_SUB) $(SRCS)
TOPLEVEL_LANG   = verilog
SIM             = verilator

include $(shell cocotb-config --makefiles)/Makefile.sim

clean_all: clean
	rm -f results.xml
	rm -f -r pytests/__pycache__
	cd gen_machine_codes && make clean

