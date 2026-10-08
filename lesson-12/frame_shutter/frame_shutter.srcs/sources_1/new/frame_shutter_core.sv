import frame_shutter_pkg::*;

module frame_shutter_core #(
    parameter int PIXELS_COUNT = 64000,
    parameter int BUS_WIDTH = $clog2(PIXELS_COUNT),
    parameter int MAX_COUNT = PIXELS_COUNT - 1
) (
    input  logic        clk,
    input  logic        rst,
    input  logic        arm,
    input  logic        start_of_frame,
    input  logic        pixel_transfer,
    output logic        is_open,
    output logic        is_last
);
    state_t current_state, next_state;

    logic [BUS_WIDTH-1:0]   counter;
    logic                   counter_en;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) current_state <= IDLE;
        else     current_state <= next_state;
    end

    always_comb begin
        next_state = current_state;
        case (current_state)
            IDLE:
                if (arm)
                    next_state = WAIT_START;
            WAIT_START:
                if (counter_en)
                    next_state = PASS;
            PASS:
                if (counter_en && is_last)
                    next_state = IDLE;
            default:
                next_state = IDLE;
        endcase
    end

    assign is_open = (current_state == PASS) ||
        (current_state == WAIT_START && start_of_frame);

    assign is_last = (current_state == PASS) && (counter == MAX_COUNT);

    assign counter_en = is_open && pixel_transfer;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            counter <= 0;
        else if (counter_en) begin
            if (is_last) counter <= 0;
            else         counter <= counter + 1'b1;
        end
    end

endmodule