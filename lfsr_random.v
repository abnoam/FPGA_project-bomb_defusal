
module lfsr_random (
    input  wire        clk,
    input  wire        rst_n,
    output reg  [23:0] random_code
);
    reg [23:0] lfsr;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr        <= 24'hACE126;
            random_code <= 24'd0;
        end else begin
            lfsr <= {lfsr[22:0], lfsr[23] ^ lfsr[22] ^ lfsr[21] ^ lfsr[16]};
            
            random_code[23:20] <= lfsr[23:20] % 10;
            random_code[19:16] <= lfsr[19:16] % 10;
            random_code[15:12] <= lfsr[15:12] % 10;
            random_code[11:8]  <= lfsr[11:8]  % 10;
            random_code[7:4]   <= lfsr[7:4]   % 10;
            random_code[3:0]   <= lfsr[3:0]   % 10;
        end
    end
endmodule