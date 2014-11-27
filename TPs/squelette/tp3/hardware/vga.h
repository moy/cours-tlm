#ifndef VGA_H
#define VGA_H

#include "ensitlm.h"

#include <SDL.h>

SC_MODULE(Vga) {
	SC_HAS_PROCESS(Vga);

	ensitlm::initiator_socket<Vga> initiator;
	ensitlm::target_socket<Vga> target;

	sc_core::sc_out<bool> irq;

	explicit Vga(sc_core::sc_module_name name);

	tlm::tlm_response_status
		read(ensitlm::addr_t a, ensitlm::data_t& d);

	tlm::tlm_response_status
		write(ensitlm::addr_t a, ensitlm::data_t d);

private:

	ensitlm::addr_t address;
	bool intr;

	SDL_Surface* screen;

	void vsync();
	void thread();
	void draw();

};

#endif
