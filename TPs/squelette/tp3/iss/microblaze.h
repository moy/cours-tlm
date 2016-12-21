/* -*- coding: utf-8 -*-
 * This file is part of SoCLIB.
 * SoCLIB is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * SoCLIB is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with SoCLIB; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 *
 * MicroBlaze Instruction Set Simulator, developed for the SoCLib Project
 * Copyright (C) 2007-2008  SLS Group of the TIMA Lab, INPG
 *
 * Contributing authors : Li Bihong,
 *                        Yan Fu,
 *                        Hao Shen <Hao.Shen@imag.fr>,
 *                        Frédéric Pétrot <Frederic.Petrot@imag.fr>
 *
 * Based on the CASS MIPS ISS developed by Frédéric Pétrot and Denis
 * Hommais back in 1996
 *
 * The MicroBlaze is a big endian machine, beware of bit numbering
 * below since it follows this convention
 * Note: The current Iss is based on the MicroBlaze version available
 * with EDK 8.2. It appears that quite a few new instructions have
 * been added in 9.2 (a MMU has been added, new mults and so on).
 * Modifications will be added if we encounter gcc generated code that
 * uses them.
 \*/

#ifndef _SOCLIB_MICROBLAZE_ISS_H_
#define _SOCLIB_MICROBLAZE_ISS_H_

#include "iss.h"
#include "soclib_endian.h"
#include "register.h"

#define R_IR_NOP        0x80000000

/*\
 *  MicroBlaze Processor structure definition
 \*/
namespace soclib {
namespace common {
	class MicroBlazeIss
		: public soclib::common::Iss
	{
	private:
		enum Vectors {
			RESET_VECTOR     = 0x00000000,
			USER_VECTOR      = 0x00000008,
			INTERRUPT_VECTOR = 0x00000010,
			BREAK_VECTOR     = 0x00000010,
			EXCEPTION_VECTOR = 0x00000020
		};
		// Bits 27:31 of ESR, also called Exception Cause
		// Bit 20:26 are called Exception Specific Status
		// w = 0 means hword access, 1 means word access
		// s = 0 means unaligned load, 1 means unaligned store
		// rx contains the gpr index of source (store) or destination (load)
		enum Exception_Cause {
			UNALIGNED_DATA_ACCESS_EXCEPTION = 1,
			ILLEGAL_OPCODE_EXCEPTION        = 2,
			INSTRUCTION_BUS_ERROR_EXCEPTION = 3,
			DATA_BUS_ERROR_EXCEPTION        = 4,
			DIVIDE_BY_ZERO_EXCEPTION        = 5,
			FLOATING_POINT_UNIT_EXCEPTION   = 6
		};
		static const int w = 20, s = 21, rx = 22;

		/*\
		 * Possible instruction types and helper struct
		 \*/
		enum {TYPEA, TYPEB,  TYPEN};

		typedef struct {
			int opcode;  /* Internal op code. */
			int format;  /* Format type */
		} IFormat;

		/*\
		 * Instruction decoding tables
		 \*/
		static const IFormat OpcodeTable[];

		/*\
		 * Instruction decoding function
		 \*/
		static inline void IDecode(uint32_t ins, char *opcode, int *rd, int *ra, int *rb, int *imm)
			{
				const IFormat *Code;

				// Instruction decoding
				Code = &OpcodeTable[(ins >> 26) & 0x3F];
				*opcode = Code->opcode;
				*ra     = (ins >> 16) & 0x1F;
				*rd     = (ins >> 21) & 0x1F;
				if (Code->format == TYPEA) {
					*imm   = ins & 0x07FF;
					*rb    = (ins >> 11) & 0x1F;
				} else if (Code->format == TYPEB) {
					*imm   = ins & 0xFFFF;
				} else { // Reserved instruction
					fprintf(stderr, "Reserved instruction 0x%08x\n", ins);
				}
			};

		// MicroBlaze Registers, all considered unsigned by default
		// (quite important for the comparisons and shifts implementation)
		uint32_t r_gpr[32]; // General Purpose Registers
		uint32_t r_imm;     // Temporate Register
		uint32_t r_msr;     // Machine Status Register
		uint32_t r_ear;     // Exception address Register
		uint32_t r_esr;     // Exception Status Register
		uint32_t r_fsr;     // Floating Point Status Register

		// States required but not visible as registers
		uint32_t m_ir;      // Current instruction
		bool     m_imm ;    // Imm
		bool     m_delay;   // Current instruction is in the delay slot
		bool     m_cancel;  // Cancel instruction in the delay slot
		bool     m_dbe;     // Data bus error
		bool     m_w;       // Unaligned access type
		uint32_t m_rx;      // Register in use when an unaligned access occurs

		uint32_t	r_pc;			// Program Counter
		uint32_t r_npc ;    // Next Program Counter
		bool        r_mem_req;
		enum DataAccessType	r_mem_type;		// Data Cache access type
		uint32_t	r_mem_addr;		// Data Cache address
		uint32_t	r_mem_wdata;		// Data Cache data value (write)
		uint32_t	r_mem_dest;		// Data Cache destination register (read)
		bool		r_dbe;			// Asynchronous Data Bus Error (write)

		uint32_t	m_rdata;
		uint32_t	m_irq;
		bool		m_ibe;

	public:
		bool branch_inst;   // indicates whether the last instruction was a branching one

		/*\
		 * The MicroBlaze has a single irq wire, called interrupt
		 \*/
		static const int n_irq = 1;

		/*\
		 * Boa                                                    (constrictor)
		 \*/
		MicroBlazeIss(uint32_t ident);

		/*\
		 * Reset handling
		 \*/
		void reset(void);

		/*\
		 * Single stepping
		 \*/
		void step(void);

		/*\
		 * Useless single stepping
		 \*/
		inline void nullStep( uint32_t cycles = 1 )
			{
			}

		inline uint32_t isBusy() {return 0;}

		inline void getInstructionRequest(bool &req, uint32_t &address) const
			{
				req = true;
				address = r_pc;
			}

		inline void getDataRequest(
			bool &valid,
			enum DataAccessType &type,
			uint32_t &address,
			uint32_t &wdata) const
			{
				valid = r_mem_req;
				address = r_mem_addr;
				wdata = r_mem_wdata;
				type = r_mem_type;
			}

		inline void setWriteBerr()
			{
				r_dbe = true;
			}

		inline void setIrq(uint32_t irq)
			{
				m_irq = irq;
			}

		/*\
		 * Feeds the Iss with an instruction to execute and an error
		 * status
		 \*/
		inline void setInstruction(bool error, uint32_t insn)
			{
				m_ibe = error;
				m_ir  = soclib::endian::uint32_swap(insn);
			};

		/*\
		 * API for memory access through the Iss
		 \*/
		void setDataResponse(bool error, uint32_t rdata);


		int cpuCauseToSignal( uint32_t cause ) const;

		// processor internal registers access API, used by
		// debugger.

		inline unsigned int getDebugRegisterCount() const
			{
				return 36;
			}

		uint32_t getDebugRegisterValue(unsigned int reg) const;

		inline size_t getDebugRegisterSize(unsigned int reg) const
			{
				return 32;
			}

		void setDebugRegisterValue(unsigned int reg, uint32_t value);

		inline uint32_t getDebugPC() const
			{
				return r_pc;
			}

		inline void setDebugPC(uint32_t pc)
			{
				r_pc = pc;
				r_npc = pc+4;
			}
	};
}
}
#endif // _SOCLIB_MICROBLAZE_ISS_H_
