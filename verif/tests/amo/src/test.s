# This test checks for Atomic memory operations support

addi x1, x0, 0xfe
addi x2, x0, 0x1
addi x3, x0, 0x3

sw x1, 0(x0)

# Test AMOADD
amoadd.w x4, x2, (x0)
nop
nop
nop
nop
nop
lw x5, 0(x0)
