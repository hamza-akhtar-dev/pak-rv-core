# Python Testbench for Arethmetic Logic Unit (ALU)

# cocotb imports
import cocotb
from cocotb.triggers import Timer, Edge, Join

# standard imports
import random
import os
import logging
import sys

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
def log(RANDOM_SEED, num_test_cases, dut_a_arr, dut_b_arr, op_arr, dut_res_arr, model_res_arr):
    for i in range(num_test_cases):
        logging.debug('--------------------  Test # %d  --------------------', i)
        logging.debug('RANDOM_SEED : %s', RANDOM_SEED                           )
        logging.debug('operation   : %s', op_arr[i]                             )
        logging.debug('opr_a       : %s', dut_a_arr[i]                          )
        logging.debug('opr_b       : %s', dut_b_arr[i]                          )
        logging.debug('RESULT      : %s', int(dut_res_arr[i])                   )
        logging.debug('EXPECTED    : %s', model_res_arr[i]                      )
        logging.debug('STATUS      : %s', dut_res_arr[i] == model_res_arr[i]    )
        logging.debug('----------------------------------------------------\n\n')

num_test_cases = 10

# read environment variables
if ("NUM_TESTS" in os.environ):                                                 
    num_tests = int(os.environ["NUM_TESTS"])                                    
else:                                                                           
    num_tests = 1

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
        opr_a_arr.append(random.randint(0, 2000))
        opr_b_arr.append(random.randint(0, 2000))
        op_arr.append(random.randint(0, 1))

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
    log(cocotb.RANDOM_SEED, num_test_cases, opr_a_arr, opr_b_arr, op_arr, dut_result, expected_result)
    