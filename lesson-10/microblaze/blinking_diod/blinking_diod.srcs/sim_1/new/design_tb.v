`timescale 1ns / 1ps

// Тестбенч для MicroBlaze-проєкту: патерн "3 + 1" на двох діодах,
// кнопка міняє діоди місцями.
//
// Часові параметри відповідають програмі з SIM = 1:
//   крок патерну 100 мкс (повний цикл 8 кроків = 800 мкс)
//   опитування кнопки 20 мкс

module design_tb;

    // ---------- Параметри ----------
    localparam real CLK_PERIOD_NS  = 10.0;   // 100 МГц на вході Clocking Wizard
    localparam      RESET_ACTIVE   = 1'b0;   // полярність reset_rtl_0 (1 - активний високий)

    // ---------- Сигнали ----------
    reg        clk_p = 1'b0;
    wire       clk_n = ~clk_p;
    reg        rst   = RESET_ACTIVE;
    reg  [0:0] btn   = 1'b0;
    wire [1:0] led;

    // ---------- Тестований дизайн ----------
    design_1_wrapper dut (
        .diff_clock_rtl_0_clk_p (clk_p),
        .diff_clock_rtl_0_clk_n (clk_n),
        .reset_rtl_0            (rst),
        .btn_tri_i              (btn),
        .led_tri_o              (led)
    );

    // ---------- Такт ----------
    always #(CLK_PERIOD_NS / 2.0) clk_p = ~clk_p;

    // ---------- Журнал змін на діодах ----------
    always @(led) begin
        case (led)
            2'b00:   $display("%t ns: LED off", $time);
            2'b01:   $display("%t ns: LED GREEN", $time);
            2'b10:   $display("%t ns: LED RED", $time);
            default: $display("%t ns: LED = %b", $time, led);
        endcase
    end

    // ---------- Натискання кнопки ----------
    // Тримаємо довше за кілька періодів опитування (20 мкс),
    // щоб програма гарантовано побачила натискання.
    task press_button(input integer hold_us);
        begin
            $display("%t ns: BUTTON pressed", $time);
            btn = 1'b1;
            #(hold_us * 1000);
            btn = 1'b0;
            $display("%t ns: BUTTON released", $time);
        end
    endtask

    // ---------- Сценарій ----------
    initial begin
        // Скидання
        rst = RESET_ACTIVE;
        #1000;                      // 1 мкс
        rst = ~RESET_ACTIVE;
        $display("%t ns: reset released", $time);

        // Чекаємо захоплення частоти Clocking Wizard, старт програми
        // і два повні цикли патерну: зелений x3, червоний x1
        #1_700_000;                 // 1,7 мс

        // Натискання: діоди міняються місцями
        press_button(100);

        // Два цикли з переставленими діодами: червоний x3, зелений x1
        #1_700_000;

        // Друге натискання: повертаємося до початкового стану
        press_button(100);

        #1_000_000;

        $display("%t ns: simulation finished", $time);
        $finish;
    end

endmodule