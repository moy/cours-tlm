/********************************************************************
 * Copyright (C) 2009, 2012 by Verimag                              *
 * Initial author: Matthieu Moy                                     *
 ********************************************************************/

#ifndef MB_WRAPPER_H
#define MB_WRAPPER_H

#include "ensitlm.h"

#include "microblaze.h"

/*!
  Wrapper for MicroBlaze ISS using the BASIC protocol.
*/
struct MBWrapper : sc_core::sc_module {
	ensitlm::initiator_socket<MBWrapper> socket;
	sc_core::sc_in<bool>               irq;

	void run_iss(void);

	SC_CTOR(MBWrapper);
private:
	typedef soclib::common::MicroBlazeIss iss_t;
	void exec_data_request(enum iss_t::DataAccessType mem_type,
			       uint32_t mem_addr,
			       uint32_t mem_wdata);

	iss_t m_iss;
};

#endif // MB_WRAPPER_H
