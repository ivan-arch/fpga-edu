module lock_debouncer #(
        parameter integer MAX_COUNT = 200_000,
        parameter integer BUS_WIDTH = 4,
        parameter [BUS_WIDTH-1:0] NOT_PRESSED = 0
    )(
        input  logic                 clk,
        input  logic [BUS_WIDTH-1:0] digit_raw,
        output logic [BUS_WIDTH-1:0] digit_clean = 0,
        output logic                 digit_is_valid = 0
    );

    localparam integer COUNTER_WIDTH = $clog2(MAX_COUNT + 1);
    logic [COUNTER_WIDTH-1:0] counter = 0;

    always_ff @(posedge clk) begin
        digit_is_valid <= 1'b0;
        if (digit_raw != digit_clean) begin
            counter <= counter + 1;
            if (counter == MAX_COUNT) begin
                digit_clean   <= digit_raw; 
                counter     <= 0;
                if (digit_raw != NOT_PRESSED) begin
                    digit_is_valid <= 1'b1; 
                end
            end
        end else begin
            counter <= 0;
        end
    end
endmodule