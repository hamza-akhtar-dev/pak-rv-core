li x9, 9 #1001
li x10, 7 #111
li x11, 5 #101
csrrw x12, mtvec, x9 #x12=0, mtvec=9
csrrs x13, mtvec, x10 #x13=9, mtvec=1111=f
csrrc x14, mtvec, x11 #x13=f, mtvec=1010=a
csrrci x15, mtvec, 2 #x14=a, mtvec=1000=8
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
add x0, x0, x0
