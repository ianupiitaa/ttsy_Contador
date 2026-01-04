# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge


@cocotb.test()

async def test_contador(dut):
    dut._log.info("Iniciando prueba del Contador 0-99")

    # Configurar Reloj (10 MHz = 100ns de periodo)
    clock = Clock(dut.clk, 100, unit="ns")
    cocotb.start_soon(clock.start())

    # Reset inicial
    dut._log.info("Aplicando Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 5)

    
    dut._log.info("Verificando que los displays se alternen (Multiplexación)")

    
    # Esperamos a ver un cambio en el bit de selección de ánodo (uo_out[7])
    # Esto confirma que el refresh_counter está funcionando.
    
    found_anode_toggle = False
    for _ in range(200000): 
        await RisingEdge(dut.clk)
        # Convertimos dut.uo_out.value a entero para poder comparar
        if int(dut.uo_out.value) >= 128: 
            found_anode_toggle = True
            break    assert found_anode_toggle, "Error: El ánodo no cambió de estado. Revisa refresh_counter."

    # Verificar incremento del contador
    # Dado que MAX_COUNT = CLK_FREQ / 4, a 10MHz son 2,500,000 ciclos.
    
    dut._log.info("Esperando incremento del contador...")
    await ClockCycles(dut.clk, 2500000) 
    
    # Ejemplo de verificación del valor "0" en el display (Unidades)
    # seg = 7'b1000000 (0x40) para el número 0.
    # Como uo_out tiene el ánodo en el bit 7, esperamos 0x40 o 0xC0
    val = int(dut.uo_out.value) & 0x7F
    assert val == 0x40, f"Error: Se esperaba 0x40 (0 en 7-seg), se obtuvo {hex(val)}"
    
    dut._log.info("Prueba finalizada exitosamente")

async def test_project(dut):
    dut._log.info("Start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("Reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    dut._log.info("Test project behavior")

    # Set the input values you want to test
    dut.ui_in.value = 20
    dut.uio_in.value = 30

    # Wait for one clock cycle to see the output values
    await ClockCycles(dut.clk, 1)

    # The following assersion is just an example of how to check the output values.
    # Change it to match the actual expected output of your module:
    assert dut.uo_out.value == 50

    # Keep testing the module by changing the input values, waiting for
    # one or more clock cycles, and asserting the expected output values.
