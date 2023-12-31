# Python Testbench for Program Counter (PC)

# cocotb imports
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, Edge, Join

# standard imports
import os
import sys
import numpy as np
import logging

# adding path for utils
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', '..', 'utils'))

# utils imports
import cocotb_utils as utils

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

# logging function
def log(cycles, dut_result, expected_result):
    for i in range(cycles):
        logging.debug('--------------------  Cycle # %d  --------------------', i  )
        logging.debug('RESULT      : %s', dut_result[i].signed_integer            )
        logging.debug('EXPECTED    : %s', np.int32(expected_result[i])            )
        logging.debug('RESULT_BIN  : %s', dut_result[i].binstr                    )
        logging.debug('EXPECTED_BIN: %s', utils.int_to_bin(expected_result[i], 32))
        logging.debug('----------------------------------------------------\n\n'  )

        # assertion
        assert dut_result[i].binstr == utils.int_to_bin(expected_result[i], 32), f"PC Test Failed! for: Cycle # {i}"

# read environment variables
if ("NUM_CYCLES" in os.environ):                                                 
    num_cycles = int(os.environ["NUM_CYCLES"])                                    
else:                                                                           
    num_cycles = 1

# seed for random number generator
np.random.seed(cocotb.RANDOM_SEED)

# model function for PC ## TODO: move to a separate file
def model(cycles):
    count_values = []
    for i in range(cycles):
        count_values.append(4*i)
    return count_values
    
# reset routine
async def reset(dut):
    dut.arst_n.value = 0
    await FallingEdge(dut.clk)
    dut.arst_n.value = 1

# driver
async def driver(dut, cycles):
    for i in range(cycles):
        dut.pc_in.value = dut.pc_out.value + 4
        await Edge(dut.pc_out)

# monitor
async def monitor(dut, cycles):
    count_values = []
    for i in range(cycles):
        await RisingEdge(dut.clk)
        count_values.append(dut.pc_out.value) # This will sample the counter on the previous clock cycle because setup time is not passed yet
    return count_values

# test
@cocotb.test()
async def test_pc(dut):

    # step1: generate clock
    cocotb.start_soon(Clock(dut.clk, 10, units='ns').start())
    
    # step2: reset sequence
    reset_thread = cocotb.start_soon(reset(dut))
    await Join(reset_thread)

    # step3: start monitor and driver threads
    monitor_thread = cocotb.start_soon(monitor(dut, num_cycles))
    driver_thread  = cocotb.start_soon(driver(dut, num_cycles))
    
    # step4: wait for monitor and driver threads to finish
    await Join(driver_thread)
    dut_result = await Join(monitor_thread)

    # step5: calculate expected result
    expected_result = model(num_cycles)

    # step6: log results
    log(num_cycles, dut_result, expected_result)
    