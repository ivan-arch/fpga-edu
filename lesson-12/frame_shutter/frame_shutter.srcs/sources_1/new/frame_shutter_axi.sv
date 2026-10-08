module frame_shutter_axi #(
    parameter int PIXELS_COUNT = 64000,
    parameter int PIXEL_SIZE = 8
) (
    // Системні сигнали
    input  logic       aclk,
    input  logic       aresetn,         // Активний низький рівень скидання (стандарт AXI)
    
    // Slave AXI4-Stream інтерфейс (Вхідний відеопотік)
    input  logic [PIXEL_SIZE-1:0] s_axis_tdata,
    input  logic       s_axis_tvalid,
    output logic       s_axis_tready,
    input  logic       s_axis_tuser,    // Початок кадру (SOF)
    input  logic       s_axis_tlast,    // Кінець рядка (EOL)
    
    // Master AXI4-Stream інтерфейс (Вихід на AXI DMA)
    output logic [PIXEL_SIZE-1:0] m_axis_tdata,
    output logic       m_axis_tvalid,
    input  logic       m_axis_tready,   // Готовність DMA до прийому
    output logic       m_axis_tuser,
    output logic       m_axis_tlast
);
    logic pass_en;

    frame_shutter_core #(
        .PIXELS_COUNT(PIXELS_COUNT)
    ) core (
        .clk            (aclk),
        .rst            (~aresetn),        // Інвертуємо активний нуль aresetn у прямий rst для ядра
        .start_of_frame (s_axis_tuser),    // Сигнал TUSER є початком кадру
        .is_open        (pass_en)          // Вихід ядра керує затвором
    );

    // Дані з девайсу просто проходять через наш модул
    assign m_axis_tdata  = s_axis_tdata;
    
    // Комутація керуючих сигналів: пропускаємо їх на DMA лише тоді, 
    // коли автомат ядра перебуває в стані PASS (pass_en == 1)
    assign m_axis_tvalid = pass_en ? s_axis_tvalid : 1'b0;
    assign m_axis_tuser  = pass_en ? s_axis_tuser  : 1'b0;
    assign m_axis_tlast  = pass_en ? s_axis_tlast  : 1'b0;
    
    // Логіка готовності прийому:
    // Коли затвор закритий, ми завжди готові "ковтати та спалювати" вхідні кадри, 
    // щоб джерело відео (наприклад, камера) не зависало.
    // Коли йде запис кадру, готовність визначається суто контролером DMA.
    assign s_axis_tready = pass_en ? m_axis_tready : 1'b1;

endmodule