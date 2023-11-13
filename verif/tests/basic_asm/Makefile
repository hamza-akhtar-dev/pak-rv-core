
ASM_FILE = test

ifndef RISCV
	$(error "RISCV is undefined. please do \
	'source setup.sh' or set it manually.")
endif

RISCV_PREFIX	?= $(RISCV)/bin/riscv32-unknown-elf-
AS		= $(RISCV_PREFIX)as
CC		= $(RISCV_PREFIX)gcc
OBJCOPY		= $(RISCV_PREFIX)objcopy
OBJDUMP		= $(RISCV_PREFIX)objdump
SIZE		= $(RISCV_PREFIX)size
NM  = $(RISCV_PREFIX)nm

CURDIR    = .
SDIR      = $(CURDIR)/src
IDIR      = $(CURDIR)/include
TESTDIR   = $(CURDIR)/test
ODIR      = $(CURDIR)/obj

_OBJS     = test.o 
OBJS      = $(addprefix $(ODIR)/, $(_OBJS))
ALL_OBJS  =  $(OBJS)
EXE       = $(ODIR)/test.out

FLAGS_COMMON = -march=rv32i -mabi=ilp32 #-O -g -mcmodel=medany -gdwarf-2
LDFLAGS = -T linker.ld -nostdlib $(FLAGS_COMMON)

all: $(EXE)

$(ODIR):
	mkdir -p $(ODIR)

$(ODIR)/%.o: $(SDIR)/%.s $(ODIR)
	$(AS) -c -o $@ $< $(FLAGS_COMMON)


$(EXE): $(ALL_OBJS)
	$(CC) -o $@ $^ $(LDFLAGS) > /dev/null	
	$(OBJDUMP) -S -s $@ > $@.dump
	cp $(CURDIR)/obj/test.out $(CURDIR)/test.elf
	$(OBJCOPY) -O binary --only-section=.data* --only-section=.text* $(CURDIR)/test.elf $(CURDIR)/data.bin
	python3 maketxt.py $(CURDIR)/data.bin > $(CURDIR)/test.txt
	cp $(CURDIR)/test.txt $(CURDIR)/test.mem


.PHONY: clean
clean:
	rm -rf $(OBJS) $(EXE) $(EXE).dump $(CURDIR)/test.*

