start:
    li x1, 0xdeadbeef
    sw x1, 0(x0)
    lw x2, 0(x0)
    add x3, x2, x0
