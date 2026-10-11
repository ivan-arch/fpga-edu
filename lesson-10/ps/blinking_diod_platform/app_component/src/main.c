#include "sleep.h"
#include "xparameters.h"
#include "xgpio.h"
#include "xil_printf.h"
#include "xil_io.h"  // Бібліотека для прямого зчитування/запису регістрів у пам'ять
#include "xtmrctr.h"           // Драйвер AXI Timer
#include "xinterrupt_wrap.h"   // XSetupInterruptSystem

// ID для AXI GPIO з xparameters.h (керування двома діодами в ПЛІС)
#define AXI_GPIO_DEVICE_ID XPAR_XGPIO_0_BASEADDR

// ID для AXI Timer з xparameters.h
#define AXI_TIMER_DEVICE_ID XPAR_XTMRCTR_0_BASEADDR

// Маски для світлодіодів на шині [1:0] (0 - Зелений, 1 - Червоний)
#define LED_GREEN_MASK      0x01 // 0b01
#define LED_RED_MASK        0x02 // 0b10
#define LED_BOTH_MASK       0x03 // 0b11

/*
 * ХАК ДЛЯ КНОПКИ S2 БЕЗ ДРАЙВЕРА XGpioPs:
 * Базова адреса контролера GPIO у процесорі Zynq-7000: 0xE000A000
 * Стан кнопки читається з регістру DATA Банку 0 (MIO 0-31), біт 20.
 * Напрямок (вхід) задається в регістрі DIRM Банку 1 (MIO 32-53), біт 20.
 */
#define ZYNQ_GPIO_BASE         0xE000A000
#define ZYNQ_GPIO_DATA_0_OFS   0x040   // DATA, Банк 0
#define ZYNQ_GPIO_DIRM_1_OFS   0x244   // DIRM, Банк 1

#define ZYNQ_GPIO_DATA_0_REG   (ZYNQ_GPIO_BASE + ZYNQ_GPIO_DATA_0_OFS)
#define ZYNQ_GPIO_DIRM_1_REG   (ZYNQ_GPIO_BASE + ZYNQ_GPIO_DIRM_1_OFS)
#define BUTTON_BIT_SHIFT       20   // 20-й біт

// Налаштування таймера
#define TIMER_CLK_HZ        100000000U   // Частота FCLK_CLK0
#define TMR_PATTERN         0            // Лічильник 0 - темп блимання
#define TMR_BUTTON          1            // Лічильник 1 - опитування кнопки
#define PATTERN_TICK_MS     250U         // Тривалість одного кроку патерну
#define BUTTON_TICK_MS      20U          // Період опитування кнопки (дебаунс)
#define MS_TO_COUNTS(ms)    (TIMER_CLK_HZ / 1000U * (ms))

// Патерн з 8 кроків: A, пауза, A, пауза, A, пауза, B, пауза
#define PATTERN_STEPS       8

XGpio AxiGpioInstance;   // Екземпляр драйвера для діодів в ПЛІС
XTmrCtr TimerInstance;   // Екземпляр драйвера AXI Timer

volatile u8 step = 0;         // Поточний крок патерну
volatile u8 swapped = 0;      // 0: A - Зелений, B - Червоний; 1: навпаки
volatile u8 btn_prev = 0;     // Попередній стан кнопки

// Крок патерну (викликається лічильником 0)
void PatternStep(void) {
    u8 led_a = swapped ? LED_RED_MASK   : LED_GREEN_MASK;
    u8 led_b = swapped ? LED_GREEN_MASK : LED_RED_MASK;
    u8 out;

    if (step % 2 == 1)  out = 0x00;     // Непарні кроки - пауза
    else if (step < 6)  out = led_a;    // Кроки 0, 2, 4 - діод A
    else                out = led_b;    // Крок 6 - діод B

    XGpio_DiscreteWrite(&AxiGpioInstance, 1, out);
    step = (step + 1) % PATTERN_STEPS;
}

// Опитування кнопки (викликається лічильником 1)
void ButtonPoll(void) {
    u32 reg_value = Xil_In32(ZYNQ_GPIO_DATA_0_REG);

    // На EBAZ4205 при натисканні кнопки лінія замикається на землю, тобто стає рівною 0
    u8 pressed = ((reg_value & (1 << BUTTON_BIT_SHIFT)) == 0);

    if (pressed && !btn_prev) {   // Момент натискання - міняємо діоди місцями
        swapped ^= 1;
    }
    btn_prev = pressed;
}

// Обробник переривання таймера (спільний для обох лічильників)
void TimerHandler(void *CallBackRef, u8 TmrCtrNumber) {
    if (TmrCtrNumber == TMR_PATTERN) {
        PatternStep();
    } else if (TmrCtrNumber == TMR_BUTTON) {
        ButtonPoll();
    }
}

int main() {
    int status;

    xil_printf("--- Початок програми EBAZ4205 (Прямий доступ до регістрів) ---\r\n");

    // Ініціалізація світлодіодів через офіційний драйвер AXI GPIO
    status = XGpio_Initialize(&AxiGpioInstance, AXI_GPIO_DEVICE_ID);
    if (status != XST_SUCCESS) {
        xil_printf("Помилка ініціалізації AXI GPIO!\r\n");
        return XST_FAILURE;
    }
    // Налаштовуємо канал 1 AXI GPIO на вихід
    XGpio_SetDataDirection(&AxiGpioInstance, 1, ~LED_BOTH_MASK);

    // Початковий стан: вимикаємо обидва світлодіоди
    XGpio_DiscreteWrite(&AxiGpioInstance, 1, 0x00);

    // Записуємо 0 у біт BUTTON_BIT_SHIFT регістру DIRM, щоб зробити пін входом (Input)
    u32 dir_reg = Xil_In32(ZYNQ_GPIO_DIRM_1_REG);
    dir_reg &= ~(1 << BUTTON_BIT_SHIFT);
    Xil_Out32(ZYNQ_GPIO_DIRM_1_REG, dir_reg);

    // Ініціалізація AXI Timer
    status = XTmrCtr_Initialize(&TimerInstance, AXI_TIMER_DEVICE_ID);
    if (status != XST_SUCCESS) {
        xil_printf("Помилка ініціалізації AXI Timer!\r\n");
        return XST_FAILURE;
    }
    XTmrCtr_SetHandler(&TimerInstance, TimerHandler, &TimerInstance);

    // Лічильник 0: переривання кожні PATTERN_TICK_MS, автоперезавантаження, рахунок вниз
    XTmrCtr_SetOptions(&TimerInstance, TMR_PATTERN,
        XTC_INT_MODE_OPTION | XTC_AUTO_RELOAD_OPTION | XTC_DOWN_COUNT_OPTION);
    XTmrCtr_SetResetValue(&TimerInstance, TMR_PATTERN, MS_TO_COUNTS(PATTERN_TICK_MS));

    // Лічильник 1: переривання кожні BUTTON_TICK_MS
    XTmrCtr_SetOptions(&TimerInstance, TMR_BUTTON,
        XTC_INT_MODE_OPTION | XTC_AUTO_RELOAD_OPTION | XTC_DOWN_COUNT_OPTION);
    XTmrCtr_SetResetValue(&TimerInstance, TMR_BUTTON, MS_TO_COUNTS(BUTTON_TICK_MS));

    // Підключення переривання таймера (IRQ_F2P -> GIC)
    status = XSetupInterruptSystem(&TimerInstance, XTmrCtr_InterruptHandler,
                                   TimerInstance.Config.IntrId,
                                   TimerInstance.Config.IntrParent,
                                   XINTERRUPT_DEFAULT_PRIORITY);
    if (status != XST_SUCCESS) {
        xil_printf("Помилка налаштування переривань!\r\n");
        return XST_FAILURE;
    }

    // Запуск обох лічильників
    XTmrCtr_Start(&TimerInstance, TMR_PATTERN);
    XTmrCtr_Start(&TimerInstance, TMR_BUTTON);

    // Головний цикл: уся робота виконується в перериваннях таймера.
    // WFI зупиняє ядро до наступного переривання, і воно не крутиться даремно.
    while (1) {
        __asm__ volatile ("wfi");
    }
}