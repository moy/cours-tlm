#include "ensitlm.h"
#include "native_wrapper.h"

/* extern "C" is needed since the software is compiled in C and
 * is linked against native_wrapper.cpp, which is compiled in C++.
 */
extern "C" int __start();
extern "C" void __interrupt();

extern "C" void write_mem(uint32_t addr, uint32_t data) {
	abort(); // TODO
}

extern "C" unsigned int read_mem(uint32_t addr) {
	abort(); // TODO
}

extern "C" void cpu_relax() {
	abort(); // TODO
}

extern "C" void wait_for_irq() {
	abort(); // TODO
}

/* To keep it simple, the soft wrapper is a singleton, we can
 * call its methods in a simple manner, using
 * NativeWrapper::get_instance()->method_name()
 */
NativeWrapper * NativeWrapper::get_instance() {
	static NativeWrapper * instance = NULL;
	if (!instance)
		instance = new NativeWrapper("native_wrapper");
	return instance;
}

NativeWrapper::NativeWrapper(sc_core::sc_module_name name) : sc_module(name),
							     irq("irq")
{
}

void NativeWrapper::write_mem(unsigned int addr, unsigned int data)
{
}

unsigned int NativeWrapper::read_mem(unsigned int addr)
{
	abort(); // TODO
}

void NativeWrapper::cpu_relax()
{
	abort(); // TODO
}

void NativeWrapper::wait_for_irq()
{
	abort(); // TODO
}

void NativeWrapper::compute()
{
	abort(); // TODO
}

void NativeWrapper::interrupt_handler_internal()
{
}
