module led_counter #(parameter LEDS_COUNT = 4)(
    input logic clk,
    input logic rst,
    output logic [LEDS_COUNT-1:0] leds
);

localparam ZERO_VAL = {LEDS_COUNT{1'b0}};
localparam MAX_VAL = (1 << LEDS_COUNT) - 1;

always_ff @(posedge clk or posedge rst) begin
    if (rst)
        leds <= ZERO_VAL;
    else if (leds == MAX_VAL)
        leds <= ZERO_VAL;
    else
        leds <= leds + 1;
end

endmodule
