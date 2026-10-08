#include <string.h>
#include "xparameters.h"
#include "xaxidma.h"
#include "xgpio.h"
#include "xil_cache.h"
#include "xil_printf.h"
#include "sleep.h"

#define DMA_BASEADDR        XPAR_XAXIDMA_0_BASEADDR
#define GPIO_BASEADDR       XPAR_XGPIO_0_BASEADDR
#define FRAME_BUFFER_ADDR   (XPAR_AXI_FULL_BRAM_0_BASEADDR + 0x100)

#define PIXELS_COUNT        64000
#define GPIO_ARM_CHANNEL    1
#define GPIO_BTN_CHANNEL    2

#define DEBOUNCE_US         0 // для симуляції
#define DMA_TIMEOUT         10000000
#define CHECK_TEST_PATTERN  1           /* 1: очікуємо пікселі 0,1,2,... (як у тестбенчі) */

static XAxiDma dma;
static XGpio   gpio;

static int init_dma(void)
{
    XAxiDma_Config *cfg = XAxiDma_LookupConfig(DMA_BASEADDR);
    if (cfg == NULL)
        return XST_FAILURE;

    if (XAxiDma_CfgInitialize(&dma, cfg) != XST_SUCCESS)
        return XST_FAILURE;

    if (XAxiDma_HasSg(&dma))
        return XST_FAILURE;             /* працюємо в Direct Register режимі */

    XAxiDma_IntrDisable(&dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
    return XST_SUCCESS;
}

static int init_gpio(void)
{
    if (XGpio_Initialize(&gpio, GPIO_BASEADDR) != XST_SUCCESS)
        return XST_FAILURE;

    XGpio_SetDataDirection(&gpio, GPIO_ARM_CHANNEL, 0x0);   /* вихід */
    XGpio_SetDataDirection(&gpio, GPIO_BTN_CHANNEL, 0x1);   /* вхід  */
    XGpio_DiscreteWrite(&gpio, GPIO_ARM_CHANNEL, 0);
    return XST_SUCCESS;
}

static int capture_frame(void)
{
    u8 *frame = (u8 *)FRAME_BUFFER_ADDR;
    int timeout = DMA_TIMEOUT;

#if CHECK_TEST_PATTERN
    memset(frame, 0xA5, PIXELS_COUNT);
    Xil_DCacheFlushRange((UINTPTR)frame, PIXELS_COUNT);
#endif

    /* 1. спочатку запускаємо S2MM */
    if (XAxiDma_SimpleTransfer(&dma, (UINTPTR)frame, PIXELS_COUNT,
                               XAXIDMA_DEVICE_TO_DMA) != XST_SUCCESS)
        return XST_FAILURE;

    /* 2. потім arm: 1, а одразу 0 (arm у ядрі працює за рівнем) */
    XGpio_DiscreteWrite(&gpio, GPIO_ARM_CHANNEL, 1);
    XGpio_DiscreteWrite(&gpio, GPIO_ARM_CHANNEL, 0);

    /* 3. чекаємо завершення */
    while (XAxiDma_Busy(&dma, XAXIDMA_DEVICE_TO_DMA)) {
        if (--timeout == 0)
            return XST_FAILURE;
    }

    Xil_DCacheInvalidateRange((UINTPTR)frame, PIXELS_COUNT);
    return XST_SUCCESS;
}

#if CHECK_TEST_PATTERN
static u32 check_frame(void)
{
    const u8 *frame = (const u8 *)FRAME_BUFFER_ADDR;
    u32 errors = 0;

    for (u32 i = 0; i < PIXELS_COUNT; i++) {
        if (frame[i] != (u8)i)
            errors++;
    }
    return errors;
}
#endif

int main(void)
{
    if (init_dma() != XST_SUCCESS || init_gpio() != XST_SUCCESS) {
        xil_printf("Init failed\r\n");
        return XST_FAILURE;
    }

    xil_printf("Ready, press button\r\n");

    while (1) {
        while (!XGpio_DiscreteRead(&gpio, GPIO_BTN_CHANNEL));   /* чекаємо натискання */
        usleep(DEBOUNCE_US);

        if (capture_frame() != XST_SUCCESS) {
            xil_printf("Capture failed (DMA timeout or error)\r\n");
            return XST_FAILURE;
        }
        xil_printf("Frame captured\r\n");

#if CHECK_TEST_PATTERN
        xil_printf("Mismatched pixels: %lu\r\n", (unsigned long)check_frame());
#endif

        while (XGpio_DiscreteRead(&gpio, GPIO_BTN_CHANNEL));    /* чекаємо відпускання */
        usleep(DEBOUNCE_US);
    }
}
