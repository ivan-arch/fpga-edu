`timescale 1ns / 1ps

module super_math_tb;
    logic clk;
    logic rst;
    logic [7:0]  x;
    logic [7:0]  y;
    logic [7:0]  z;
    logic [15:0] result;
    
    super_math /* super_math_pipelined */ dut(
        .clk(clk),
        .rst(rst),
        .x(x),
        .y(y),
        .z(z), 
        .result(result)
    );

    task automatic check_result(
        input string description,
        logic [15:0] expected_result
    );
        if(result !== expected_result)
          $display("[%0t] FAIL: %-8s -> result=%0d, expected=%0d",
                $time, description, result, expected_result);
        else
            $display("[%0t] PASS: %-8s -> result=%0d",
                $time, description, result);
    endtask
    
    initial clk = 0;
    always #5 clk = ~clk;
    
    initial begin
        rst = 1; @(posedge clk); #1; 
        rst = 0;
        check_result("Zero after reset", 16'd0);
            
        x = 7'd1; y = 7'd1; z = 7'd1;
        repeat(10) @(posedge clk); #1;
        check_result("(1 + 1) * 1 + 1 * (1 + 1) = 4", 16'd4);
        
        x = 7'd1; y = 7'd2; z = 7'd3;
        repeat(10) @(posedge clk); #1;
        check_result("(1 + 2) * 3 + 1 * (2 + 3) = 14", 16'd14);
   
        x = 7'd3; y = 7'd2; z = 7'd1;
        repeat(10) @(posedge clk); #1;
        check_result("(3 + 2) * 1 + 3 * (2 + 1) = 14", 16'd14);
             
        x = 7'd2; y = 7'd2; z = 7'd2;
        repeat(10) @(posedge clk); #1;
        check_result("(2 + 2) * 2 + 2 * (2 + 2) = 16", 16'd16);
   
        $finish;
    end
    
endmodule
