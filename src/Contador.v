module display_mux (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [3:0] in_uni,
    input  wire [3:0] in_dec,
    // input  wire [3:0] in_cen,     // ELIMINADO: Ya no usamos centenas
    output reg  [6:0] seg,
    output reg        an             // MODIFICADO: De [3:0] a 1 solo bit para cumplir con 8 salidas totales
);

    reg [19:0] refresh_counter;
    wire       digit_select;         // MODIFICADO: De [1:0] a 1 bit (solo alterna entre 2 estados)
    reg [3:0]  hex_digit;

    always @(posedge clk or posedge rst_n) begin
        if (rst_n) 
            refresh_counter <= 20'b0;
        else 
            refresh_counter <= refresh_counter + 1'b1;
    end

    // MODIFICADO: Usamos un bit del contador para alternar entre UNIDADES y DECENAS
    assign digit_select = refresh_counter[17]; 

    always @(*) begin
        // multiplexación para 2 displays
        if (digit_select == 1'b0) begin
            an = 1'b0;               // Activa primer display
            hex_digit = in_uni;
        end else begin
            an = 1'b1;               // Activa segundo display
            hex_digit = in_dec;
        end
    end

    // Decodificador de 7 Segmentos
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
    parameter CLK_FREQ = 50000000  
)(
    input  wire       clk,
    input  wire       rst_n,   
    // MODIFICADO: Agrupado en un solo bus de 8 bits para Tiny Tapeout (uo_out)
    // uo_out[6:0] son los segmentos, uo_out[7] es el ánodo
    output wire [7:0] uo_out         
);

    localparam MAX_COUNT = CLK_FREQ / 4;
    reg [31:0] counter_4hz;
    reg        tick; 
    reg [6:0]  valor_contador;       // MODIFICADO: 7 bits son suficientes

    wire [3:0] w_decenas;
    wire [3:0] w_unidades;
    wire [6:0] w_seg;
    wire       w_an;

    // Divisor de frecuencia
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
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

    // Contador
    always @(posedge clk or posedge rst_n) begin
        if (rst_n) begin
            valor_contador <= 7'd0;
        end else if (tick) begin
            if (valor_contador >= 99) // MODIFICADO: Reset al llegar a 99
                valor_contador <= 7'd0;
            else
                valor_contador <= valor_contador + 1'b1;
        end
    end

    // Separador de Dígitos
    always @(*) begin
        // w_centenas = valor_contador / 100; // ELIMINADO
        w_decenas  = valor_contador / 10;
        w_unidades = valor_contador % 10;
    end

    display_mux u_display_driver (
        .clk     (clk),
        .rst_n   (rst_n),
        .in_uni  (w_unidades),
        .in_dec  (w_decenas),
        .seg     (w_seg),
        .an      (w_an)
    );

    // MODIFICADO: Concatenación final para las 8 salidas de Tiny Tapeout
    assign uo_out = {w_an, w_seg}; 

endmodule