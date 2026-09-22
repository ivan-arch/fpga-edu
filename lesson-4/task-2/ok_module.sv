module ok_module(
    input logic in,
    output logic [1:0] out = 0
    );

always_comb begin
    if(in)
        out = 2'b01;
    else
        out = 2'b10;
end

endmodule


