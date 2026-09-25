`timescale 1ns / 1ps

module debouncer_tb;
    localparam integer DEBOUNCE_TICKS = 10;
    localparam integer BUS_WIDTH = 4;
   
    logic clk;
    logic rst;
    logic [BUS_WIDTH-1:0] digit_raw;
    logic [BUS_WIDTH-1:0] digit_clean;
    
    debouncer #(
        .DEBOUNCE_TICKS(DEBOUNCE_TICKS),
        .BUS_WIDTH(BUS_WIDTH)
    ) dut(
        .clk(clk),
        .rst(rst),
        .digit_raw(digit_raw),
        .digit_clean(digit_clean)
    );

    task automatic check_state(
        input string description,
        input logic [BUS_WIDTH-1:0] expected_digit_clean
    );
        if(digit_clean != expected_digit_clean)
          $display("[%0t] FAIL: %-8s -> digit_clean=%d, expected=%d",
                $time, description, digit_clean, expected_digit_clean);
        else
            $display("[%0t] PASS: %-8s -> digit_clean=%d",
                $time, description, digit_clean);
    endtask
    
    initial clk = 0;
    always #5 clk = ~clk;
    
    initial begin
        rst = 1; @(posedge clk); #1; 
        rst = 0;
        check_state("Zero after reset", 0);
        
        #1; digit_raw = 1; @(posedge clk);
        repeat(DEBOUNCE_TICKS) @(posedge clk); #1;
        check_state("Stable input 1", 1);

        #1; digit_raw = 2; @(posedge clk);
        repeat(DEBOUNCE_TICKS) @(posedge clk); #1;
        check_state("Stable input 2", 2);
        
        #1; digit_raw = 3; @(posedge clk);
        repeat(DEBOUNCE_TICKS - 1) @(posedge clk); #1;
        #1; digit_raw = 4; @(posedge clk);
        repeat(DEBOUNCE_TICKS - 1) @(posedge clk); #1;
        #1; digit_raw = 3; @(posedge clk);
        repeat(DEBOUNCE_TICKS - 1) @(posedge clk); #1;
        #1; digit_raw = 4; @(posedge clk);
        repeat(DEBOUNCE_TICKS - 1) @(posedge clk); #1;
        check_state("Unstable input. Output still 2", 2);

        rst = 1; @(posedge clk); #1; 
        rst = 0;
        check_state("Zero after reset", 0);
        
        $finish;
    end
    
endmodule