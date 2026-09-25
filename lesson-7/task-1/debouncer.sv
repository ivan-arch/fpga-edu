module debouncer #(
        parameter integer DEBOUNCE_TICKS = 200_000,
        parameter integer BUS_WIDTH = 4
    )(
        input  logic                 clk,
        input  logic                 rst,
        input  logic [BUS_WIDTH-1:0] digit_raw,
        output logic [BUS_WIDTH-1:0] digit_clean
    );

    localparam integer COUNTER_WIDTH = $clog2(DEBOUNCE_TICKS + 1);
    logic [COUNTER_WIDTH-1:0] count;
    logic [BUS_WIDTH-1:0] prev_digit_raw;
   
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            digit_clean <= 0;
            count <= 0;
            prev_digit_raw <= 0;
        end
        else begin
            prev_digit_raw <= digit_raw; 
            if ((digit_raw == digit_clean) || (digit_raw != prev_digit_raw))
                count <= 0;
            else begin
                count <= count + 1;
                if(count == (DEBOUNCE_TICKS - 1))
                    digit_clean <= digit_raw;
            end
        end
    end

endmodule
