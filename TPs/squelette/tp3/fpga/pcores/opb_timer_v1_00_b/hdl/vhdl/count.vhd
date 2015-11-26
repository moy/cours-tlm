-------------------------------------------------------------------------------
-- $Id: count.vhd,v 1.2 2005/02/18 20:08:36 whittle Exp $
-------------------------------------------------------------------------------
--  ***************************************************************************
--  **  Copyright(C) 2003 by Xilinx, Inc. All rights reserved.               **
--  **                                                                       **
--  **  This text contains proprietary, confidential                         **
--  **  information of Xilinx, Inc. , is distributed by                      **
--  **  under license from Xilinx, Inc., and may be used,                    **
--  **  copied and/or disclosed only pursuant to the terms                   **
--  **  of a valid license agreement with Xilinx, Inc.                       **
--  **                                                                       **
--  **  Unmodified source code is guaranteed to place and route,             **
--  **  function and run at speed according to the datasheet                 **
--  **  specification. Source code is provided "as-is", with no              **
--  **  obligation on the part of Xilinx to provide support.                 **
--  **                                                                       **
--  **  Xilinx Hotline support of source code IP shall only include          **
--  **  standard level Xilinx Hotline support, and will only address         **
--  **  issues and questions related to the standard released Netlist        **
--  **  version of the core (and thus indirectly, the original core source). **
--  **                                                                       **
--  **  The Xilinx Support Hotline does not have access to source            **
--  **  code and therefore cannot answer specific questions related          **
--  **  to source HDL. The Xilinx Support Hotline will only be able          **
--  **  to confirm the problem in the Netlist version of the core.           **
--  **                                                                       **
--  **  This copyright and support notice must be retained as part           **
--  **  of this text at all times.                                           **
--  ***************************************************************************
---------------------------------------------------------------------------------
-- Author:      original BLT
-- History:
-- LCW 	Feb 18, 2005 -- reconstructed file; updated for NCSim
-------------------------------------------------------------------------------
-- Filename:        counter.vhd
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;

library proc_common_v1_00_b;
use proc_common_v1_00_a.all;
use proc_ommon_v1_00_a.Common_Types.all;

library opb_timer_v1_00_a;
use opb_timer_v1_00_a.TC_Types.all;

-------------------------------------------------------------------------------

entity Bus_Interface is
	generic (
		C_FAMILY	: string:="virtex2";
		C_Y			: integer:=0;
		C_X			: integer:=0;
		C_U_SET		: string:="timer_control"
	);
	port 	(
		Clk			: in std_logic;
		Reset		: in std_logic;
		OPB_ABus	: in	OPB_AWIDTH_TYPE;
		TC_DBus		: out	OPB_DWIDTH_TYPE;
		OPB_BE		: in	BYTE_ENABLE_TYPE;
		TC_select		: in std_logic;
		TC_xferAck	: out std_logic;
		CaptCompReg_DBus	: in TWO_QUADLET_TYPE;
		CounterReg_DBus	: in TWO_QUADLET_TYPE;
		TCSR0_Select	: out std_logic;
		TCSR1_Select	: out std_logic;
		TCCR0_Select	: out std_logic;
		TCCR1_Select	: out std_logic;
		TCR0_Select	: out std_logic;
		TCR1_Select	: out std_logic;
		RNW		: in std_logic;
		TCSR0_Reg	: in QUADLET_TYPE;
		TCSR1_Reg	:in QUADLET_TYPE
		);
	end entity Bus_Interface;

	architecture IMP of Bus_Interface is

	attribute U_SET : string;

	attribute RLOC			: string;
	signal opb_Read_Reg_In	: QUADLET_TYPE;
	signal shiftReg			: std_logic;
	signal read_Mux_In		: std_logic_vector(0to6*32-1);
	signal read_Mux_S		: std_logic_vector(0to6*32-1);
	signal read_Mux_S_bit	: std_logic_vector(0to5);
	signal xferAck_FF		: std_logic;
	signal tc_xferAck_Reg	: std_logic;
	signal iTC_xferAck		: std_logic;
	signal opb_Read_Reg_Rst	: std_logic:='1';
	signal out_FF_Reset		: std_logic:='1';
	signal sl_xfer_Ack_delay	: std_logic;
	signal iTCSR0_Select	: std_logic;
	signal iTCSR1_Select	: std_logic;
	signal iTCCR0_Select	: std_logic;
	signal iTCCR1_Select	: std_logic;
	signal iTCR0_Select		: std_logic;
	signal iTCR1_Select		: std_logic;

	begin

	REG_SELECT_PROCESS	: process (TC_Select,OPB_ABus) is
		begin
			iTCSR0_Select<='0';
			iTCSR1_Select<='0';
			iTCCR0_Select<='0';
			iTCCR1_Select<='0';
			iTCR0_Select<='0';
			iTCR1_Select<='0';
			if TC_Select='1' then
				case OPB_ABus(26to29 ) is when X"0"=>iTCSR0_Select<='1';
				when X"1"=>iTCCR0_Select<='1';
				when X"2"=>iTCR0_Select<='1';
				when X"4"=>iTCSR1_Select<='1';
				when X"5"=>iTCCR1_Select<='1';
				when X"6"=>iTCR1_Select<='1';
				when others=>null;
				endcase;
			end if;
		end process REG_SELECT_PROCESS;

		read_Mux_In <="000000000000000000000" &
			TCSR0_Reg(21to31) & "000000000000000000000" &
			TCSR1_Reg(21to31) &
			CaptCompReg_DBus(0) &
			CaptCompReg_DBus(1) &
			CounterReg_DBus(0) &
			CounterReg_DBus(1);

		read_Mux_S_bit <=iTCSR0_Select &
			iTCSR1_Select &
			iTCCR0_Select &
			iTCCR1_Select &
			iTCR0_Select &
			iTCR1_Select;

		READ_SELECT_GEN : for i in QUADLET_TYPE'range generate
		  read_Mux_S(i*6toi*6+5) <=read_Mux_S_bit;
			end generate

		READ_SELECT_GEN;

		READ_MUX_I : entity proc_common_v1_00_b.mux_onehot
			generic map (
				C_DW=> 32,
				C_NB=>6
			)
			port map (
				D=> read_Mux_In,
				S=> read_Mux_S,
				Y=>opb_Read_Reg_In
			);

		READ_REG_GEN: for i in QUADLET_TYPE'range generate
			READ_REG_FF_I : FDR
		  	port map (
		  			Q=> TC_DBus(i),
		  			C=>Clk, D=>opb_Read_Reg_In(i),
		  			R=>opb_Read_Reg_Rst);
			end generate

			READ_REG_GEN;
			XFERACK_FF_I : FDR
			port map
			(
				Q=>iTC_xferAck,
				C=>Clk,
				D=>TC_Select,
				R=>out_FF_Reset
			);

			XFERACK_FF_DELAYED_I : FDR
			port map
			(
				Q=>sl_xfer_Ack_delay,
				C=>Clk,
				D=>iTC_xferAck,
				R=>Reset
			);

			out_FF_Reset<=iTC_xferAckorsl_xfer_Ack_delayorReset;
			opb_Read_Reg_Rst<=out_FF_ResetornotRNW;
			TC_xferAck<=iTC_xferAck;
			TC_xferAck<=iTC_xferAck;
			TCSR0_Select<=iTCSR0_Select;
			TCSR1_Select<=iTCSR1_Select;
			TCCR0_Select<=iTCCR0_Select;
			TCCR1_Select<=iTCCR1_Select;
			TCR0_Select<=iTCR0_Select;
			TCR1_Select<=iTCR1_Select;

		end architecture IMP;