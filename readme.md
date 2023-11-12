# Pak-RV-Core
- This is formal start of the project. This readme will contain all the details of the project.
## Simulation Pre-requisites
- [RISC-V GCC Toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain),  [Pre-built version of RISC-V GCC Toolchain (Prefered)](https://github.com/stnolting/riscv-gcc-prebuilt/releases/download/rv32i-4.0.0/riscv32-unknown-elf.gcc-12.1.0.tar.gz)
- [Verilator (latest verision)](https://verilator.org/guide/latest/install.html#git-quick-install)
- [Cocotb (for block level testing)](https://github.com/cocotb/cocotb)
- [RISC-OF and A Reference Model (spike/sail)](https://riscof.readthedocs.io/en/latest/installation.html)
## Getting Started
To simulate the project with pytests which use cocotb and primary simulator as verilator, you can use the command:
```
make all
```
This will generate machine codes and then run the simulation. The above command can used in variety like:
```
make all TEST=if_stage MACHINE_LANG=asm ASM_FILE=gcd C_FILE=factorial
```
Explanation is:  
- TEST: Optional argument telling which module you want to test. Default value is if_stage.  
- MACHINE_LANG: Optional argument telling which language you have written the code to be converted to RISCV machine code. It has two values either **asm** (assembly) or **c** (c language). Its default valus is **asm**.  
- ASM_FILE: Optional argument which specifies what is the assembly file (name only without extension) to be converted to machine code. Default value is *gcd*  
- C_FILE: Optional argument which specifies what is the C file (name only without extension) to be converted to machine code. Default value is *factorial*  
## Running RISCOF Compliance Tests
- Clone the repository:
```
git clone --recurse-submodules https://github.com/hamza-akhtar-dev/pak-rv-core
```
- Go to `verif` directory:
```
cd verif/riscof_compliance/
```
- Run the shell script to run RISCOF Framework on the PakRV Core:
```
chmod +x run-compliance.sh
./run-compliance.sh
```
## Contriubution Guidelines

- For detailed contribution guidlines please go to [contribution guidelines](./docs/contribution_guidelines.md)