# boot.s

   .global main   # external
   .option norelax
   .option norvc

   .section .boot,"aw",@progbits
   .global _start
   .type _start, @function
_start:   

   call main

exit:
   la t1, tohost
1: sw a0,  (0)(t1)
   j 1b

_spin:
   j _spin

   .section ._stack_fence,"aw",@progbits
   .zero 16

   .section .tohost,"aw",@progbits
   .align 6
   .global tohost
tohost:
   .word 0
   .global fromhost
fromhost:
   .word 0

