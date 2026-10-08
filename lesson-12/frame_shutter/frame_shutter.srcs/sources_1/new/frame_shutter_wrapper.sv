module frame_shutter_wrapper #(
    parameter int PIXELS_COUNT = 64000
) (
    input  logic        clk,
    input  logic        rst,
    input  logic        arm,

    // FIFO (First Word Fall Through), слово {start_of_frame, pixel}
    input  logic [7:0]  fifo_data,
    input  logic        fifo_start_of_frame,
    input  logic        fifo_valid,             // = !empty
    output logic        fifo_rd_en,

    // AXI Stream до DMA (S2MM)
    output logic [7:0]  m_axis_tdata,
    output logic        m_axis_tvalid,
    output logic        m_axis_tlast,
    input  logic        m_axis_tready
);
    logic is_open;
    logic is_last;
    logic start_of_frame;
    logic pixel_transfer;

    assign start_of_frame = fifo_valid && fifo_start_of_frame;
    assign pixel_transfer = m_axis_tvalid && m_axis_tready;

    assign m_axis_tdata  = fifo_data;
    assign m_axis_tvalid = is_open && fifo_valid;
    assign m_axis_tlast  = m_axis_tvalid && is_last;

    // шторка закрита: FIFO вичитується і дані викидаються
    // шторка відкрита: читання лише коли DMA готовий
    assign fifo_rd_en = fifo_valid && (!is_open || m_axis_tready);

    frame_shutter_core #(
        .PIXELS_COUNT(PIXELS_COUNT)
    ) core (
        .clk            (clk),
        .rst            (rst),
        .arm            (arm),
        .start_of_frame (start_of_frame),
        .pixel_transfer (pixel_transfer),
        .is_open        (is_open),
        .is_last        (is_last)
    );

endmodule