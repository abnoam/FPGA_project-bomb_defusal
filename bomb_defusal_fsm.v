// File: bomb_defusal_fsm.v

module bomb_defusal_fsm #(
    parameter CODE_LENGTH = 4
)(
    input  wire        clk,
    input  wire        reset_n,
    input  wire        btn_submit,
    input  wire [3:0]  digit_in,
    input  wire [1:0]  diff_level,
    input  wire [23:0] random_code_in,
    
    output reg  [7:0]  timer_sec,
    output reg  [2:0]  current_digit_idx,
    output reg  [3:0]  diff_led_count,
    output reg  [9:0]  led_diff_mask,
    output reg  [9:0]  led_green_progress, // 10 לדים עבור לוח DE0
    output reg  [2:0]  game_state,
    output reg         led_green_flash,
    output reg         display_bang,
    output reg         display_good
);

    localparam STATE_IDLE       = 3'b000;
    localparam STATE_PLAY       = 3'b001;
    localparam STATE_WIN        = 3'b010;
    localparam STATE_BANG       = 3'b011;
    localparam STATE_DIGIT_GOOD = 3'b100;

    reg [3:0] secret_code [0:3];
    
    // גילוי עליית דופק ללחצן Submit (איתחול ל-1 מונע דופק מזויף ביציאה מ-Reset)
    reg btn_submit_d;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) 
            btn_submit_d <= 1'b1;
        else          
            btn_submit_d <= btn_submit;
    end
    wire btn_submit_pulse = btn_submit & ~btn_submit_d;

    // מחלק שעון לשנייה אחת (טיימר משחק)
    reg [25:0] clk_divider;
    wire one_second_tick = (clk_divider == 26'd49_999_999);

    // השהיה של שנייה אחת להצגת GOOD בין ספרות
    reg [25:0] good_delay_cnt;
    wire good_delay_done = (good_delay_cnt == 26'd49_999_999);

    // מחולל הבהוב (~1.5Hz)
    reg [24:0] flash_divider;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) flash_divider <= 0;
        else flash_divider <= flash_divider + 1'b1;
    end
    always @(*) begin
        led_green_flash = flash_divider[24];
    end

    // ספירת שניות בתוך משחק
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            clk_divider <= 26'd0;
        else if (game_state == STATE_PLAY) begin
            if (one_second_tick)
                clk_divider <= 26'd0;
            else
                clk_divider <= clk_divider + 1'b1;
        end else begin
            clk_divider <= 26'd0;
        end
    end

    // ספירת השהיה עבור הצגת GOOD בין ספרות
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            good_delay_cnt <= 26'd0;
        else if (game_state == STATE_DIGIT_GOOD) begin
            if (good_delay_done)
                good_delay_cnt <= 26'd0;
            else
                good_delay_cnt <= good_delay_cnt + 1'b1;
        end else begin
            good_delay_cnt <= 26'd0;
        end
    end

    // מכונת מצבים ראשית
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            game_state        <= STATE_IDLE;
            timer_sec         <= 8'd120;
            current_digit_idx <= 3'd0;
            display_good      <= 1'b0;
            display_bang      <= 1'b0;
            
            secret_code[0]    <= 4'd1;
            secret_code[1]    <= 4'd2;
            secret_code[2]    <= 4'd3;
            secret_code[3]    <= 4'd4;
        end else begin
            case (game_state)
                STATE_IDLE: begin
                    display_good      <= 1'b0;
                    display_bang      <= 1'b0;
                    current_digit_idx <= 3'd0;
                    
                    // עדכון זמן התחלתי בלייב לפי דרגת הקושי
                    case (diff_level)
                        2'b00:   timer_sec <= 8'd120; // קל: 120 שניות
                        2'b01:   timer_sec <= 8'd90;  // בינוני: 90 שניות
                        default: timer_sec <= 8'd60;  // קשה: 60 שניות
                    endcase
                    
                    if (btn_submit_pulse) begin
                        secret_code[0] <= random_code_in[3:0]   % 4'd10;
                        secret_code[1] <= random_code_in[7:4]   % 4'd10;
                        secret_code[2] <= random_code_in[11:8]  % 4'd10;
                        secret_code[3] <= random_code_in[15:12] % 4'd10;
                        
                        game_state <= STATE_PLAY;
                    end
                end

                STATE_PLAY: begin
                    display_good <= 1'b0;
                    display_bang <= 1'b0;

                    if (one_second_tick) begin
                        if (timer_sec > 8'd0)
                            timer_sec <= timer_sec - 1'b1;
                        else
                            game_state <= STATE_BANG;
                    end

                    if (btn_submit_pulse) begin
                        if (digit_in == secret_code[current_digit_idx]) begin
                            if (current_digit_idx == 3'd3) begin
                                game_state <= STATE_WIN;
                            end else begin
                                game_state <= STATE_DIGIT_GOOD;
                            end
                        end else begin
                            if (timer_sec > 8'd5) begin
                                timer_sec <= timer_sec - 8'd5;
                            end else begin
                                timer_sec  <= 8'd0;
                                game_state <= STATE_BANG;
                            end
                        end
                    end
                end

                STATE_DIGIT_GOOD: begin
                    display_good <= 1'b1;
                    display_bang <= 1'b0;
                    
                    if (good_delay_done) begin
                        current_digit_idx <= current_digit_idx + 1'b1;
                        display_good      <= 1'b0;
                        game_state        <= STATE_PLAY;
                    end
                end

                STATE_WIN: begin
                    display_good <= led_green_flash; 
                    display_bang <= 1'b0;
                end

                STATE_BANG: begin
                    display_good <= 1'b0;
                    display_bang <= led_green_flash;
                end

                default: game_state <= STATE_IDLE;
            endcase
        end
    end

    // חישוב הפרש הניחוש מהספרה הסודית
    reg [3:0] digit_diff;
    always @(*) begin
        if (digit_in > secret_code[current_digit_idx])
            digit_diff = digit_in - secret_code[current_digit_idx];
        else
            digit_diff = secret_code[current_digit_idx] - digit_in;
    end

    // לוגיקת נוריות LED ירוקות (הפרש 0-9)
    always @(*) begin
        if (game_state == STATE_WIN) begin
            led_green_progress = led_green_flash ? 10'b1111111111 : 10'b0000000000;
        end else if (game_state == STATE_DIGIT_GOOD) begin
            led_green_progress = 10'b1111111111;
        end else if (game_state == STATE_PLAY) begin
            case (digit_diff)
                4'd0:    led_green_progress = 10'b0000000000;
                4'd1:    led_green_progress = 10'b0000000001;
                4'd2:    led_green_progress = 10'b0000000011;
                4'd3:    led_green_progress = 10'b0000000111;
                4'd4:    led_green_progress = 10'b0000001111;
                4'd5:    led_green_progress = 10'b0000011111;
                4'd6:    led_green_progress = 10'b0000111111;
                4'd7:    led_green_progress = 10'b0001111111;
                4'd8:    led_green_progress = 10'b0011111111;
                4'd9:    led_green_progress = 10'b0111111111;
                default: led_green_progress = 10'b1111111111;
            endcase
        end else begin
            led_green_progress = 10'b0000000000;
        end
    end

    // לוגיקת נוריות דרגת קושי
    always @(*) begin
        case (diff_level)
            2'b00: begin
                diff_led_count = 4'd3;
                led_diff_mask  = 10'b0000000111;
            end
            2'b01: begin
                diff_led_count = 4'd6;
                led_diff_mask  = 10'b0000111111;
            end
            default: begin
                diff_led_count = 4'd10;
                led_diff_mask  = 10'b1111111111;
            end
        endcase
    end

endmodule