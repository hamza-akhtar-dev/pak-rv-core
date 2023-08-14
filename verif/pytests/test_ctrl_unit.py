# ============= Imports ===================

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, Join

# =========== Parameters ==================

# ========== ENUMS ==========

# ========== Driver/Monitor ===============

samples = 1000

async def driver(dut, data):
    dut.instruction <= int(data)

async def monitor(dut):
    pass


# ============ Main Test ==================

@cocotb.test()
async def ctrl_unit(dut):
    clock = Clock(dut.clk, 2, units="ns") # create 2ns period clock on port clk
    cocotb.fork(clock.start()) # start the clock

    # Reset

    await RisingEdge(dut.clk)
    dut.arst_n <=+ 1

    await RisingEdge(dut.clk)
    dut.arst_n <=+ 0

    # Set Reset to Low
    await RisingEdge(dut.clk)
    dut.arst_n <= +1

    monitor_task = cocotb.fork(monitor(dut))
    for i in range (samples):
        if (i % 4 == 0):
            driver_task = cocotb.fork(driver(dut, i))
            await RisingEdge(dut.clk)

    await Join(driver_task)
    await Join(monitor_task)

