<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

El presente proyecto fue modificado a partir de la sintesis de un contador (255 unidades del 0 al 255) modelado en SystemVerilog, posteriormente para la compatibilidad de tiny tapeout fue modificado a un archivo verilog, considerando unicamente 8 salidas, lo cual limita el conteo hasta 99, 2 displays y los respectivos segmentos.
Se considera un contador de refrescoy un bloque de multiplezacion que asigna a cada salida el valor de una senal como las partes fundamentales del presente trabajo

## How to test

Para probar el funcionamiento de manera rudimentaria, puede tomar el archivo .v or verilog y correrlo en Quartus con un test bench simble que unicamnete mande un reset, asi podras ver la interrupcion del conteo.
Sin embargo, si gustas probarlo directamente dentro del repositorio de Git hub, debes copiar el repositorio, permitir las cciones de git hub y posteriormente modificar el tb.py en la carpeta de test, recomiendo unicamente modificar los tiempos en los que las tareas se ejecutan (los ciclos y los periodos)

## External hardware

Puede usarse una fpga con cyclone asignando los pines de salida a diferentes displays de 7 segmentos o a un display con 3 segmentos (preferentemente para que sea compatible), dada la segunda opcion, no se necesita hardware
