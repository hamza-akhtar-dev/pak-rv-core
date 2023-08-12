
ASM_FILE = asm_code
C_FILE   = factorial

asm_to_machine: clean
	@mkdir -p build
	@riscv32-unknown-elf-as -c -o build/$(ASM_FILE).o src/$(ASM_FILE).s -march=rv32i -mabi=ilp32
	@riscv32-unknown-elf-gcc -o build/$(ASM_FILE).elf build/$(ASM_FILE).o -T linker.ld -nostdlib -march=rv32i -mabi=ilp32 > /dev/null
	@riscv32-unknown-elf-objcopy -O binary --only-section=.data* --only-section=.text* build/$(ASM_FILE).elf build/$(ASM_FILE).bin
	@python3 maketxt.py build/$(ASM_FILE).bin > build/$(ASM_FILE).txt
	@riscv32-unknown-elf-objdump -S -s build/$(ASM_FILE).elf > build/$(ASM_FILE).dump
	@cp build/$(ASM_FILE).txt build/machine_code.mem

c_to_machine: clean
	@mkdir -p build
	@riscv32-unknown-elf-as -c -o build/startup.o src/startup.s -march=rv32i -mabi=ilp32
	@riscv32-unknown-elf-gcc -c -o build/$(C_FILE).o src/$(C_FILE).c -march=rv32i -mabi=ilp32
	@riscv32-unknown-elf-gcc -o build/$(C_FILE).elf build/$(C_FILE).o build/startup.o -T linker.ld -nostdlib -march=rv32i -mabi=ilp32
	@riscv32-unknown-elf-objcopy -O binary --only-section=.data* --only-section=.text* build/$(C_FILE).elf build/$(C_FILE).bin
	@python3 maketxt.py build/$(C_FILE).bin > build/$(C_FILE).txt
	@riscv32-unknown-elf-objdump -S -s build/$(C_FILE).elf > build/$(C_FILE).dump
	@cp build/$(C_FILE).txt build/machine_code.mem

clean:
	@rm -rf build