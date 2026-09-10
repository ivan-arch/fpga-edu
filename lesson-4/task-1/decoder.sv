module decoder #(
    parameter OUT_WIDTH = 4,
    localparam ADDR_WIDTH=$clog2(OUT_WIDTH)
) ( 
    input logic [ADDR_WIDTH-1:0] addr,
    output logic [OUT_WIDTH-1:0] out
);

always_comb begin
    out = {OUT_WIDTH{1'b0}};
    out[addr] = 1'b1;
end

endmodule
