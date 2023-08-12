# Pak-RV-Core
- This is formal start of the project. This readme will contain all the details of the project.
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