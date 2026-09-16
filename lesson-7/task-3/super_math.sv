module super_math (
    input  logic        clk,
    input  logic        rst,
    input  logic [7:0]  x,
    input  logic [7:0]  y,
    input  logic [7:0]  z,
    output logic [15:0] result
);
    logic [7:0] x_reg, y_reg, z_reg;
    logic [15:0] next_result;

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

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            result <= 16'd0;
        end else begin
            result <= next_result;
        end
    end
    
    assign next_result = ((x_reg + y_reg) * z_reg) + (x_reg * (y_reg + z_reg));
endmodule