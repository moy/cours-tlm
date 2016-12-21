/********************************************************************
 * Copyright (C) 2009--2016 by Verimag                              *
 * Initial author: Matthieu Moy                                     *
 ********************************************************************/

/*!
  \file hal.h
  \brief Harwdare Abstraction Layer : implementation for MicroBlaze
  ISS.


*/
#ifndef HAL_H
#define HAL_H

#include <stdint.h>

#include <xil_io.h> // For Xil_in32 and Xil_out32
#define read_mem(a)     Xil_In32(a)
#define write_mem(a, d) Xil_Out32(a, d)
#define wait_for_irq()  /* Not implemented */
#define cpu_relax()     /* Not implemented */

// Defined in BSP
void microblaze_enable_interrupts(void);
void interrupt_handler() __attribute__ ((interrupt_handler));
#include <xil_printf.h>
#define printf xil_printf

#endif /* HAL_H */
