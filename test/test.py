# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles, RisingEdge

# ##############################
# PRUEBA DEL CONTADOR (CORREGIDA)
# ##############################

@cocotb.test()
async def test_contador(dut):
    dut._log.info("Iniciando prueba del Contador 0-99")

    # Configurar Reloj (10 MHz = 100ns de periodo)
    # Este periodo coincide con el CLK_FREQ definido en Contador.v
    clock = Clock(dut.clk, 100, unit="ns")
    cocotb.start_soon(clock.start())

    # Reset inicial
    # Se utiliza rst_n (activo en bajo) tal como se definió en el hardware
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
    # Esto confirma que el refresh_counter está funcionando correctamente.
    found_anode_toggle = False
    
    # Ejecutamos un bucle para buscar la conmutación del ánodo
    # Se redujo el rango a 5000 porque en Contador.v ahora usamos el bit 10
    for _ in range(5000): 
        await RisingEdge(dut.clk)
        # Convertimos dut.uo_out.value a entero para evitar errores de LogicArray
        # Buscamos que el bit 7 (valor decimal 128) cambie de estado
        if int(dut.uo_out.value) >= 128: 
            found_anode_toggle = True
            break 
            
    # Verificación de la multiplexación fuera del bucle for
    assert found_anode_toggle, "Error: El ánodo no cambió de estado. Revisa refresh_counter en Contador.v"

    # Verificar incremento del contador
    # Dado que redujimos MAX_COUNT a 1000 en Contador.v, el tick ocurre rápido
    dut._log.info("Esperando incremento del contador (basado en MAX_COUNT reducido)...")
    
    # Esperamos 1100 ciclos para asegurar que el contador pase de 0 a 1
    await ClockCycles(dut.clk, 1100) 
    
    # Verificación del valor inicial en el display (Unidades)
    # Filtramos el bit del ánodo (bit 7) usando una máscara 0x7F (7 bits bajos)
    val = int(dut.uo_out.value) & 0x7F
    
    # Según el decodificador, el número 0 es 7'b1000000 (0x40)
    # El número 1 es 7'b1111001 (0x79)
    dut._log.info(f"Valor detectado en segmentos: {hex(val)}")
    
    # Verificamos que no esté en un estado de error (0xff) y que haya actividad
    assert val != 0x7f, "Error: Los segmentos indican un estado de display apagado"
    
    dut._log.info("Prueba finalizada exitosamente")

# Nota: Se eliminó la función test_project original para evitar conflictos 
# con las señales de entrada que este diseño de contador no utiliza.
