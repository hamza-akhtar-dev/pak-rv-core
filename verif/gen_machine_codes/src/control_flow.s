test_beq:
    addi x1, x0, 12
    addi x2, x0, 12
    nop
    nop
    nop
    nop
    beq  x1, x2, test_jal
    nop
    nop
    nop
    nop
test_jal:
    jal x6, test_jalr
    nop
    nop
    nop
    nop
test_jalr:
    la x7, end
    nop
    nop
    nop
    nop
    jalr x8, x7, 0
    nop
end:
    addi x20, x0, 202
    nop
    nop
    nop
    nop
