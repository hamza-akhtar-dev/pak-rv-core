
# MACHINE_LANG can be either asm or c, this is choice whether
# we want to convert asm to machine code or c to machine code

MACHINE_LANG = asm
ASM_FILE     = gcd
C_FILE       = factorial
TEST         = if_stage

ifeq ($(MACHINE_LANG), asm)
    MACHINE_CODE_GEN_TARGET = asm_to_machine
else ifeq ($(MACHINE_LANG), c)
    MACHINE_CODE_GEN_TARGET = c_to_machine
else
    MACHINE_CODE_GEN_TARGET = asm_to_machine
endif

gen_machine_codes:
	@cd verif/gen_machine_codes; make $(MACHINE_CODE_GEN_TARGET) ASM_FILE=$(ASM_FILE) C_FILE=$(C_FILE)

compile_and_simulate:
	@cd verif && make TEST=$(TEST)

clean:
	@cd verif && make clean_all

all: gen_machine_codes compile_and_simulate
