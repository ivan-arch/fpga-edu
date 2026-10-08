`timescale 1ns / 1ps

import frame_shutter_pkg::*;

module frame_shutter_core_tb;
    logic        clk;
    logic        rst;
    logic        arm;
    logic        start_of_frame;
    logic        pixel_transfer;
    logic        is_open;
    logic        is_last;
    
    localparam int PIXELS_COUNT = 13;
    
    frame_shutter_core  #(
        .PIXELS_COUNT(PIXELS_COUNT)
    ) dut (
        .clk(clk),
        .rst(rst),
        .arm(arm),
        .start_of_frame(start_of_frame),
        .pixel_transfer(pixel_transfer),
        .is_open(is_open),
        .is_last(is_last)
    );
    
    task automatic check_state(input string description, input state_t expected_state);
        if(dut.current_state !== expected_state)
          $display("[%0t] FAIL: %s -> state=%s, expected=%s",
                $time, description, dut.current_state.name(), expected_state.name());
        else
          $display("[%0t] PASS: %s -> state=%s",
                $time, description, dut.current_state.name());
    endtask
    
    initial clk = 0;
    always #5 clk = ~clk;
    
    initial begin
        start_of_frame = 0;
        arm = 0;
        pixel_transfer = 0;
    
        rst = 1; @(posedge clk); #1; rst = 0;
        check_state("Reset", IDLE);
        
        arm = 1; @(posedge clk); #1; arm = 0;
        check_state("Arm", WAIT_START);
        
        start_of_frame = 1; pixel_transfer = 1; @(posedge clk); #1; start_of_frame = 0;
        check_state("Frame start (first pixel)", PASS);
        
        repeat(PIXELS_COUNT - 2) @(posedge clk); #1;
        check_state("One pixel left", PASS);
        
        @(posedge clk); #1;
        check_state("All pixels", IDLE);
         
        start_of_frame = 1;
        @(posedge clk); #1;
        check_state("Ignore frame start without arm", IDLE);
        
        rst = 1; @(posedge clk); #1; rst = 0;
        check_state("Reset", IDLE);
        
        $finish;
    end
   
endmodule