`timescale 1ns / 1ps

import lock_pkg::*;

module lock_controller_tb;
    logic clk;
    logic rst;
    logic [3:0] digit_in;
    logic unlocked_led;
    
    localparam integer DEBOUNCE_TICKS = 2;
    localparam logic [3:0] NOT_PRESSED = 4'd0;
    localparam logic [3:0] D1 = 4'd1;
    localparam logic [3:0] D2 = 4'd3;
    localparam logic [3:0] D3 = 4'd5;
    localparam logic [3:0] WRONG = 4'd9;
   
    lock_controller #(
        .DEBOUNCE_TICKS(DEBOUNCE_TICKS),
        .NOT_PRESSED(NOT_PRESSED),
        .D1(D1),
        .D2(D2),
        .D3(D3)
    ) dut(
        .clk(clk),
        .rst(rst),
        .digit_in(digit_in),
        .unlocked_led(unlocked_led)
    );

    task automatic check_state(
        input string description,
        input state_t expected_state,
        input logic expected_unlocked_led
    );
        if(dut.state !== expected_state)
          $display("[%0t] FAIL: %-8s -> state=%s, expected=%s",
                $time, description, dut.state.name(), expected_state.name());
        else if (dut.unlocked_led !== expected_unlocked_led)
            $display("[%0t] FAIL: %-8s -> unlocked_led=%0b, expected=%0b",
                $time, description, dut.unlocked_led, expected_unlocked_led);
        else
            $display("[%0t] PASS: %-8s -> state=%s, unlocked_led=%0b",
                $time, description, dut.state.name(), dut.unlocked_led);
    endtask
    
    task automatic check_transition(
        input string name,
        input logic [3:0] set_digit,
        input state_t expected_state,
        input logic expected_unlocked_led
    );
        digit_in = set_digit; 
        repeat(DEBOUNCE_TICKS + 2) @(posedge clk); #1;
        check_state(name, expected_state, expected_unlocked_led);
    endtask
    
    initial clk = 0;
    always #5 clk = ~clk;
    
    initial begin
        rst = 1; @(posedge clk); #1; 
        rst = 0;
        check_state("Locked after reset", LOCKED, 1'b0);
            
        check_transition("Set correct 1st digit", D1, WAIT_D2, 1'b0);
        check_transition("Set correct 2nd digit", D2, WAIT_D3, 1'b0);
        check_transition("Set correct 3d digit", D3, UNLOCKED, 1'b1);
            
        repeat(DEBOUNCE_TICKS + 2) @(posedge clk); #1;
        check_state("Remains unlocked", UNLOCKED, 1'b1);
   
        digit_in = NOT_PRESSED;
        repeat(DEBOUNCE_TICKS + 2) @(posedge clk); #1;
        check_state("Ignores not pressed", UNLOCKED, 1'b1);
   
        rst = 1; @(posedge clk); #1;    
        rst = 0;
        check_state("Locked after reset", LOCKED, 1'b0);
      
        check_transition("Set correct 1st digit", D1, WAIT_D2, 1'b0);
        check_transition("Set wrong 2nd digit", WRONG, LOCKED, 1'b0);    
        
        $finish;
    end
    
endmodule
