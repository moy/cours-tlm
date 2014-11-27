/********************************************************************
 * Copyright (C) 2009, 2012 by Verimag                              *
 * Initial author: Matthieu Moy                                     *
 ********************************************************************/

#include "ensitlm.h"
#include "mb_wrapper.h"
#include "microblaze.h"
#include <iomanip>


/* Time between two step()s */
static const sc_core::sc_time PERIOD(20, sc_core::SC_NS);

//#define DEBUG
//#define INFO

using namespace std;

MBWrapper::MBWrapper(sc_core::sc_module_name name)
	: sc_core::sc_module(name), irq("irq"),
	  m_iss(0) /* identifier, not very useful since we have only one instance */
{
	m_iss.reset();
	m_iss.setIrq(false);
	SC_THREAD(run_iss);
}


void MBWrapper::exec_data_request(enum iss_t::DataAccessType mem_type,
				  uint32_t mem_addr,
				  uint32_t mem_wdata) {
	uint32_t localbuf;
	tlm::tlm_response_status status;
	switch (mem_type) {
	case iss_t::READ_WORD:
	{
		/* The ISS requested a data read
		   (mem_addr into localbuf). */
		abort(); // TODO
#ifdef DEBUG
		std::cout << hex << "read    " << setw(10) << localbuf << " at address " << mem_addr << std::endl;
#endif
		m_iss.setDataResponse(0,localbuf);
	}
	break;
	case iss_t::READ_BYTE:
	case iss_t::WRITE_HALF:
	case iss_t::WRITE_BYTE:
	case iss_t::READ_HALF:
		// Not needed for our platform.
		std::cerr << "Operation " << mem_type
			  << " unsupported for " << std::showbase << std::hex << mem_addr
			  << std::endl;
		abort();
	case iss_t::LINE_INVAL:
		// No cache => nothing to do.
		break;
	case iss_t::WRITE_WORD:
	{
		/* The ISS requested a data write
		   (mem_wdata at mem_addr). */
		abort(); // TODO
#ifdef DEBUG
		std::cout << hex << "wrote   " << setw(10) << mem_wdata << " at address " << mem_addr << std::endl;
#endif
		m_iss.setDataResponse(0,0);
	}
	break;
	case iss_t::STORE_COND:
		break;
	case iss_t::READ_LINKED:
		break;
	}
}

void MBWrapper::run_iss(void) {

	int inst_count = 0;

	while(true) {
		// std::cout << "Starting new processor cycle" << std::endl;

		if (m_iss.isBusy())
			m_iss.nullStep();
		else {
			bool ins_asked;
			uint32_t ins_addr;
			m_iss.getInstructionRequest(ins_asked, ins_addr);

			if (ins_asked) {
				/* The ISS requested an instruction.
				 * We have to do the instruction fetch
				 * by reading from memory. */
				abort(); // TODO
				m_iss.setInstruction(0,localbuf);
			}

			bool mem_asked;
			enum iss_t::DataAccessType mem_type;
			uint32_t mem_addr;
			uint32_t mem_wdata;
			m_iss.getDataRequest( mem_asked, mem_type, mem_addr, mem_wdata );

			if (mem_asked) {
				exec_data_request(mem_type, mem_addr, mem_wdata);
			}
			m_iss.step();
		}

		wait(PERIOD);
	}
}
