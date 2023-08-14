# Python Testbench for Arethmetic Logic Unit (ALU)

# cocotb imports
import cocotb
from cocotb.triggers import Timer, Edge, Join

# standard imports
import os
import sys
import numpy as np
import random
import logging

# adding path for utils
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', '..', 'utils'))

# utils imports
import cocotb_utils as utils

# constants
DATA_WIDTH = 32

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
def log(num_test_cases, dut_a_arr, dut_b_arr, op_arr, dut_res_arr, model_res_arr):
    for i in range(num_test_cases):
        logging.debug('--------------------  Test # %d  --------------------', i)
        logging.debug('operation   : %s', op_arr[i]                             )
        logging.debug('opr_a       : %s', np.int32(dut_a_arr[i])                )
        logging.debug('opr_b       : %s', np.int32(dut_b_arr[i])                )
        logging.debug('RESULT      : %s', dut_res_arr[i].signed_integer         )
        logging.debug('EXPECTED    : %s', np.int32(model_res_arr[i])            )
        logging.debug('RESULT_BIN  : %s', dut_res_arr[i].binstr                 )
        logging.debug('EXPECTED_BIN: %s', utils.int_to_bin(model_res_arr[i], 32))
        logging.debug('----------------------------------------------------\n\n')

        # assertion
        assert dut_res_arr[i].binstr == utils.int_to_bin(model_res_arr[i], 32), f"ALU Test Failed! for: Test # {i}"

# read environment variables
if ("NUM_PERMS" in os.environ):                                                 
    num_perms = int(os.environ["NUM_PERMS"])                                    
else:                                                                           
    num_perms = 1

if ("NUM_TEST_CASES" in os.environ):                                                 
    num_test_cases = int(os.environ["NUM_TEST_CASES"])                                    
else:                                                                           
    num_test_cases = 1

# seed for random number generator
np.random.seed(cocotb.RANDOM_SEED)

# model function for ALU ## TODO: move to a separate file
def model(num_test_cases, opr_a_arr, opr_b_arr, op_arr):
    opr_res_arr = []
    for i in range(num_test_cases):
        if (op_arr[i] == 0):
            opr_res_arr.append(opr_a_arr[i] + opr_b_arr[i])
        else:
            opr_res_arr.append(opr_a_arr[i] - opr_b_arr[i])
    return opr_res_arr
    
# input generator
def generate_inputs(num_test_cases, opr_a_arr, opr_b_arr, op_arr):
    for _ in range(num_test_cases):
        opr_a_arr.append(np.random.randint(np.iinfo(np.int32).min, np.iinfo(np.int32).max))
        opr_b_arr.append(np.random.randint(np.iinfo(np.int32).min, np.iinfo(np.int32).max))
        op_arr.append(np.random.randint(0, 1))

# driver
async def driver(dut, num_test_cases, delay, opr_a_arr, opr_b_arr, op_arr):
    for i in range(num_test_cases):
        dut.opr_a.value = opr_a_arr[i]
        dut.opr_b.value = opr_b_arr[i]
        dut.op.value    = op_arr[i]
        await Timer(delay, units='ns')

# monitor
async def monitor(dut, num_test_cases):
    opr_res_arr = []
    for i in range(num_test_cases):
        await Edge(dut.opr_result)
        opr_res_arr.append(dut.opr_result.value)
    return opr_res_arr

# test
@cocotb.test()
async def test_alu(dut):
    opr_a_arr = []
    opr_b_arr = []
    op_arr    = []

    # step1: generate inputs
    generate_inputs(num_test_cases, opr_a_arr, opr_b_arr, op_arr)

    # step2: start monitor and driver threads
    monitor_thread = cocotb.start_soon(monitor(dut, num_test_cases))
    driver_thread  = cocotb.start_soon(driver(dut, num_test_cases, 5, opr_a_arr, opr_b_arr, op_arr))

    # step3: wait for monitor and driver threads to finish
    await Join(driver_thread)
    dut_result = await Join(monitor_thread)

    # step4: calculate expected result
    expected_result = model(num_test_cases, opr_a_arr, opr_b_arr, op_arr)

    # step5: log results
    log(num_test_cases, opr_a_arr, opr_b_arr, op_arr, dut_result, expected_result)
    