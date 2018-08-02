
#include "stm32f1xx_hal.h"
#include "stm32_hal_legacy.h"
#include "stm32f103xb.h"

void InitializeLED(void)
{
  __GPIOC_CLK_ENABLE();
  GPIO_InitTypeDef GPIO_InitStructure;
  GPIO_InitStructure.Pin = GPIO_PIN_13;
  GPIO_InitStructure.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStructure.Speed = GPIO_SPEED_HIGH;
  GPIO_InitStructure.Pull = GPIO_NOPULL;
  HAL_GPIO_Init(GPIOC, &GPIO_InitStructure);
}

int main(void) {

  // Reset of all peripherals, Initializes the Flash interface and the Systick.
	HAL_Init();
  InitializeLED();

	// Infinite loop
	while (1) {
		HAL_Delay(50);
    HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_SET);
		HAL_Delay(50);
    HAL_GPIO_WritePin(GPIOC, GPIO_PIN_13, GPIO_PIN_RESET);
	}
}