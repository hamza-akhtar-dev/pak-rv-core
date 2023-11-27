 # Reset handler and interrupt vector table entries
.global reset_handler
.type reset_handler, %object
.section .text.vector_table,"a",%progbits

# this entry is to align reset_handler at address 0x04
  .word    0x00000013
  j        reset_handler
  .word    0x00000013


reset_handler:

# Load the initial stack pointer value.
  la   sp, _sp


# Call user 'main(0,0)' (.data/.bss sections initialized there)
  li   a0, 0
  li   a1, 0
  call main