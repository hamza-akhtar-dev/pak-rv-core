# MACHINE_LANG can be either asm or c, this is choice whether
# we want to convert asm to machine code or c to machine code

DUT          ?= core
TEST 		 ?= basic_asm

ROOT=$(shell pwd)
VERIF=$(ROOT)/verif
TESTBUILD_DIR=$(ROOT)/verif/build
TESTS_DIR=$(VERIF)/tests

all: build compile_and_simulate

build:
	@echo Compiling Test : "$(TESTS_DIR)/$(TEST)"
	@cd $(TESTS_DIR)/$(TEST); make all;
	@echo Copying the test.mem file in : $(TESTBUILD_DIR)
	@cp $(TESTS_DIR)/$(TEST)/test.mem $(TESTBUILD_DIR)

compile_and_simulate:
	@cd verif && make DUT=$(DUT)

.PHONY: clean
clean:
	@cd verif && make clean_all

