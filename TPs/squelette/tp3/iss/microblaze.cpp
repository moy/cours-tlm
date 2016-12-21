/* -*- coding: utf-8 -*-
 * vim:ts=3:
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
 *                        Xavier Guérin <Xavier.Guerin@imag.fr>
 *
 * Based on the CASS MIPS ISS developed by Frédéric Pétrot and Denis
 * Hommais back in 1996
 * First version developed on the 'old' (pre-anr) SoCLib template during the
 * summer of 2007 by Li, Yan, and Hao.
 * Fairly complete rewritting and adaptation to the new Iss stuff by
 * Fred during the winter vacations of the same year.
 * GDB server adapation by Xav.
 \*/
#define MBDEBUG 0

#include "microblaze.h"
#include "soclib_endian.h"
#include "arithmetics.h"

// MicroBlaze Opcode definitions
#define OP_ADD        0x00
#define OP_RSUB       0x01
#define OP_ADDC       0x02
#define OP_RSUBC      0x03

#define OP_ADDK       0x04
#define OP_CMP        0x05
#define OP_ADDKC      0x06
#define OP_RSUBKC     0x07

#define OP_ADDI       0x08
#define OP_RSUBI      0x09
#define OP_ADDIC      0x0A
#define OP_RSUBIC     0x0B

#define OP_ADDIK      0x0C
#define OP_RSUBIK     0x0D
#define OP_ADDIKC     0x0E
#define OP_RSUBIKC    0x0F

#define OP_MUL        0x10
#define OP_BS         0x11
#define OP_IDIV       0x12
#define OP_FSL        0x13
#define OP_MULI       0x18
#define OP_BSI        0x19

#define OP_OR         0x20
#define OP_AND        0x21
#define OP_XOR        0x22
#define OP_ANDN       0x23

#define OP_SEXT       0x24
#define OP_MFS        0x25
#define OP_BR         0x26 // for br brd brld bra brad brald brk
#define OP_BRNC       0x27 // for beq bne blt ble bgt bge

#define OP_ORI        0x28
#define OP_ANDI       0x29
#define OP_XORI       0x2A
#define OP_ANDNI      0x2B

#define OP_IMM        0x2C
#define OP_RTBD       0x2D
#define OP_BRI        0x2E // for bri brid brlid brai braid
#define OP_BRNI       0x2F // for beqi bnei blti blei bgti bgei

#define OP_LBU        0x30
#define OP_LHU        0x31
#define OP_LW         0x32

#define OP_SB         0x34
#define OP_SH         0x35
#define OP_SW         0x36

#define OP_LBUI       0x38
#define OP_LHUI       0x39
#define OP_LWI        0x3A

#define OP_SBI        0x3C
#define OP_SHI        0x3D
#define OP_SWI        0x3E
#define OP_RES        0x3F


/*\
 * Machine State Register bits
 \*/

#define MSR_BE        0x1
#define MSR_IE        0x2
// Quite strange but defined so in the doc !
#define MSR_C         0x80000004
#define MSR_BIP       0x8
#define MSR_DZ        0x40
#define MSR_EIP       0x200
#define MSR_EE        0x100

#define SET_CARRY(cond)           \
	do {                              \
		r_msr = cond ? r_msr | MSR_C   \
		: r_msr & ~MSR_C; \
	} while (0)

#define GET_CARRY ((r_msr >> 2) & 1)

/*\
 * 32 bit extension of a 16 bit or a 8 bit number
 \*/
#define SEXT16(imm) (((imm)&0x8000)?0xFFFF0000|(imm):(imm))
#define SEXT8(imm) (((imm)&0x80)?0xFFFFFF00|(imm):(imm))

/*\
 * Conditional computation of the immediate value: a pure rhs
 \*/
#define IMM_OP ((uint32_t)(m_imm ? (r_imm | ins_imm) : SEXT16(ins_imm)))

/*\
 * Memory accesses to fit the current SoCLib Iss strategy
 * The type, addr, dest and wdata fields are inherited from Iss
 \*/

#define LOAD(type, addr)                                      \
	do {                                                       \
		r_mem_req = true;                                       \
		r_mem_type = type;                                      \
		r_mem_addr = addr;                                      \
		r_mem_dest = ins_rd;                                    \
	} while (0)

#define STORE(type, addr, data)                               \
	do {                                                       \
		r_mem_req = true;                                       \
		r_mem_type  = type;                                     \
		r_mem_addr  = addr;                                     \
		r_mem_wdata = data;                                     \
	} while (0)

#define HANDLE_EXCEPTION                                      \
	do {                                                       \
		r_gpr[17] = r_pc;                                       \
		r_pc = EXCEPTION_VECTOR;                                \
		r_npc = EXCEPTION_VECTOR + 4;                           \
		r_msr |= MSR_EIP;                                       \
		return;                                                 \
	} while (0)

namespace soclib { namespace common {

	namespace {

		static inline std::string mkname(uint32_t no) {
			char tmp[32];
			snprintf(tmp, 32, "mb_iss%d", (int)no);
			return std::string(tmp);
		}
	}

	const MicroBlazeIss::IFormat MicroBlazeIss::OpcodeTable[] = {
		{OP_ADD,    TYPEA},  {OP_RSUB,   TYPEA},  {OP_ADDC,   TYPEA},  {OP_RSUBC,   TYPEA},
		{OP_ADDK,   TYPEA},  {OP_CMP,    TYPEA},  {OP_ADDKC,  TYPEA},  {OP_RSUBKC,  TYPEA},
		{OP_ADDI,   TYPEB},  {OP_RSUBI,  TYPEB},  {OP_ADDIC,  TYPEB},  {OP_RSUBIC,  TYPEB},
		{OP_ADDIK,  TYPEB},  {OP_RSUBIK, TYPEB},  {OP_ADDIKC, TYPEB},  {OP_RSUBIKC, TYPEB},
		{OP_MUL,    TYPEA},  {OP_BS,     TYPEA},  {OP_IDIV,   TYPEA},  {OP_RES,     TYPEN},
		{OP_RES,    TYPEN},  {OP_RES,    TYPEN},  {OP_RES,    TYPEN},  {OP_RES,     TYPEN},
		{OP_MULI,   TYPEB},  {OP_BSI,    TYPEB},  {OP_RES,    TYPEN},  {OP_FSL,     TYPEB},
		{OP_RES,    TYPEN},  {OP_RES,    TYPEN},  {OP_RES,    TYPEN},  {OP_RES,     TYPEN},
		{OP_OR,     TYPEA},  {OP_AND,    TYPEA},  {OP_XOR,    TYPEA},  {OP_ANDN,    TYPEA},
		{OP_SEXT,   TYPEA},  {OP_MFS,    TYPEB},  {OP_BR,     TYPEA},  {OP_BRNC,    TYPEA},
		{OP_ORI,    TYPEB},  {OP_ANDI,   TYPEB},  {OP_XORI,   TYPEB},  {OP_ANDNI,   TYPEB},
		{OP_IMM,    TYPEB},  {OP_RTBD,   TYPEB},  {OP_BRI,    TYPEB},  {OP_BRNI,    TYPEB},
		{OP_LBU,    TYPEA},  {OP_LHU,    TYPEA},  {OP_LW,     TYPEA},  {OP_RES,     TYPEN},
		{OP_SB,     TYPEA},  {OP_SH,     TYPEA},  {OP_SW,     TYPEA},  {OP_RES,     TYPEN},
		{OP_LBUI,   TYPEB},  {OP_LHUI,   TYPEB},  {OP_LWI,    TYPEB},  {OP_RES,     TYPEN},
		{OP_SBI,    TYPEB},  {OP_SHI,    TYPEB},  {OP_SWI,    TYPEB},  {OP_RES,     TYPEN}
	};

	MicroBlazeIss::MicroBlazeIss(uint32_t ident)
		: Iss(mkname(ident), ident) {
		branch_inst = false;
		}

	void MicroBlazeIss::reset(void) {
		r_pc = RESET_VECTOR;
		r_npc = RESET_VECTOR + 4;
		r_dbe = false;
		m_ibe = false;
		m_dbe = false;
		r_mem_req = false;
		r_gpr[0] = 0;
		r_msr    = 0;
		r_ear    = 0;
		r_esr    = 0;
		m_ir     = R_IR_NOP;
		m_imm    = 0;
		m_delay  = false;
		m_cancel = false;
	};

	int MicroBlazeIss::cpuCauseToSignal( uint32_t cause ) const
	{
		switch (cause) {
			case DATA_BUS_ERROR_EXCEPTION:
			case INSTRUCTION_BUS_ERROR_EXCEPTION:
				return 5; // Trap (nothing better)
			case ILLEGAL_OPCODE_EXCEPTION:
				return 4; // Illegal instruction
			case DIVIDE_BY_ZERO_EXCEPTION:
			case FLOATING_POINT_UNIT_EXCEPTION:
				return 8; // Floating point exception
		};
		return 5;       // GDB SIGTRAP
	}

	void MicroBlazeIss::setDataResponse(bool error, uint32_t data)
	{
		m_dbe = error;
		r_mem_req = false;

		if (error) return;

		switch (r_mem_type) {
			case WRITE_BYTE :
			case WRITE_HALF :
			case WRITE_WORD :
			case LINE_INVAL :
				break;
			case READ_BYTE:
				r_gpr[r_mem_dest] = data & 0xFF;
				break;
			case READ_HALF:
				r_gpr[r_mem_dest] = soclib::endian::uint16_swap(data & 0xffff);
				break;
			case READ_WORD:
				r_gpr[r_mem_dest] = soclib::endian::uint32_swap(data);
				break;
			case READ_LINKED :
				fprintf(stderr, "Unhandled READ_LINKEDrequest\n");
				exit(EXIT_FAILURE);
				break;
			case STORE_COND:
				fprintf(stderr, "Unhandled STORE_COND request\n");
				exit(EXIT_FAILURE);
				break;
			default:
				fprintf(stderr, "Unhandled memory access request\n");
				exit(EXIT_FAILURE);
				break;
		}
	}

	/*\
	 * Bare copy of this comment from the mips.cpp stuffs, as a reminder
	 * The current instruction is executed in case of interrupt, but
	 * the next instruction will be delayed.
	 * The current instruction is not executed in case of exception,
	 * and there is three types of bus error events,
	 * 1 - instruction bus errors are synchronous events, signaled in
	 * the m_ibe variable
	 * 2 - read data bus errors are synchronous events, signaled in
	 * the m_dbe variable
	 * 3 - write data bus errors are asynchonous events signaled in
	 * the r_dbe flip-flop
	 * Instuction bus errors are related to the current instruction:
	 * lowest priority.
	 * Read Data bus errors are related to the previous instruction:
	 * intermediate priority
	 * Write Data bus error are related to an older instruction:
	 * highest priority
	 *
	 * The MicroBlaze documentation is not very clear on the way the
	 * exceptions should be handled, so I do it the MIPS way for now
	 \*/

	void MicroBlazeIss::step(void)
	{
		bool branch = 0xdeadbeef;
		int  next_pc = 0xdeadbeef;

		/*\
		 * Local variable used to build the value send on the
		 * interconnect.
		 * It looks like endianness and byte enable are misteriously
		 * interpreted, so each byte or half world is replicated to
		 * avoid headaches
		 \*/

		uint32_t  data;
		uint32_t  addr;

		char ins_opcode;
		int  ins_rd;
		int  ins_ra;
		int  ins_rb = 0xdeadbeef;
		int  ins_imm = 0xdeadbeef;


		bool exception = false;

		/*\
		 * Setting exceptions in the correct priority order
		 * Assumption: the value in the r_imm register is lost in case of
		 * exception, even though this is not specified in the Xilinx doc.
		 \*/

		if (m_ibe) {
			r_esr = INSTRUCTION_BUS_ERROR_EXCEPTION;
			exception = true;
		}

		if (m_dbe) {
			r_esr = DATA_BUS_ERROR_EXCEPTION;
			r_ear = r_mem_addr;
			exception = true;
		}

		if (r_dbe) {
			r_esr = DATA_BUS_ERROR_EXCEPTION;
			r_ear = r_mem_addr;
			r_dbe = false;
			exception = true;
		}

		if (exception) {
			HANDLE_EXCEPTION;
		}

		/*\
		 * Cancel the instruction in the delay slot if any,
		 * regardless of interruptions
		 \*/

		if (m_cancel) {
			m_cancel = false;
			m_delay  = false;
			r_pc  = r_npc;
			r_npc = r_pc + 4;
			return;
		}

		/*
		 * Check for interruptions
		 \*/
		if (!m_imm && !branch_inst && m_irq && !m_delay && (r_msr & MSR_IE)
				&& !(r_msr & MSR_EIP) && !(r_msr & MSR_BIP)) {
			r_gpr[14] = r_pc;
			r_pc = INTERRUPT_VECTOR;
			r_npc = INTERRUPT_VECTOR + 4;
			r_msr &= ~MSR_IE;
		} else {

		/*\
		 * Reset flags before executing a new instruction
		 \*/
		branch_inst = false;
		m_cancel = false;
		m_delay  = false;
		/* Decode the current instruction */
		IDecode(m_ir, &ins_opcode, &ins_rd, &ins_ra, &ins_rb, &ins_imm);
#if MBDEBUG
		printf("%8s 0x%08x : \n", name().c_str(), r_pc);
#endif
		switch (ins_opcode) {
			case OP_ADD:
#if MBDEBUG
				printf("add r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] + r_gpr[ins_rb];
				SET_CARRY(r_gpr[ins_rd] < r_gpr[ins_ra]);
				next_pc = r_npc + 4;
				break;

			case OP_ADDC:
#if MBDEBUG
				printf("addc r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] + r_gpr[ins_rb] + GET_CARRY;
				SET_CARRY(r_gpr[ins_rd] < r_gpr[ins_ra]);
				next_pc = r_npc + 4;
				break;

			case OP_ADDK:
#if MBDEBUG
				printf("addk r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] + r_gpr[ins_rb];
				next_pc = r_npc + 4;
				break;

			case OP_ADDKC:
#if MBDEBUG
				printf("addkc r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] + r_gpr[ins_rb] + GET_CARRY;
				next_pc = r_npc + 4;
				break;

			case OP_ADDI:
#if MBDEBUG
				printf("addi r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] + IMM_OP;
				SET_CARRY(r_gpr[ins_rd] < r_gpr[ins_ra]);
				next_pc = r_npc + 4;
				break;

			case OP_ADDIC:
#if MBDEBUG
				printf("addic r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] + IMM_OP + GET_CARRY;
				SET_CARRY(r_gpr[ins_rd] < r_gpr[ins_ra]);
				next_pc = r_npc + 4;
				break;

			case OP_ADDIK:
#if MBDEBUG
				printf("addik r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] + IMM_OP;
				next_pc = r_npc + 4;
				break;

			case OP_ADDIKC:
#if MBDEBUG
				printf("addikc r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] + IMM_OP + GET_CARRY;
				next_pc = r_npc + 4;
				break;

			case OP_AND:
#if MBDEBUG
				printf("and r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] & r_gpr[ins_rb];
				next_pc = r_npc + 4;
				break;

			case OP_ANDI:
#if MBDEBUG
				printf("andi r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] & IMM_OP;
				next_pc = r_npc + 4;
				break;

			case OP_ANDN:
#if MBDEBUG
				printf("andn r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] & ~r_gpr[ins_rb];
				next_pc = r_npc + 4;
				break;

			case OP_ANDNI:
#if MBDEBUG
				printf("andni r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] & ~IMM_OP;
				next_pc = r_npc + 4;
				break;

			case OP_BRNC:
				switch (ins_rd & 0xf) {
					case 0x0:// for beq
#if MBDEBUG
						printf("beq%s r%d, r%d\n", ins_rd & 0x10 ? "d" : "", ins_ra, ins_rb);
#endif
						branch = r_gpr[ins_ra] == 0;
						break;
					case 0x1:// for bne
#if MBDEBUG
						printf("bne%s r%d, r%d\n", ins_rd & 0x10 ? "d" : "", ins_ra, ins_rb);
#endif
						branch = r_gpr[ins_ra] != 0;
						break;
					case 0x2:// for blt
#if MBDEBUG
						printf("blt%s r%d, r%d\n", ins_rd & 0x10 ? "d" : "", ins_ra, ins_rb);
#endif
						branch = (int32_t)r_gpr[ins_ra] < 0;
						break;
					case 0x3:// for ble
#if MBDEBUG
						printf("ble%s r%d, r%d\n", ins_rd & 0x10 ? "d" : "", ins_ra, ins_rb);
#endif
						branch = (int32_t)r_gpr[ins_ra] <= 0;
						break;
					case 0x4:// for bgt
#if MBDEBUG
						printf("bgt%s r%d, r%d\n", ins_rd & 0x10 ? "d" : "", ins_ra, ins_rb);
#endif
						branch = (int32_t)r_gpr[ins_ra] > 0;
						break;
					case 0x5:// for bge
#if MBDEBUG
						printf("bge%s r%d, r%d\n", ins_rd & 0x10 ? "d" : "", ins_ra, ins_rb);
#endif
						branch = (int32_t)r_gpr[ins_ra] >= 0;
						break;
					default:
						printf("brnc has some errors, please check\n");
						break;
				}

				next_pc = r_pc + (!branch ? 8 : r_gpr[ins_rb]);

				if (!(ins_rd & 0x10) && branch)
					m_cancel = true;
				branch_inst = true;
				break;

			case OP_BRNI:
				switch (ins_rd & 0xf) {
					case 0x0:// for beqi
#if MBDEBUG
						printf("beqi%s r%d, 0x%x\n", ins_rd & 0x10 ? "d" : "", ins_ra, ins_imm);
#endif
						branch = r_gpr[ins_ra] == 0;
						break;
					case 0x1:// for bnei
#if MBDEBUG
						printf("bnei%s r%d, 0x%x\n", ins_rd & 0x10 ? "d" : "", ins_ra, ins_imm);
#endif
						branch = r_gpr[ins_ra] != 0;
						break;
					case 0x2:// for blti
#if MBDEBUG
						printf("blti%s r%d, 0x%x\n", ins_rd & 0x10 ? "d" : "", ins_ra, ins_imm);
#endif
						branch = (int32_t)r_gpr[ins_ra] < 0;
						break;
					case 0x3:// for blei
#if MBDEBUG
						printf("blei%s r%d, 0x%x\n", ins_rd & 0x10 ? "d" : "", ins_ra, ins_imm);
#endif
						branch = (int32_t)r_gpr[ins_ra] <= 0;
						break;
					case 0x4:// for bgti
#if MBDEBUG
						printf("bgti%s r%d, 0x%x\n", ins_rd & 0x10 ? "d" : "", ins_ra, ins_imm);
#endif
						branch = (int32_t)r_gpr[ins_ra] > 0;
						break;
					case 0x5:// for bgei
#if MBDEBUG
						printf("bgei%s r%d, 0x%x\n", ins_rd & 0x10 ? "d" : "", ins_ra, ins_imm);
#endif
						branch = (int32_t)r_gpr[ins_ra] >= 0;
						break;
					default:
						printf("brni has some errors, please check\n");
						break;
				}

				// + seems to have precedence over ?: finally :)
				next_pc = r_pc + (!branch ? 8 : IMM_OP);

				if (!(ins_rd & 0x10) && branch)
					m_cancel = true;
				branch_inst = true;
				break;

			case OP_BR://br bra brd brad brld brald
				if (ins_ra & 0x04)
					r_gpr[ins_rd] = r_pc;

				if (ins_ra & 0x08)
					next_pc = r_gpr[ins_rb];
				else
					next_pc = r_pc + r_gpr[ins_rb];

				if (!(ins_ra & 0x10)) { // Delay slot
					m_cancel = true;
					if ((ins_ra & 0x1F) == 0x0C) // it is a brk
						r_msr |= MSR_BIP;
				}
#if MBDEBUG
				{
					char a, l, d, b;
					l = ins_ra & 0x04;
					a = ins_ra & 0x08;
					d = ins_ra & 0x10;
					b = (ins_ra & 0x1F) == 0x0C;
					if (b) printf("brk r%d, r%d\n", ins_rd, ins_rb);
					else if (!l) printf("br%s%s r%d\n", a ? "a" : "", d ? "d" : "", ins_rb);
					else printf("br%sl%s r%d, r%d\n", a ? "a" : "", d ? "d" : "", ins_rd, ins_rb);
				}
#endif
				branch_inst = true;
				break;

			case OP_BRI://bri brai brid braid brlid bralid
				if (ins_ra & 0x04)
					r_gpr[ins_rd] = r_pc;

				if (ins_ra & 0x08) // for BRA
					next_pc = IMM_OP;
				else
					next_pc = r_pc + IMM_OP;

				if (!(ins_ra & 0x10)) { // Delay slot
					m_cancel = true;
					if ((ins_ra & 0x1F) == 0x0C) // it is a brki
						r_msr |= MSR_BIP;
				}
#if MBDEBUG
				{
					char a, l, d, b;
					l = ins_ra & 0x04;
					a = ins_ra & 0x08;
					d = ins_ra & 0x10;
					b = (ins_ra & 0x1F) == 0x0C;
					if (b) printf("brki r%d, 0x%x\n", ins_rd, ins_imm);
					else if (!l) printf("br%si%s 0x%x\n", a ? "a" : "", d ? "d" : "", ins_imm);
					else printf("br%sli%s r%d, 0x%x\n", a ? "a" : "", d ? "d" : "", ins_rd, ins_imm);
				}
#endif
				branch_inst = true;
				break;

			case OP_BS:
				if (ins_imm & 0x400) { // S == 1, left shift
					r_gpr[ins_rd] = r_gpr[ins_ra] << (r_gpr[ins_rb] & 0x1F);
#if MBDEBUG
					printf("bsll r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				} else { // S = 0, right shift
					if (ins_imm & 0x200) { // T == 1, arithmetic shift
#if MBDEBUG
						printf("bsra r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
						if (r_gpr[ins_rb] & 0x1F) { // operand not null
							r_gpr[ins_rd] = ((int32_t)r_gpr[ins_ra]) >> (r_gpr[ins_rb] & 0x1F);
						} else {
							r_gpr[ins_rd] =  r_gpr[ins_ra];
						}
					} else {
#if MBDEBUG
						printf("bsrl r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
						r_gpr[ins_rd] = r_gpr[ins_ra] >> (r_gpr[ins_rb] & 0x1F);
					}
				}
				next_pc = r_npc + 4;
				break;

			case OP_BSI:
				if (ins_imm & 0x400) {// S == 1, left shift
#if MBDEBUG
					printf("bslli r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
					r_gpr[ins_rd] = r_gpr[ins_ra] << (ins_imm & 0x1F);
				} else { // S = 0, right shift
					if (ins_imm & 0x200) { // T == 1, arithmetic shift
#if MBDEBUG
						printf("bsrai r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
						if (r_gpr[ins_rb] & 0x1F) { // operand not null
							r_gpr[ins_rd] = ((int32_t)r_gpr[ins_ra]) >> (ins_imm & 0x1F);
						} else {
							r_gpr[ins_rd] =  r_gpr[ins_ra];
						}
					} else {
#if MBDEBUG
						printf("bsrli r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
						r_gpr[ins_rd] = r_gpr[ins_ra] >> (ins_imm & 0x1F);
					}
				}
				next_pc = r_npc + 4;
				break;

			case OP_CMP: // or RSUBK
				if (ins_imm & 1) {
					uint32_t rd = r_gpr[ins_rb] + ~r_gpr[ins_ra] + 1;
#if MBDEBUG
					printf("cmp%s r%d, r%d, r%d\n", ins_imm & 2 ? "u" : "", ins_rd, ins_ra, ins_rb);
#endif
					if (ins_imm & 2)
						r_gpr[ins_rd] = r_gpr[ins_ra]
							> r_gpr[ins_rb]
							? 0x80000000 | rd
							: 0x7FFFFFFF & rd;
					else
						r_gpr[ins_rd] = (int32_t)r_gpr[ins_ra]
							> (int32_t)r_gpr[ins_rb]
							? 0x80000000 | rd
							: 0x7FFFFFFF & rd;
				} else {
#if MBDEBUG
					printf("rsubk r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
					r_gpr[ins_rd] = r_gpr[ins_rb] + ~r_gpr[ins_ra] + 1;
				}
				next_pc = r_npc + 4;
				break;

			case OP_IDIV:
#if MBDEBUG
				printf("idiv%s r%d, r%d, r%d\n", ins_imm & 2 ? "u" : "", ins_rd, ins_ra, ins_rb);
#endif

				if (r_gpr[ins_ra]) {
					if (ins_imm & 2) //Unsigned version
						r_gpr[ins_rd] = r_gpr[ins_rb] / r_gpr[ins_ra];
					else
						r_gpr[ins_rd] = (int32_t)r_gpr[ins_rb] / (int32_t)r_gpr[ins_ra];
				} else {
					r_gpr[ins_rd] = 0;
					r_msr |= MSR_DZ;
				}

				next_pc = r_npc + 4;
				break;

			case OP_FSL:
				if ((ins_imm & 0xE0) != 0) {
					fprintf(stderr, "Currently unsupported Iss FSL operation at pc = 0x%08x\n", r_pc);
				} else
#if MBDEBUG
					printf("get r%d, fsl%x\n", ins_rd, ins_imm);
#endif
				if ((ins_imm & 0x07) != 0)
					fprintf(stderr, "Currently get operation only for procid retrieval at pc = 0x%08x\n", r_pc);
				r_gpr[ins_rd] = m_ident; // As far as I understood
				next_pc = r_npc + 4;
				break;

			case OP_IMM:
#if MBDEBUG
				printf("imm 0x%04x\n", ins_imm);
#endif
				r_imm =  ins_imm << 16;
				next_pc = r_npc + 4;
				break;

			case OP_LBU:
#if MBDEBUG
				printf("lbu r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				addr = r_gpr[ins_ra] + r_gpr[ins_rb];
				LOAD(READ_BYTE, addr);
				next_pc = r_npc + 4;
				break;

			case OP_LBUI://
#if MBDEBUG
				printf("lbui r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				addr = r_gpr[ins_ra] + IMM_OP;
				LOAD(READ_BYTE, addr);
				next_pc = r_npc + 4;
				break;

			case OP_LHU:
#if MBDEBUG
				printf("lhu r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				addr = r_gpr[ins_ra] + r_gpr[ins_rb];
				if (addr & 1) {
					r_esr = (ins_rd << 5) | UNALIGNED_DATA_ACCESS_EXCEPTION;
					HANDLE_EXCEPTION;
				}
				LOAD(READ_HALF, addr);
				next_pc = r_npc + 4;
				break;

			case OP_LHUI:
#if MBDEBUG
				printf("lhui r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				addr = r_gpr[ins_ra] + IMM_OP;
				if (addr & 1) {
					r_esr = (ins_rd << 5) | UNALIGNED_DATA_ACCESS_EXCEPTION;
					HANDLE_EXCEPTION;
				}
				LOAD(READ_HALF, addr);
				next_pc = r_npc + 4;
				break;

			case OP_LW:
#if MBDEBUG
				printf("lw r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				addr = r_gpr[ins_ra] + r_gpr[ins_rb];
				if (addr & 3) {
					r_esr = (1 << 11) | (ins_rd << 5) | UNALIGNED_DATA_ACCESS_EXCEPTION;
					HANDLE_EXCEPTION;
				}
				LOAD(READ_WORD, addr);
				next_pc = r_npc + 4;
				break;

			case OP_LWI:
#if MBDEBUG
				printf("lwi r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				addr = r_gpr[ins_ra] + IMM_OP;
				if (addr & 3) {
					r_esr = (1 << 11) | (ins_rd << 5) | UNALIGNED_DATA_ACCESS_EXCEPTION;
					HANDLE_EXCEPTION;
				}
				LOAD(READ_WORD, addr);
#if MBDEBUG
				printf("\tResult => r%d = 0x%08x, r%d = 0x%08x\n", ins_rd, r_gpr[ins_rd], ins_ra, r_gpr[ins_ra]);
#endif
				next_pc = r_npc + 4;
				break;

			case OP_MFS:
				if ((ins_imm & 0xc000) == 0xc000) { // mts
					switch(ins_imm & 0x7) {
						case 0x1:
#if MBDEBUG
							printf("mts r%d, r%d\n", ins_rd, ins_imm & 7);
#endif
							r_msr = r_gpr[ins_ra];
							break;
						default:
							printf("mts has some errors, please check r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
							break;
					}
				} else if ((ins_imm & 0xc000) == 0x0) { //msrclr or msrset
					if ((ins_ra & 1) == 0x0) { //msrset
#if MBDEBUG
						printf("msrset r%d, %d\n", ins_rd, ins_imm & 7);
#endif
						r_gpr[ins_rd] = r_msr;
						r_msr |= ins_imm;
					} else if ((ins_ra & 1)== 0x1) { //msrclr
#if MBDEBUG
						printf("msrclr r%d, %d\n", ins_rd, ins_imm & 7);
#endif
						r_gpr[ins_rd] = r_msr;
						r_msr &= ~ins_imm;
					} else {
						printf("msrclr or msrset has some errors, please check r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
					}
				} else if ((ins_imm & 0xc000) == 0x8000) { //mfs
#if MBDEBUG
					printf("mfs r%d, r%d\n", ins_rd, ins_imm & 7);
#endif
					switch (ins_imm &0x7) {
						case 0x0:
							r_gpr[ins_rd] = r_pc;
							break;

						case 0x1:
							r_gpr[ins_rd] = r_msr;
							break;

						case 0x3:
							r_gpr[ins_rd] = r_ear;
							break;

						case 0x5:
							r_gpr[ins_rd] = r_esr;
							break;

						default:
							printf("mfs has some errors, please check r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
							break;
					}
				}
				next_pc = r_npc + 4;
				break;

			case OP_MUL:
#if MBDEBUG
				printf("mul r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] * r_gpr[ins_rb];
				next_pc = r_npc + 4;
				break;

			case OP_MULI:
#if MBDEBUG
				printf("muli r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] * IMM_OP ;
				next_pc = r_npc + 4;
				break;

			case OP_OR:
#if MBDEBUG
				printf("or r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] | r_gpr[ins_rb];
				next_pc = r_npc + 4;
				break;

			case OP_ORI:
#if MBDEBUG
				printf("ori r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] | IMM_OP;
				next_pc = r_npc + 4;
				break;

			case OP_RSUB:
#if MBDEBUG
				printf("rsub r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				r_gpr[ins_rd] =  r_gpr[ins_rb] +  ~r_gpr[ins_ra] + 1;
				SET_CARRY(r_gpr[ins_rd] > r_gpr[ins_ra]);
				next_pc = r_npc + 4;
				break;

			case OP_RSUBC:
#if MBDEBUG
				printf("rsubc r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				r_gpr[ins_rd] =  r_gpr[ins_rb] +  ~r_gpr[ins_ra] + GET_CARRY;
				SET_CARRY(r_gpr[ins_rd] > r_gpr[ins_ra]);
				next_pc = r_npc + 4;
				break;

			case OP_RSUBKC:
#if MBDEBUG
				printf("rsubkc r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				r_gpr[ins_rd] =  r_gpr[ins_rb] +  ~r_gpr[ins_ra] + GET_CARRY;
				next_pc = r_npc + 4;
				break;

			case OP_RSUBI:
#if MBDEBUG
				printf("rsubi r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				r_gpr[ins_rd] = IMM_OP + ~r_gpr[ins_ra] + 1;
				SET_CARRY(r_gpr[ins_rd] > IMM_OP);
				next_pc = r_npc + 4;
				break;

			case OP_RSUBIC:
#if MBDEBUG
				printf("rsubic r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				r_gpr[ins_rd] = IMM_OP +  ~r_gpr[ins_ra] + GET_CARRY;
				SET_CARRY(r_gpr[ins_rd] > IMM_OP);
				next_pc = r_npc + 4;
				break;

			case OP_RSUBIK:
#if MBDEBUG
				printf("rsubik r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				r_gpr[ins_rd] =  IMM_OP +  ~r_gpr[ins_ra] + 1;
				next_pc = r_npc + 4;
				break;

			case OP_RSUBIKC:
#if MBDEBUG
				printf("rsubikc r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				r_gpr[ins_rd] =  IMM_OP + ~r_gpr[ins_ra] + GET_CARRY;
				next_pc = r_npc + 4;
				break;

			case OP_RTBD:
				switch(ins_rd) {
					case 0x12: // RTBD
#if MBDEBUG
						printf("rtbd r%d, 0x%x\n", ins_ra, ins_imm);
#endif
						r_msr &= ~MSR_BIP;
						break;

					case 0x11: // RTID
#if MBDEBUG
						printf("rtid r%d, 0x%x\n", ins_ra, ins_imm);
#endif
						r_msr |= MSR_IE;
						break;

					case 0x14: // RTED
#if MBDEBUG
						printf("rted r%d, 0x%x\n", ins_ra, ins_imm);
#endif
						r_msr |=  MSR_EE;
						r_msr &=  ~MSR_EIP;
						break;

					case 0x10: // RTSD
#if MBDEBUG
						printf("rtsd r%d, 0x%x\n", ins_ra, ins_imm);
#endif
						break;

					default:
						fprintf(stderr, "Illegal subopcode in OP_RTBD\n");
						break;
				}
				// Very strange, ... I would have expected a IMM_OP here but
				// I doubled checked the doc and it looks like it is really a
				// SEXT16.
				next_pc = r_gpr[ins_ra] + SEXT16(ins_imm);
				branch_inst = true;
				break;

			case OP_SB:
#if MBDEBUG
				printf("sb r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				data = r_gpr[ins_rd] & 0xFF;
				addr = r_gpr[ins_ra] + r_gpr[ins_rb];
				STORE(WRITE_BYTE, addr, (data << 24) | (data << 16) | (data << 8) | data);
				next_pc = r_npc + 4;
				break;

			case OP_SBI:
#if MBDEBUG
				printf("sbi r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				data = r_gpr[ins_rd] & 0xFF;
				addr = r_gpr[ins_ra] + IMM_OP;
				STORE(WRITE_BYTE, addr, (data << 24) | (data << 16) | (data << 8) | data);
				next_pc = r_npc + 4;
				break;

			case OP_SEXT:
#if MBDEBUG
				printf("sext r%d, r%d\n", ins_rd, ins_ra);
#endif
				switch (ins_imm) {
					case 0x61: //sext16
						r_gpr[ins_rd] = SEXT16(r_gpr[ins_ra]);
						break;

					case 0x60: //sext8
						r_gpr[ins_rd] = SEXT8(r_gpr[ins_ra]);
						break;

					case 0x01: //sra
						r_gpr[ins_rd] = (int32_t)r_gpr[ins_ra] >> 1;
						SET_CARRY(r_gpr[ins_ra] & 0x1);
						break;

					case 0x21: //src
						r_gpr[ins_rd] = (r_gpr[ins_ra] >> 1) | (GET_CARRY << 31);
						SET_CARRY(r_gpr[ins_ra]& 0x1);
						break;

					case 0x41: //srl
						r_gpr[ins_rd] = r_gpr[ins_ra] >> 1;
						SET_CARRY(r_gpr[ins_ra]& 0x1);
						break;

					default :
						printf("op_sext has some errors, please check r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
						break;
				}
				next_pc = r_npc + 4;
				break;

			case OP_SH:
#if MBDEBUG
				printf("sh r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				data = soclib::endian::uint16_swap(r_gpr[ins_rd] & 0xFFFF);
				addr = r_gpr[ins_ra] + r_gpr[ins_rb];
				if (addr & 1) {
					r_esr =  (1 << 10) |(ins_rd << 5) | UNALIGNED_DATA_ACCESS_EXCEPTION;
					HANDLE_EXCEPTION;
				}
				STORE(WRITE_HALF, addr, (data << 16) | data);
				next_pc = r_npc + 4;
				break;

			case OP_SHI:
#if MBDEBUG
				printf("shi r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				data = soclib::endian::uint16_swap(r_gpr[ins_rd] & 0xFFFF);
				addr = r_gpr[ins_ra] + IMM_OP;
				if (addr & 1) {
					r_esr =  (1 << 10) |(ins_rd << 5) | UNALIGNED_DATA_ACCESS_EXCEPTION;
					HANDLE_EXCEPTION;
				}
				STORE(WRITE_HALF, addr, (data << 16) | data);
				next_pc = r_npc + 4;
				break;

			case OP_SW:
#if MBDEBUG
				printf("sw r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				addr = r_gpr[ins_ra] + r_gpr[ins_rb];
				if (addr & 3) {
					r_esr = (1 << 11) | (1 << 10) | (ins_rd << 5) | UNALIGNED_DATA_ACCESS_EXCEPTION;
					HANDLE_EXCEPTION;
				}
				STORE(WRITE_WORD, addr, soclib::endian::uint32_swap(r_gpr[ins_rd]));
				next_pc = r_npc + 4;
				break;

			case OP_SWI:
#if MBDEBUG
				printf("swi r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				addr = r_gpr[ins_ra] + IMM_OP;
				if (addr & 3) {
					r_esr = (1 << 11) | (1 << 10) | (ins_rd << 5) | UNALIGNED_DATA_ACCESS_EXCEPTION;
					HANDLE_EXCEPTION;
				}
				STORE(WRITE_WORD, addr, soclib::endian::uint32_swap(r_gpr[ins_rd]));
#if MBDEBUG
				printf("\tResult (swi) => r%d = 0x%08x, r%d = 0x%08x\n", ins_rd, r_gpr[ins_rd], ins_ra, r_gpr[ins_ra]);
#endif
				next_pc = r_npc + 4;
				break;


			case OP_XOR:
#if MBDEBUG
				printf("xor r%d, r%d, r%d\n", ins_rd, ins_ra, ins_rb);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] ^ r_gpr[ins_rb];
				next_pc = r_npc + 4;
				break;

			case OP_XORI:
#if MBDEBUG
				printf("xori r%d, r%d, 0x%x\n", ins_rd, ins_ra, ins_imm);
#endif
				r_gpr[ins_rd] = r_gpr[ins_ra] ^ IMM_OP;
				next_pc = r_npc + 4;
				break;

			default :
				fprintf(stderr, "Found an illegal instruction op_code at pc = 0x%08x, please check r%d, r%d, r%d\n", r_pc, ins_rd, ins_ra, ins_rb);
				break;

		}
		/*\
		 * Ensures that we leave here with a zeroed r0
		 \*/
		r_gpr[0] = 0;

		/*\
		 * Make the r_imm register not significant if not an imm insn
		 \*/
		m_imm = ins_opcode == OP_IMM;


			r_pc  = r_npc;
			r_npc = next_pc;
		}
	} // end MicroBlazeIss::step

	uint32_t MicroBlazeIss::getDebugRegisterValue(unsigned int reg) const
	{

		switch (reg)
		{
			case 0:
				return 0;
			case 1 ... 31:
				return r_gpr[reg];
			case 32:
				return r_pc;
			case 33:
				return r_msr;
			case 34:
				return r_ear;
			case 35:
				return r_esr;
			case 36:
				return r_fsr;
			default:
				return 0;
		}
	}

	void MicroBlazeIss::setDebugRegisterValue(unsigned int reg, uint32_t value)
	{
		switch (reg)
		{
			case 1 ... 31:
				r_gpr[reg] = value;
				break;
			case 32:
				r_pc = value;
	r_npc = value+4;
				break;
			case 33:
				r_ear = value;
				break;
			case 34:
				r_esr = value;
				break;
			case 35:
				r_fsr = value;
				break;
			default:
				break;
		}
	}

} // end common
} // end soclib
