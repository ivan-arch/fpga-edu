import lock_pkg::*;

module lock_controller #(
        parameter integer DEBOUNCE_TICKS = 200_000,
        parameter logic [3:0] NOT_PRESSED = 4'd0,
        parameter logic [3:0] D1 = 4'd1,
        parameter logic [3:0] D2 = 4'd3,
        parameter logic [3:0] D3 = 4'd5
    )(
        input logic clk,
        input logic rst,
        input logic [3:0] digit_in,
        output logic unlocked_led
    );

logic [3:0] digit_clean, digit_clean_prev;

debouncer #(
    .BUS_WIDTH(4),
    .DEBOUNCE_TICKS(DEBOUNCE_TICKS)
    ) debouncer (
  .rst(rst),
  .clk(clk), 
  .digit_raw(digit_in),
  .digit_clean(digit_clean)
);

state_t state, next_state;

always_ff @(posedge clk or posedge rst) begin
    if(rst)
        state <= LOCKED;
    else
        state <= next_state;
end

always_ff @(posedge clk or posedge rst) begin
    if(rst)
        digit_clean_prev <= 0;
    else
        digit_clean_prev <= digit_clean;
end

always_comb begin
    next_state = state;
    case (state)
        LOCKED:
            if(digit_is_new && (digit_clean != NOT_PRESSED))
                next_state = (digit_clean == D1) ? WAIT_D2 : LOCKED;
            else
                next_state = state;
        WAIT_D2:
            if(digit_is_new && (digit_clean != NOT_PRESSED))
                next_state = (digit_clean == D2) ? WAIT_D3 : LOCKED;
            else
                next_state = state;
        WAIT_D3:
           if(digit_is_new && (digit_clean != NOT_PRESSED))
                 next_state = (digit_clean == D3) ? UNLOCKED : LOCKED;
            else
                next_state = state;
        UNLOCKED:
            next_state = UNLOCKED;
        default:
            next_state = LOCKED;
    endcase
end

assign unlocked_led = (state == UNLOCKED);
assign digit_is_new = digit_clean_prev != digit_clean;

endmodule
