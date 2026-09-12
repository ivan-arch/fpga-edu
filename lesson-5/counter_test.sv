`timescale 1ns / 1ps

module counter_test;
    logic clk;
    logic rst;
    logic load;
    logic [3:0] data_in;
    logic en;
    logic up_down;
    logic [3:0] count;
    
    counter dut(
        .clk(clk), 
        .rst(rst), 
        .load(load), 
        .data_in(data_in), 
        .en(en), 
        .up_down(up_down),
        .count(count)
    );
     
    task automatic check_count(
        input string feature_name,
        input [3:0] expected_count
    );
      if(count === expected_count)
        $display("[%0t] PASS: %-8s -> count=%0d (0x%h, %b) as expected",
            $time, feature_name, count, count, count);
      else
        $display("[%0t] FAIL: %-8s -> count had to be %0d, got %0d (may be X/Z: %b)",
            $time, feature_name, expected_count, count, count);
      
    endtask
     
    initial clk = 0;
    always #5 clk = ~clk;
    
    initial begin
        rst = 1; @(posedge clk); 
        
        // load data
        rst = 0; load = 1; data_in = 4'd10; @(posedge clk); #1;        
        check_count("load data", 4'd10); 
            
        // count up
        load = 0; en=1; up_down=1; 
        @(posedge clk); @(posedge clk); @(posedge clk); #1;
        check_count("count up", 4'd13); 
        @(posedge clk); @(posedge clk); @(posedge clk); #1;
        check_count("count up", 4'd0); 
           
        // hold previous value
        load=0; en=0; data_in=4'd5; up_down=1;
        @(posedge clk); @(posedge clk); #1;
        check_count("hold previous value", 4'd0);
        
        // load over counting priority        
        load=1; en=1; data_in=4'd6; up_down=1;
        @(posedge clk); #1;
        check_count("load over counting priority", 4'd6);
            
        // load over disabling priority    
        load=1; en=0; data_in=4'd7; up_down=1;
        @(posedge clk); #1;
        check_count("load over disabling priority", 4'd7);
         
        $finish;
    end

endmodule