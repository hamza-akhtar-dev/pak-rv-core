OUTPUT_ARCH("riscv")
ENTRY( _start )

IMEM_BASE  = 0x100000000;

STACK_SIZE       = 16K;
STACK_FENCE_SIZE = 16;

SECTIONS
{
   /* boot addr */
   . = IMEM_BASE;
   .boot   : { *(.boot) }
   .text   : { *(.text) }
   .data : { *(.data) }
   .bss : { *(.bss) }
   . = ALIGN(8);
   .tohost  : { *(.tohost) }

   STACK_END = .;
   .stack_fence : { */boot.o(._stack_fence) }
   . = STACK_END + STACK_SIZE + STACK_FENCE_SIZE;
   STACK_BASE = .;
   . = ALIGN(8);
   
   _end = .;
}
