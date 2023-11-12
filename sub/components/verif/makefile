# design under test
DUT = alu

# directory paths
TOP_DIR      = $(shell pwd)/..
SRC_DIR      = $(TOP_DIR)/src
INCLUDE_DIR  = $(TOP_DIR)/include

# dut parameters
ifeq ($(DUT), alu)
    TOPLEVEL  = $(DUT)
    PARAMS    = -GDATA_WIDTH=32
	MODULE    = pytests.test_$(TOPLEVEL)
	_SRCS     = alu.sv
	SIM_BUILD = build/build_alu
else ifeq ($(DUT), pc)
    TOPLEVEL  = $(DUT)
    PARAMS    = -GPC_SIZE=32
	MODULE    = pytests.test_$(TOPLEVEL)
	_SRCS     = pc.sv
	SIM_BUILD = build/build_pc
else ifeq ($(DUT), rf)
    TOPLEVEL  = $(DUT)
    PARAMS    = -GDATA_WIDTH=32 -GNUM_REGISTERS=32
	MODULE    = pytests.test_$(TOPLEVEL)
	_SRCS     = rf.sv
	SIM_BUILD = build/build_rf
endif

# path substitution
SRCS = $(patsubst %,$(SRC_DIR)/%,$(_SRCS))

# debug/trace settings
ifeq ($(DEBUG), on)
	SETTINGS = --trace --trace-structs --debug --gdbbt
endif

# cocotb variables
EXTRA_ARGS      = vconfig.vlt -I$(INCLUDE_DIR) $(PARAMS) $(SETTINGS)
VERILOG_SOURCES = $(SRCS)
TOPLEVEL_LANG   = verilog
SIM             = verilator

include $(shell cocotb-config --makefiles)/Makefile.sim

clean_all: clean
	rm -f results.xml
	rm -f -r pytests/__pycache__