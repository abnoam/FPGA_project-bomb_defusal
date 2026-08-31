module debouncer (
    input  wire clk,
    input  wire reset_n,
    input  wire btn_in,    
    output reg  btn_clean  
);
    reg [19:0] count;
    reg btn_state;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            count     <= 20'd0;
            btn_state <= 1'b0;
            btn_clean <= 1'b0;
        end else begin
            if ((~btn_in) != btn_state) begin
                count <= count + 1'b1;
                if (count == 20'd999_999) begin 
                    btn_state <= ~btn_in;
                    count     <= 20'd0;
                end
            end else begin
                count <= 20'd0;
            end
            
            btn_clean <= btn_state;
        end
    end
endmodule