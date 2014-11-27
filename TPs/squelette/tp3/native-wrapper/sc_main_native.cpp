#include "ensitlm.h"

#include "native_wrapper.h"
#include "memory.h"
#include "bus.h"
#include "timer.h"
#include "vga.h"
#include "intc.h"
#include "gpio.h"

int sc_main(int, char**)
{
	NativeWrapper& cpu = *NativeWrapper::get_instance();
	Memory memory("Memory", 0x00100000);
	Bus bus("bus");
	TIMER timer("timer", sc_core::sc_time(20, sc_core::SC_NS));
	Vga vga("vga");
	Intc intc("intc");
	Gpio gpio("gpio");

	sc_core::sc_signal<bool> timer_irq("timer_irq");
	sc_core::sc_signal<bool> vga_irq("vga_irq");
	sc_core::sc_signal<bool> cpu_irq("cpu_irq");

	// initiators
	cpu.socket.bind(bus.target);
	vga.initiator(bus.target);

	// targets
	bus.initiator(memory.target);
	bus.initiator(vga.target);
	bus.initiator(timer.target);
	bus.initiator(gpio.target);

	// interrupts
	vga.irq(vga_irq);
	timer.irq(timer_irq);
	intc.in0(vga_irq);
	intc.in1(timer_irq);
	intc.out(cpu_irq);
	cpu.irq(cpu_irq);

	//      port              start addr  size
	bus.map(memory.target,    0x20100000, 0x00100000);
	bus.map(vga.target,       0x73A00000, 0x00010000);
	bus.map(gpio.target,      0x40000000, 0x00010000);
	bus.map(timer.target,     0x41C00000, 0x00010000);

	// start the simulation
	sc_core::sc_start();

	return 0;
}
