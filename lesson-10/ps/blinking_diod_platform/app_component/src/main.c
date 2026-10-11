#include "sleep.h"
#include "xparameters.h"
#include "xgpio.h"
#include "xil_printf.h"
#include "xil_io.h"  // Бібліотека для прямого зчитування/запису регістрів у пам'ять

// ID для AXI GPIO з xparameters.h (керування двома діодами в ПЛІС)
#define AXI_GPIO_DEVICE_ID XPAR_XGPIO_0_BASEADDR

// Маски для світлодіодів на шині [1:0] (0 - Зелений, 1 - Червоний)
#define LED_GREEN_MASK      0x01 // 0b01
#define LED_RED_MASK        0x02 // 0b10
#define LED_BOTH_MASK       0x03 // 0b11

/* 
 * ХАК ДЛЯ КНОПКИ S2 (MIO 51) БЕЗ ДРАЙВЕРА XGpioPs:
 * Базова адреса контролера GPIO у процесорі Zynq-7000: 0xE000A000
 * Зміщення (Offset) для регістру DATA інпутів Банку 1 (куди входять лінії MIO 32-53): 0x00000044
 * Формула адреси регістру читання даних: 0xE000A000 + 0x00000044 = 0xE000A044
 * Номер біту для MIO 51 всередині Банку 1: 51 - 32 = 19
 */
#define ZYNQ_GPIO_DATA_1_REG   0xE000A040  // Регістр DATA для Банку 0
#define BUTTON_BIT_SHIFT       20   // 20-й біт

XGpio AxiGpioInstance; // Екземпляр драйвера для діодів в ПЛІС

int main() {
    int status;
    u32 reg_value;

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

    // Адреса регістру напрямку для Банку 1 (MIO 32-53) — 0xE000A244
    // Записуємо 0 в 19-й біт (MIO 51), щоб примусово зробити цей пін входом (Input)
    u32 dir_reg = Xil_In32(0xE000A244);
    dir_reg &= ~(1 << BUTTON_BIT_SHIFT);
    Xil_Out32(0xE000A244, dir_reg);


    // Головний цикл
    while(1) {
        // Хак: читаємо 32-бітний регістр стану MIO-ніжок процесора напряму з пам'яті Zynq
        reg_value = Xil_In32(ZYNQ_GPIO_DATA_1_REG);

        // Перевіряємо стан 19-го біту (який електрично з'єднаний з кнопкою S2 за схемою плати)
        // На EBAZ4205 при натисканні кнопки лінія замикається на землю, тобто стає рівною 0
        if ((reg_value & (1 << BUTTON_BIT_SHIFT)) == 0) {
            // Кнопка натиснута: вмикаємо Зелений, вимикаємо Червоний
            XGpio_DiscreteWrite(&AxiGpioInstance, 1, LED_GREEN_MASK);
        } else {
            // Кнопка відпущена: вмикаємо Червоний, вимикаємо Зелений
            XGpio_DiscreteWrite(&AxiGpioInstance, 1, LED_RED_MASK);
        }

        // Затримка для стабільності роботи (дебаунс кнопки)
        for (volatile int i = 0; i < 50000; i++);
       
        // XGpio_DiscreteWrite(&AxiGpioInstance, 1, LED_GREEN_MASK);
        // usleep(500000); 
        // XGpio_DiscreteWrite(&AxiGpioInstance, 1, LED_RED_MASK);
        // usleep(500000);
    }

    return 0;
}
