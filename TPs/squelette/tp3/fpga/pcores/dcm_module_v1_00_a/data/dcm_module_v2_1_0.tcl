################################################################################
##
## Copyright (c) 2005 Xilinx, Inc. All Rights Reserved.
## You may copy and modify these files for your own internal use solely with
## Xilinx programmable logic devices and Xilinx EDK system or create IP
## modules solely for Xilinx programmable logic devices and Xilinx EDK system.
## No rights are granted to distribute any files unless they are distributed in
## Xilinx programmable logic devices.
##
## dcm_module_v2_1_0.tcl
##
################################################################################

proc check_iplevel_settings {mhsinst} {
   # Return value
   set retval 0

   set duty_cycle [xget_hw_parameter_value $mhsinst "C_DUTY_CYCLE_CORRECTION"]

   set clk_feedback [xget_hw_parameter_value $mhsinst "C_CLK_FEEDBACK"]

   set clkout_phase_shift [xget_hw_parameter_value $mhsinst "C_CLKOUT_PHASE_SHIFT"]
   set family [xget_hw_parameter_value $mhsinst "C_FAMILY"]
   # Family should already be lower case, but it never hurts to be sure
   set family [string tolower $family]

   set phase_shift [xget_hw_parameter_value $mhsinst "C_PHASE_SHIFT"]

   set deskew_adjust [xget_hw_parameter_value $mhsinst "C_DESKEW_ADJUST"]

   set param_clkin_buf [xget_hw_parameter_value $mhsinst "C_CLKIN_BUF"]
   set param_clkfb_buf [xget_hw_parameter_value $mhsinst "C_CLKFB_BUF"]
   set param_clk0_buf [xget_hw_parameter_value $mhsinst "C_CLK0_BUF"]
   set param_clk90_buf [xget_hw_parameter_value $mhsinst "C_CLK90_BUF"]
   set param_clk180_buf [xget_hw_parameter_value $mhsinst "C_CLK180_BUF"]
   set param_clk270_buf [xget_hw_parameter_value $mhsinst "C_CLK270_BUF"]
   set param_clkdv_buf [xget_hw_parameter_value $mhsinst "C_CLKDV_BUF"]
   set param_clk2x_buf [xget_hw_parameter_value $mhsinst "C_CLK2X_BUF"]
   set param_clk2x180_buf [xget_hw_parameter_value $mhsinst "C_CLK2X180_BUF"]
   set param_clkfx_buf [xget_hw_parameter_value $mhsinst "C_CLKFX_BUF"]
   set param_clkfx180_buf [xget_hw_parameter_value $mhsinst "C_CLKFX180_BUF"]

   set port_clkin [xget_hw_port_value $mhsinst "CLKIN"]
   set port_clkfb [xget_hw_port_value $mhsinst "CLKFB"]
   set port_clk0 [xget_hw_port_value $mhsinst "CLK0"]
   set port_clk90 [xget_hw_port_value $mhsinst "CLK90"]
   set port_clk180 [xget_hw_port_value $mhsinst "CLK180"]
   set port_clk270 [xget_hw_port_value $mhsinst "CLK270"]
   set port_clkdv [xget_hw_port_value $mhsinst "CLKDV"]
   set port_clk2x [xget_hw_port_value $mhsinst "CLK2X"]
   set port_clk2x180 [xget_hw_port_value $mhsinst "CLK2X180"]
   set port_clkfx [xget_hw_port_value $mhsinst "CLKFX"]
   set port_clkfx180 [xget_hw_port_value $mhsinst "CLKFX180"]

   if {$duty_cycle != "TRUE"} {
      puts "WARNING ***********************************************************************"
      puts "WARNING **                           DCM Module"
      puts "WARNING ***********************************************************************"
      puts "WARNING ** It is strongly recommended to always set the C_DUTY_CYCLE_CORRECTION"
      puts "WARNING ** parameter to TRUE."
      puts "WARNING ***********************************************************************"
   }

   if {$port_clkfb == ""} {
      if {$clk_feedback != "NONE"} {
         puts "WARNING ***********************************************************************"
         puts "WARNING **                           DCM Module"
         puts "WARNING ***********************************************************************"
         puts "WARNING ** CLKFB is not connected and C_CLK_FEEDBACK = $clk_feedback"
         puts "WARNING ***********************************************************************"
      }
   } elseif {$port_clkfb == $port_clk0} {
      if {$clk_feedback != "1X"} {
         puts "WARNING ***********************************************************************"
         puts "WARNING **                           DCM Module"
         puts "WARNING ***********************************************************************"
         puts "WARNING ** CLKFB is connected to CLK0 and C_CLK_FEEDBACK = $clk_feedback"
         puts "WARNING ***********************************************************************"
      }
   } elseif {$port_clkfb == $port_clk2x} {
      if {$clk_feedback != "2X"} {
         puts "WARNING ***********************************************************************"
         puts "WARNING **                           DCM Module"
         puts "WARNING ***********************************************************************"
         puts "WARNING ** CLKFB is connected to CLK2X and C_CLK_FEEDBACK = $clk_feedback"
         puts "WARNING ***********************************************************************"
      }
   }

   if {$family == "virtex4"} {
      if {$clkout_phase_shift == "VARIABLE"} {
         puts "WARNING ***********************************************************************"
         puts "WARNING **                           DCM Module"
         puts "WARNING ***********************************************************************"
         puts "WARNING ** C_CLKOUT_PHASE_SHIFT = VARIABLE is not supported on $family."
         puts "WARNING ***********************************************************************"
      }
   } elseif {($family == "qrvirtex2") || ($family == "qvirtex2") || ($family == "spartan3") || ($family == "spartan3e") || ($family == "virtex2") || ($family == "virtex2p")} {
      if {($clkout_phase_shift == "VARIABLE_POSITIVE") || ($clkout_phase_shift == "VARIABLE_CENTER") || ($clkout_phase_shift == "DIRECT")} {
         puts "WARNING ***********************************************************************"
         puts "WARNING **                           DCM Module"
         puts "WARNING ***********************************************************************"
         puts "WARNING ** C_CLKOUT_PHASE_SHIFT = $clkout_phase_shift is not supported on $family."
         puts "WARNING ***********************************************************************"
      }

      if {$phase_shift > 255} {
         puts "WARNING ***********************************************************************"
         puts "WARNING **                           DCM Module"
         puts "WARNING ***********************************************************************"
         puts "WARNING ** C_PHASE_SHIFT = $phase_shift (greater than 255) is not supported on $family."
         puts "WARNING ***********************************************************************"
      }
   }

   if {($deskew_adjust != "SYSTEM_SYNCHRONOUS") && ($deskew_adjust != "SOURCE_SYNCHRONOUS")} {
      puts "WARNING ***********************************************************************"
      puts "WARNING **                           DCM Module"
      puts "WARNING ***********************************************************************"
      puts "WARNING ** C_DESKEW_ADJUST = $deskew_adjust.  This should only be done after"
      puts "WARNING ** consulting Xilinx."
      puts "WARNING ***********************************************************************"
   }

   #########################################################################################
   # BUFGs should not be enabled on inputs.  SIGIS=DCMCLK should be used instead.
   #########################################################################################
   if {$param_clkin_buf != "FALSE"} {
      puts "WARNING ***********************************************************************"
      puts "WARNING **                           DCM Module"
      puts "WARNING ***********************************************************************"
      puts "WARNING ** C_CLKIN_BUF = $param_clkin_buf. It is recommended to set this"
      puts "WARNING ** parameter FALSE."
      puts "WARNING ***********************************************************************"
   }

   if {$param_clkfb_buf != "FALSE"} {
      puts "WARNING ***********************************************************************"
      puts "WARNING **                           DCM Module"
      puts "WARNING ***********************************************************************"
      puts "WARNING ** C_CLKFB_BUF = $param_clkfb_buf. It is recommended to set this"
      puts "WARNING ** parameter FALSE."
      puts "WARNING ***********************************************************************"
   }

   #########################################################################################
   # Check BUFG
   #########################################################################################
   if {($param_clk0_buf == "TRUE") && ($port_clk0 == "")} {
      puts "WARNING ***********************************************************************"
      puts "WARNING **                           DCM Module"
      puts "WARNING ***********************************************************************"
      puts "WARNING ** CLK0 is not connected and C_CLK0_BUF = $param_clk0_buf."
      puts "WARNING ***********************************************************************"
   } elseif {($param_clk0_buf == "FALSE") && ($port_clk0 != "")} {
      set buf_check [check_buf $mhsinst $port_clk0]
      if {$buf_check != 0} {
         puts "WARNING ***********************************************************************"
         puts "WARNING **                           DCM Module"
         puts "WARNING ***********************************************************************"
         puts "WARNING ** CLK0 is connected internally.  It is recommended to set"
         puts "WARNING ** C_CLK0_BUF = TRUE."
         puts "WARNING ***********************************************************************"
      }
   }
   if {($param_clk90_buf == "TRUE") && ($port_clk90 == "")} {
      puts "WARNING ***********************************************************************"
      puts "WARNING **                           DCM Module"
      puts "WARNING ***********************************************************************"
      puts "WARNING ** CLK90 is not connected and C_CLK90_BUF = $param_clk90_buf."
      puts "WARNING ***********************************************************************"
   } elseif {($param_clk90_buf == "FALSE") && ($port_clk90 != "")} {
      set buf_check [check_buf $mhsinst $port_clk90]
      if {$buf_check != 0} {
         puts "WARNING ***********************************************************************"
         puts "WARNING **                           DCM Module"
         puts "WARNING ***********************************************************************"
         puts "WARNING ** CLK90 is connected internally.  It is recommended to set"
         puts "WARNING ** C_CLK90_BUF = TRUE."
         puts "WARNING ***********************************************************************"
      }
   }
   if {($param_clk180_buf == "TRUE") && ($port_clk180 == "")} {
      puts "WARNING ***********************************************************************"
      puts "WARNING **                           DCM Module"
      puts "WARNING ***********************************************************************"
      puts "WARNING ** CLK180 is not connected and C_CLK180_BUF = $param_clk180_buf."
      puts "WARNING ***********************************************************************"
   } elseif {($param_clk180_buf == "FALSE") && ($port_clk180 != "")} {
      set buf_check [check_buf $mhsinst $port_clk180]
      if {$buf_check != 0} {
         puts "WARNING ***********************************************************************"
         puts "WARNING **                           DCM Module"
         puts "WARNING ***********************************************************************"
         puts "WARNING ** CLK180 is connected internally.  It is recommended to set"
         puts "WARNING ** C_CLK180_BUF = TRUE."
         puts "WARNING ***********************************************************************"
      }
   }
   if {($param_clk270_buf == "TRUE") && ($port_clk270 == "")} {
      puts "WARNING ***********************************************************************"
      puts "WARNING **                           DCM Module"
      puts "WARNING ***********************************************************************"
      puts "WARNING ** CLK270 is not connected and C_CLK270_BUF = $param_clk270_buf."
      puts "WARNING ***********************************************************************"
   } elseif {($param_clk270_buf == "FALSE") && ($port_clk270 != "")} {
      set buf_check [check_buf $mhsinst $port_clk270]
      if {$buf_check != 0} {
         puts "WARNING ***********************************************************************"
         puts "WARNING **                           DCM Module"
         puts "WARNING ***********************************************************************"
         puts "WARNING ** CLK270 is connected internally.  It is recommended to set"
         puts "WARNING ** C_CLK270_BUF = TRUE."
         puts "WARNING ***********************************************************************"
      }
   }
   if {($param_clkdv_buf == "TRUE") && ($port_clkdv == "")} {
      puts "WARNING ***********************************************************************"
      puts "WARNING **                           DCM Module"
      puts "WARNING ***********************************************************************"
      puts "WARNING ** CLKDV is not connected and C_CLKDV_BUF = $param_clkdv_buf."
      puts "WARNING ***********************************************************************"
   } elseif {($param_clkdv_buf == "FALSE") && ($port_clkdv != "")} {
      set buf_check [check_buf $mhsinst $port_clkdv]
      if {$buf_check != 0} {
         puts "WARNING ***********************************************************************"
         puts "WARNING **                           DCM Module"
         puts "WARNING ***********************************************************************"
         puts "WARNING ** CLKDV is connected internally.  It is recommended to set"
         puts "WARNING ** C_CLKDV_BUF = TRUE."
         puts "WARNING ***********************************************************************"
      }
   }
   if {($param_clk2x_buf == "TRUE") && ($port_clk2x == "")} {
      puts "WARNING ***********************************************************************"
      puts "WARNING **                           DCM Module"
      puts "WARNING ***********************************************************************"
      puts "WARNING ** CLK2X is not connected and C_CLK2X_BUF = $param_clk2x_buf."
      puts "WARNING ***********************************************************************"
   } elseif {($param_clk2x_buf == "FALSE") && ($port_clk2x != "")} {
      set buf_check [check_buf $mhsinst $port_clk2x]
      if {$buf_check != 0} {
         puts "WARNING ***********************************************************************"
         puts "WARNING **                           DCM Module"
         puts "WARNING ***********************************************************************"
         puts "WARNING ** CLK2X is connected internally.  It is recommended to set"
         puts "WARNING ** C_CLK2X_BUF = TRUE."
         puts "WARNING ***********************************************************************"
      }
   }
   if {($param_clk2x180_buf == "TRUE") && ($port_clk2x180 == "")} {
      puts "WARNING ***********************************************************************"
      puts "WARNING **                           DCM Module"
      puts "WARNING ***********************************************************************"
      puts "WARNING ** CLK2X180 is not connected and C_CLK2X180_BUF = $param_clk2x180_buf."
      puts "WARNING ***********************************************************************"
   } elseif {($param_clk2x180_buf == "FALSE") && ($port_clk2x180 != "")} {
      set buf_check [check_buf $mhsinst $port_clk2x180]
      if {$buf_check != 0} {
         puts "WARNING ***********************************************************************"
         puts "WARNING **                           DCM Module"
         puts "WARNING ***********************************************************************"
         puts "WARNING ** CLK2X180 is connected internally.  It is recommended to set"
         puts "WARNING ** C_CLK2X180_BUF = TRUE."
         puts "WARNING ***********************************************************************"
      }
   }
   if {($param_clkfx_buf == "TRUE") && ($port_clkfx == "")} {
      puts "WARNING ***********************************************************************"
      puts "WARNING **                           DCM Module"
      puts "WARNING ***********************************************************************"
      puts "WARNING ** CLKFX is not connected and C_CLK_FXBUF = $param_clkfx_buf."
      puts "WARNING ***********************************************************************"
   } elseif {($param_clkfx_buf == "FALSE") && ($port_clkfx != "")} {
      set buf_check [check_buf $mhsinst $port_clkfx]
      if {$buf_check != 0} {
         puts "WARNING ***********************************************************************"
         puts "WARNING **                           DCM Module"
         puts "WARNING ***********************************************************************"
         puts "WARNING ** CLKFX is connected internally.  It is recommended to set"
         puts "WARNING ** C_CLKFX_BUF = TRUE."
         puts "WARNING ***********************************************************************"
      }
   }
   if {($param_clkfx180_buf == "TRUE") && ($port_clkfx180 == "")} {
      puts "WARNING ***********************************************************************"
      puts "WARNING **                           DCM Module"
      puts "WARNING ***********************************************************************"
      puts "WARNING ** CLKFX180 is not connected and C_CLKFX180_BUF = $param_clkfx180_buf."
      puts "WARNING ***********************************************************************"
   } elseif {($param_clkfx180_buf == "FALSE") && ($port_clkfx180 != "")} {
      set buf_check [check_buf $mhsinst $port_clkfx180]
      if {$buf_check != 0} {
         puts "WARNING ***********************************************************************"
         puts "WARNING **                           DCM Module"
         puts "WARNING ***********************************************************************"
         puts "WARNING ** CLKFX180 is connected internally.  It is recommended to set"
         puts "WARNING ** C_CLKFX180_BUF = TRUE."
         puts "WARNING ***********************************************************************"
      }
   }

   #########################################################################################
   # Check for SIGIS=DCMCLK on global ports
   #########################################################################################
   set clkin_check [check_dcmclk $mhsinst $port_clkin]
   set clkfb_check [check_dcmclk $mhsinst $port_clkfb]

   return $retval
}

proc check_dcmclk {mhsinst port_name} {
   set mhs_handle [xget_handle $mhsinst "PARENT"]

   set source_list ""
   if {$port_name != ""} {
      set source_list [xget_hw_connected_ports_handle $mhs_handle $port_name "SOURCE"]
   }

   foreach port $source_list {
      set port_type [xget_port_type $port]
      set port_sigis [xget_value $port "SUBPROPERTY" "SIGIS"]
      if {($port_type == "global") && ($port_sigis != "DCMCLK")} {
         set port_name [xget_value $port "NAME"]
         puts "WARNING ***********************************************************************"
         puts "WARNING **                           DCM Module"
         puts "WARNING ***********************************************************************"
         puts "WARNING ** Global port $port_name connects to dcm_module and should specify"
         puts "WARNING ** SIGIS = DCMCLK."
         puts "WARNING ***********************************************************************"
      }
   }

   return 0
}

proc check_buf {mhsinst port_name} {
   # Return value
   set retval 0

   set local_port 0

   set mhs_handle [xget_handle $mhsinst "PARENT"]

   set sink_list ""
   if {$port_name != ""} {
      set sink_list [xget_hw_connected_ports_handle $mhs_handle $port_name "SINK"]
   }

   foreach port $sink_list {
      set port_type [xget_port_type $port]
      if {$port_type == "local"} {
         set local_port [expr $local_port + 1]
      }
   }

   if {$local_port != 0} {
      set retval [expr $retval + 1]
   }

   return $retval
}

