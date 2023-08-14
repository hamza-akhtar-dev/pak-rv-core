# Utilities Python Libary for Cocotb Testbenches

def int_to_bin(value, width):
    return bin(value & (2**width-1))[2:].zfill(width)

