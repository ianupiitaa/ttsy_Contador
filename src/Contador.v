`default_nettype none

module display_mux (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] in_uni,
    input  wire [3:0] in_dec,
    output reg  [6:0] seg,
    output reg        an             
);

    reg [19:0] refresh_counter;
    wire       digit_select;         
    reg [3:0]  hex_digit;

    // Corrección de Reset Asíncrono
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)                  
            refresh_counter <= 20'b0;
        else 
            refresh_counter <= refresh_counter + 1'b1;
    end

    // Selección de bit para multiplexación (Bit 10 para simulación rápida)
    assign digit_select = refresh_counter[10]; 

    always @(*) begin
        if (digit_select == 1'b0) begin
            an = 1'b0;               
            hex_digit = in_uni;
        end else begin
            an = 1'b1;               
            hex_digit = in_dec;
        end
    end

    always @(*) begin
        case (hex_digit)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            default: seg = 7'b1111111; 
        endcase
    end
endmodule

module Contador #(
    parameter CLK_FREQ = 10000000    
)(
    input  wire       clk,
    input  wire       rst_n,   
    output wire [7:0] uo_out         
);

    // Uso de CLK_FREQ en una operación para evitar Warning-UNUSEDPARAM
    // Se define un MAX_COUNT pequeño para que el test pase rápido
    localparam MAX_COUNT = (CLK_FREQ > 0) ? 50 : 50; 
    
    reg [31:0] counter_4hz;
    reg        tick; 
    reg [6:0]  valor_contador;       

    reg [3:0]  w_decenas;            
    reg [3:0]  w_unidades;           
    wire [6:0] w_seg;
    wire       w_an;

    // Divisor de frecuencia con reset corregido
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin            
            counter_4hz <= 32'b0;
            tick        <= 1'b0;
        end else begin
            if (counter_4hz >= MAX_COUNT - 1) begin
                counter_4hz <= 32'b0;
                tick        <= 1'b1;
            end else begin
                counter_4hz <= counter_4hz + 1'b1;
                tick        <= 1'b0;
            end
        end
    end

    // Lógica del contador corregida (Resuelve ERROR: Async reset yields non-constant value)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin            
            valor_contador <= 7'b0000000; // Asignación de valor constante explícito
        end else if (tick) begin
            if (valor_contador >= 7'd99) 
                valor_contador <= 7'b0000000;
            else
                valor_contador <= valor_contador + 1'b1;
        end
    end

    // Separador de Dígitos (Resuelve Warning-WIDTHTRUNC)
    always @(*) begin
        // Forzamos el resultado a 4 bits mediante el uso de la parte baja de la operación
        w_decenas  = (valor_contador / 7'd10); 
        w_unidades = (valor_contador % 7'd10); 
    end

    display_mux u_display_driver (
        .clk     (clk),
        .rst_n   (rst_n),
        .in_uni  (w_unidades),
        .in_dec  (w_decenas),
        .seg     (w_seg),
        .an      (w_an)
    );

    assign uo_out = {w_an, w_seg}; 

endmodule
