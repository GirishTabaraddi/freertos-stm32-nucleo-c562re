/**
  ******************************************************************************
  * file           : main.c
  * brief          : Main program body
  *                  Calls target system initialization then loop in main.
  ******************************************************************************
  *
  * Copyright (c) 2025 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include <stdio.h>
#include <string.h>
#include "mx_usart2.h"

/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
uint32_t ulBlinkCount = 0;
/* Private functions prototype -----------------------------------------------*/

extern hal_uart_handle_t hUSART2;

int _write(int fd, char *ptr, int len) {
    (void)fd;

    /* Get the private handle pointer from ST's generated code */
    hal_uart_handle_t *p_huart = mx_usart2_uart_gethandle();

    /* Pass the pointer to the HAL transmit function */
    HAL_UART_Transmit(p_huart, (uint8_t*)ptr, len, 1000);

    return len;
}

/**
  * brief:  The application entry point.
  * retval: none but we specify int to comply with C99 standard
  */
int main(void)
{
  /** System Init: this code placed in targets folder initializes your system.
    * It calls the initialization (and sets the initial configuration) of the peripherals.
    * You can use STM32CubeMX to generate and call this code or not in this project.
    * It also contains the HAL initialization and the initial clock configuration.
    */
  if (mx_system_init() != SYSTEM_OK)
  {
    return (-1);
  }
  else
  {
	  /* Application Code Starts Here */
	  printf("\r\n");
	  printf("=========================================\r\n");
	  printf("  NUCLEO-C562RE — Exercise 00 (CMake)\r\n");
	  printf("  LED Blink + UART Test\r\n");
	  printf("  Core: ARM Cortex-M33 @ 64 MHz\r\n");
	  printf("=========================================\r\n\r\n");

	  while (1)
	  {
		  /* Toggle LD1 (PA5) using the new C5 HAL syntax */
		  HAL_GPIO_TogglePin(HAL_GPIOA, HAL_GPIO_PIN_5);

		  /* Print status */
		  ulBlinkCount++;
		  printf("Blink #%lu — LED is %s\r\n",
				 ulBlinkCount,
				 (HAL_GPIO_ReadPin(HAL_GPIOA, HAL_GPIO_PIN_5) == HAL_GPIO_PIN_SET)
					 ? "ON " : "OFF");

		  /* Wait 500ms */
		  HAL_Delay(500);
	  }
  }
} /* end main */

