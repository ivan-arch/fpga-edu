module super_math_pipelined (
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  x,
    input  logic [7:0]  y,
    input  logic [7:0]  z,
    output logic [15:0] result
);
    logic [7:0] x_reg, y_reg, z_reg;
    logic [15:0]  part1_reg, part2_reg; 
    logic [15:0] next_part1, next_part2, next_result;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            x_reg <= 8'd0;
            y_reg <= 8'd0;
            z_reg <= 8'd0;
        end else begin
            x_reg <= x;
            y_reg <= y;
            z_reg <= z;
        end
    end

    // step 1
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            part1_reg <= 16'd0;
            part2_reg <= 16'd0;
        end else begin
            part1_reg <= next_part1;
            part2_reg <= next_part2;
        end
    end
    
    // step 2
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 16'd0;
        end else begin
            result <= next_result;
        end
    end
    
    // step 1
    assign next_part1 = (x_reg + y_reg) * z_reg;
    assign next_part2 = x_reg * (y_reg + z_reg);
    
    // step 2
    assign next_result = part1_reg + part2_reg;
endmodule