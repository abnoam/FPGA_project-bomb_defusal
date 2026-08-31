
module seven_seg_driver (
    input  wire       clk,
    input  wire [7:0] timer_sec,
    input  wire       display_bang,
    input  wire       display_good,
    output reg  [6:0] hex0,
    output reg  [6:0] hex1,
    output reg  [6:0] hex2,
    output reg  [6:0] hex3
);

    function [6:0] decode_digit(input [3:0] digit);
        case (digit)
            4'd0: decode_digit = 7'b0000001;
            4'd1: decode_digit = 7'b1001111;
            4'd2: decode_digit = 7'b0010010;
            4'd3: decode_digit = 7'b0000110;
            4'd4: decode_digit = 7'b1001100;
            4'd5: decode_digit = 7'b0100100;
            4'd6: decode_digit = 7'b0100000;
            4'd7: decode_digit = 7'b0001111;
            4'd8: decode_digit = 7'b0000000;
            4'd9: decode_digit = 7'b0000100;
            default: decode_digit = 7'b1111111; 
        endcase
    endfunction

    wire [3:0] hundreds = timer_sec / 100;
    wire [3:0] tens     = (timer_sec % 100) / 10;
    wire [3:0] ones     = timer_sec % 10;

    localparam CHAR_G   = 7'b0100000;
    localparam CHAR_O   = 7'b0000001;
    localparam CHAR_D   = 7'b1000010;

    localparam CHAR_B   = 7'b1100000;
    localparam CHAR_A   = 7'b0001000;
    localparam CHAR_N   = 7'b1101010;
    localparam CHAR_OFF = 7'b1111111;

    always @(*) begin
        if (display_bang) begin
            hex3 = CHAR_B;
            hex2 = CHAR_A;
            hex1 = CHAR_N;
            hex0 = CHAR_G;
        end else if (display_good) begin
            hex3 = CHAR_G;
            hex2 = CHAR_O;
            hex1 = CHAR_O;
            hex0 = CHAR_D;
        end else begin
            hex0 = decode_digit(ones);
            hex1 = (hundreds > 0 || tens > 0) ? decode_digit(tens) : CHAR_OFF;
            hex2 = (hundreds > 0) ? decode_digit(hundreds) : CHAR_OFF;
            hex3 = CHAR_OFF;
        end
    end

endmodule