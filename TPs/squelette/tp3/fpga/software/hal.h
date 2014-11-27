/* hal.h -- Hardware Abstraction Layer -- FPGA version */

#ifndef HAL_H
#define HAL_H

/* from microblaze/include */
#include "xparameters.h"
#include "xbasic_types.h"

/* serial port */
#include "xuartlite_l.h"

/* interrupt controller */
#include "xintc_l.h"

/* a smaller footprint printf */
#define printf xil_printf

#define read_mem(a) \
      (*((volatile uint32_t*) (a)))

#define write_mem(a,d) \
      ( (*((volatile uint32_t*) (a))) = (d) )

#define cpu_relax() \
      (void)NULL

#if 0
/* serial port interrupt service routine, registered statically */
static void uart_isr() {
   char c;

   /* while receive FIFO has data */
   while (!XUartLite_mIsReceiveEmpty(XPAR_RS232_BASEADDR)) {
      /* read a character */
      c = XUartLite_RecvByte(XPAR_RS232_BASEADDR);
      printf("%c", c);
   }
}
#endif

typedef Xuint32 uint32_t;

extern void __interrupt();
extern int __start();

void interrupt() {
   __interrupt();

   /* ack interrupt controller (not in TLM) */
   XIntc_mAckIntr(XPAR_OPB_INTC_0_BASEADDR, 0xFFFFFFFF);
}

int main() {
   /* mask ublaze interrupt register */
   microblaze_disable_interrupts();
   /* enable interrupt controller (not in TLM) */
   XIntc_mMasterEnable(XPAR_OPB_INTC_0_BASEADDR);
   XIntc_mEnableIntr(XPAR_OPB_INTC_0_BASEADDR,  0xFFFFFFFF);
   /* enable serial port interrupts (not in TLM) */
   XUartLite_mEnableIntr(XPAR_RS232_BASEADDR);
   /* unmask ublaze interrupt register */
   microblaze_enable_interrupts();
   return __start();
}

#endif
