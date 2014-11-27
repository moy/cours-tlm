#include "ensitlm.h"
#include "intc.h"

Intc::Intc(sc_core::sc_module_name name) :
	sc_core::sc_module(name)
{
	SC_METHOD(merge);
	dont_initialize();
	out.initialize(false);
	sensitive << in0 << in1;
}


void Intc::merge() {
	out.write(in0.read() || in1.read());
}
