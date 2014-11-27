#include "ensitlm.h"
#include "vga.h"
#include "offsets/vga.h"
#include "offsets/memory.h"

// #define DEBUG
#define INFO

const sc_core::sc_time period((double) 1 / VGA_FREQUENCY, sc_core::SC_SEC);

int filter(const SDL_Event* event) {
	switch(event->type) {
	case SDL_QUIT:
		sc_core::sc_stop();
		break;
	default:
		break;
	}
	return 0;
}

Uint16 black;
Uint16 white;

Vga::Vga(sc_core::sc_module_name name) :
	sc_core::sc_module(name), address(0), intr(false)
{
	SC_THREAD(thread);

	if(SDL_Init(SDL_INIT_VIDEO) < 0) {
		SC_REPORT_FATAL(sc_module::name(), SDL_GetError());
	}

	atexit(SDL_Quit);

	SDL_SetEventFilter(filter);

	screen = SDL_SetVideoMode(VGA_WIDTH, VGA_HEIGHT, 16,
				  SDL_DOUBLEBUF | SDL_HWSURFACE);

	if(screen->format->BytesPerPixel != 2) {
		SC_REPORT_FATAL(sc_module::name(), SDL_GetError());
	}

	black = SDL_MapRGB(screen->format, 0x00, 0x00, 0x00);
	white = SDL_MapRGB(screen->format, 0xFF, 0xFF, 0xFF);

	SDL_WM_SetCaption(sc_module::name(), NULL);

#ifdef DEBUG
	std::cout << "Debug: " << sc_module::name() <<
		": LCD controller TLM model\n";
#endif
}

void Vga::thread() {
	while(true) {
		wait(period);
		if(address != 0) {
			vsync();
		}
	}
}

void Vga::vsync() {
	SDL_PumpEvents();
	draw();

#ifdef DEBUG
	std::cout << "Debug: " << sc_module::name() <<
		": vsync @ " << sc_core::sc_time_stamp()<< "\n";
#endif

	intr = true;
	irq.write(1);
	wait(sc_core::SC_ZERO_TIME);
	irq.write(0);
}

void Vga::draw() {
	if(SDL_MUSTLOCK(screen)) {
		SDL_LockSurface(screen);
	}

	for(int y = 0; y < VGA_HEIGHT; ++y) {
		for(int x = 0; x < VGA_WIDTH; x += (sizeof(ensitlm::data_t) * CHAR_BIT)) {

			ensitlm::data_t d;
			initiator.read(address + ((x + (y * VGA_LINE)) / CHAR_BIT), d);

			for(unsigned int bit = 0; bit < (sizeof(ensitlm::data_t) * CHAR_BIT); ++bit) {

				Uint16 *bufp = (Uint16 *) screen->pixels +
					x + (y * screen->pitch / 2) +
					((sizeof(ensitlm::data_t) * CHAR_BIT) - 1 - bit);

				if(TEST_BIT(d, bit)) {
					*bufp = white;
				}
				else {
					*bufp = black;
				}
			}

		}
	}

	if(SDL_MUSTLOCK(screen)) {
		SDL_UnlockSurface(screen);
	}
	SDL_Flip(screen);
}

tlm::tlm_response_status
Vga::read(ensitlm::addr_t a, ensitlm::data_t& d)
{
	switch(a) {
	case VGA_CFG_OFFSET:
		d = address;
		break;
	case VGA_STT_OFFSET:
		d = 0xFFFFFFFF;
		break;
	case VGA_INT_OFFSET:
		d = intr;
		break;
	default:
		SC_REPORT_ERROR(name(), "register not implemented");
		return tlm::TLM_ADDRESS_ERROR_RESPONSE;
	}
	return tlm::TLM_OK_RESPONSE;
}

tlm::tlm_response_status
Vga::write(ensitlm::addr_t a, ensitlm::data_t d)
{
	switch(a) {
	case VGA_CFG_OFFSET:
		address = d;
#ifdef INFO
		std::cout << name() << ": VGA_CFG_OFFSET changed to " << std::hex << 1+address << std::endl;
#endif
		break;
	case VGA_STT_OFFSET:
		/* see VHDL */
		break;
	case VGA_INT_OFFSET:
		intr = false;
		break;
	default:
		SC_REPORT_ERROR(name(),
				"register not implemented");
		return tlm::TLM_ADDRESS_ERROR_RESPONSE;
	}
	return tlm::TLM_OK_RESPONSE;
}
