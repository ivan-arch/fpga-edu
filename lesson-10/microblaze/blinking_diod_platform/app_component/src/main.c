#include "xparameters.h"
#include "xgpio.h"
#include "xtmrctr.h"           // Драйвер AXI Timer
#include "xinterrupt_wrap.h"   // XSetupInterruptSystem

/*
 * SIM = 1 - короткі періоди для симуляції у Vivado
 * SIM = 0 - реальні періоди для заліза
 */
#define SIM 1

// AXI GPIO з xparameters.h (канал 1 - діоди, канал 2 - кнопка)
#define AXI_GPIO_DEVICE_ID  XPAR_XGPIO_0_BASEADDR
#define LED_CH              1
#define BTN_CH              2

// AXI Timer з xparameters.h
#define AXI_TIMER_DEVICE_ID XPAR_XTMRCTR_0_BASEADDR

// Маски для світлодіодів на шині [1:0] (0 - Зелений, 1 - Червоний)
#define LED_GREEN_MASK      0x01 // 0b01
#define LED_RED_MASK        0x02 // 0b10
#define LED_BOTH_MASK       0x03 // 0b11

// Кнопка на каналі 2 AXI GPIO, біт 0
#define BTN_MASK            0x01
#define BTN_ACTIVE_HIGH     1    // 1 - натиснута = 1 (симуляція); 0 - натиснута = 0 (як на EBAZ4205)

// Налаштування таймера
#define TIMER_CLK_HZ        100000000U   // Частота порту clk (має збігатися з тестбенчем)
#define TMR_PATTERN         0            // Лічильник 0 - темп блимання
#define TMR_BUTTON          1            // Лічильник 1 - опитування кнопки
#define US_TO_COUNTS(us)    (TIMER_CLK_HZ / 1000000U * (us))

#if SIM
#define PATTERN_TICK_US     100U         // Крок патерну у симуляції
#define BUTTON_TICK_US      20U          // Опитування кнопки у симуляції
#else
#define PATTERN_TICK_US     250000U      // 250 мс
#define BUTTON_TICK_US      20000U       // 20 мс (дебаунс)
#endif

// Патерн з 8 кроків: A, пауза, A, пауза, A, пауза, B, пауза
#define PATTERN_STEPS       8

XGpio AxiGpioInstance;   // Екземпляр драйвера AXI GPIO
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

    XGpio_DiscreteWrite(&AxiGpioInstance, LED_CH, out);
    step = (step + 1) % PATTERN_STEPS;
}

// Опитування кнопки (викликається лічильником 1)
void ButtonPoll(void) {
    u32 level = XGpio_DiscreteRead(&AxiGpioInstance, BTN_CH) & BTN_MASK;

#if BTN_ACTIVE_HIGH
    u8 pressed = (level != 0);
#else
    u8 pressed = (level == 0);
#endif

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

    // Ініціалізація AXI GPIO
    status = XGpio_Initialize(&AxiGpioInstance, AXI_GPIO_DEVICE_ID);
    if (status != XST_SUCCESS) {
        return XST_FAILURE;
    }
    XGpio_SetDataDirection(&AxiGpioInstance, LED_CH, ~LED_BOTH_MASK);  // Діоди - виходи
    XGpio_SetDataDirection(&AxiGpioInstance, BTN_CH, 0xFFFFFFFF);      // Кнопка - вхід

    // Початковий стан: вимикаємо обидва світлодіоди
    XGpio_DiscreteWrite(&AxiGpioInstance, LED_CH, 0x00);

    // Ініціалізація AXI Timer
    status = XTmrCtr_Initialize(&TimerInstance, AXI_TIMER_DEVICE_ID);
    if (status != XST_SUCCESS) {
        return XST_FAILURE;
    }
    XTmrCtr_SetHandler(&TimerInstance, TimerHandler, &TimerInstance);

    // Лічильник 0: переривання кожні PATTERN_TICK_US, автоперезавантаження, рахунок вниз
    XTmrCtr_SetOptions(&TimerInstance, TMR_PATTERN,
        XTC_INT_MODE_OPTION | XTC_AUTO_RELOAD_OPTION | XTC_DOWN_COUNT_OPTION);
    XTmrCtr_SetResetValue(&TimerInstance, TMR_PATTERN, US_TO_COUNTS(PATTERN_TICK_US));

    // Лічильник 1: переривання кожні BUTTON_TICK_US
    XTmrCtr_SetOptions(&TimerInstance, TMR_BUTTON,
        XTC_INT_MODE_OPTION | XTC_AUTO_RELOAD_OPTION | XTC_DOWN_COUNT_OPTION);
    XTmrCtr_SetResetValue(&TimerInstance, TMR_BUTTON, US_TO_COUNTS(BUTTON_TICK_US));

    // Підключення переривання таймера (Concat -> AXI INTC -> MicroBlaze)
    status = XSetupInterruptSystem(&TimerInstance, XTmrCtr_InterruptHandler,
                                   TimerInstance.Config.IntrId,
                                   TimerInstance.Config.IntrParent,
                                   XINTERRUPT_DEFAULT_PRIORITY);
    if (status != XST_SUCCESS) {
        return XST_FAILURE;
    }

    // Запуск обох лічильників
    XTmrCtr_Start(&TimerInstance, TMR_PATTERN);
    XTmrCtr_Start(&TimerInstance, TMR_BUTTON);

    // Головний цикл: уся робота виконується в перериваннях таймера
    while (1) {
    }
}