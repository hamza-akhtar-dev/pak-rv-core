# Assembly code to test the forwarding unit

start:
    addi x1, x1, 15
    addi x1, x1, 20
    add  x1, x1, x1
    add  x1, x1, x1

# Test passes if x1 = 140
