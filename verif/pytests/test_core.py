# Python Testbench for Core

# cocotb imports
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Join

# standard imports
import sys
import numpy as np
import logging

# logging setup
for handler in logging.root.handlers[:]:
    logging.root.removeHandler(handler)
    logging.basicConfig(
        level    = logging.DEBUG,
        format   = "%(message)s",
        handlers = [
            logging.StreamHandler(sys.stdout)                   
        ]
    )

# seed for random number generator
np.random.seed(cocotb.RANDOM_SEED)

# reset routine
async def reset(dut):
    dut.arst_n.value = 0
    await FallingEdge(dut.clk)
    dut.arst_n.value = 1

# driver
async def driver(dut):
    for i in range(500):
        await RisingEdge(dut.clk)

# test
@cocotb.test()
async def test_core(dut):

    # step1: generate clock
    cocotb.start_soon(Clock(dut.clk, 10, units='ns').start())
    
    # step2: reset sequence
    reset_thread = cocotb.start_soon(reset(dut))
    await Join(reset_thread)

    # step3: driver thread
    driver_thread  = cocotb.start_soon(driver(dut))
    
    # step4: wait for monitor and driver threads to finish
    await Join(driver_thread)

