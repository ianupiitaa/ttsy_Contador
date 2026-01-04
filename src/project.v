// /*
//  * Copyright (c) 2024 Your Name
//  * SPDX-License-Identifier: Apache-2.0
//  */

// `default_nettype none

// module tt_um_example (
//     input  wire [7:0] ui_in,    // Dedicated inputs
//     output wire [7:0] uo_out,   // Dedicated outputs
//     input  wire [7:0] uio_in,   // IOs: Input path
//     output wire [7:0] uio_out,  // IOs: Output path
//     output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
//     input  wire       ena,      // always 1 when the design is powered, so you can ignore it
//     input  wire       clk,      // clock
//     input  wire       rst_n     // reset_n - low to reset
// );

//   // All output pins must be assigned. If not used, assign to 0.
//   assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
//   assign uio_out = 0;
//   assign uio_oe  = 0;

//   // List all unused inputs to prevent warnings
//   wire _unused = &{ena, clk, rst_n, 1'b0};

// endmodule

`default_nettype none

module tt_um_Contador (
    input  wire [7:0] ui_in,    // Entradas dedicadas
    output wire [7:0] uo_out,   // Salidas dedicadas
    input  wire [7:0] uio_in,   // IOs Bidireccionales (Entrada)
    output wire [7:0] uio_out,  // IOs Bidireccionales (Salida)
    output wire [7:0] uio_oe,   // IOs Enable path
    input  wire       ena,      
    input  wire       clk,      
    input  wire       rst_n     
);

    wire [7:0] segmentos_y_anodo;

    assign uo_out  = segmentos_y_anodo; 
    
    assign uio_out = 8'b0;
    assign uio_oe  = 8'b0; 

    //DUT
    Contador #(
        .CLK_FREQ(10000000) 
    ) Contador_Unit (
        .clk   (clk),
        .rst_n (rst_n),
        .uo_out(segmentos_y_anodo) 
    );

    wire _unused = &{ui_in, uio_in, ena, 1'b0};

endmodule
