# This test checks for Atomic memory operations support

addi x1, x0, 0xfe
addi x2, x0, 0x1
addi x3, x0, 0x3

sw x1, 0(x0)
add x5, x1, x0

# Test AMOADD
keep_checking:
    amoadd.w x4, x2, (x0)
    beq x4, x5, keep_checking

addi x1, x0, 1
addi x1, x0, 2
addi x1, x0, 3
addi x1, x0, 4
addi x1, x0, 5
lw x5, 0(x0)
