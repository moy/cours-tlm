#ifndef ADDRESS_MAP_H
#define ADDRESS_MAP_H

#define SRAM_BASEADDR 0x20100000
#define SRAM_SIZE     0x00100000
#include "hardware/offsets/memory.h"

#define INST_RAM_SIZE 0x00004000
#define INST_RAM_BASEADDR 0

#define GPIO_BASEADDR 0x40000000
#define GPIO_SIZE     0x00010000
#include "hardware/offsets/gpio.h"

#define TIMER_BASEADDR 0x41C00000
#define TIMER_SIZE     0x00010000
#include "hardware/offsets/timer.h"

#define VGA_BASEADDR 0x73A00000
#define VGA_SIZE     0x00010000
#include "hardware/offsets/vga.h"

#define UART_BASEADDR 0x40600000
#define UART_SIZE     0x00010000
#include "hardware/offsets/uart.h"

#endif
