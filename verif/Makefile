
TOP_DIR      = $(shell pwd)/..
SRC_DIR      = $(TOP_DIR)/src
INCLUDE_DIR  = $(TOP_DIR)/include

FILES       += $(SRC_DIR)/if_stage.sv
FILES       += $(SRC_DIR)/id_stage.sv

TEST         = if_stage

ifeq ($(TEST), if_stage)
    TOPLEVEL = $(TEST)
    PARAMS   = -GDW=32 -GIMEM_SZ_IN_KB=1
else ifeq ($(TEST), id_stage)
    TOPLEVEL = $(TEST)
    PARAMS   = -GDW=32
endif

EXTRA_ARGS      = vconfig.vlt -I$(INCLUDE_DIR) $(PARAMS) --trace --trace-structs #--debug --gdbbt
MODULE          = pytests.test_$(TOPLEVEL)
VERILOG_SOURCES = $(FILES)
TOPLEVEL_LANG   = verilog
SIM             = verilator

include $(shell cocotb-config --makefiles)/Makefile.sim

