################################################################################
##
## Copyright (c) 2004 Xilinx, Inc. All Rights Reserved.
## You may copy and modify these files for your own internal use solely with
## Xilinx programmable logic devices and Xilinx EDK system or create IP
## modules solely for Xilinx programmable logic devices and Xilinx EDK system.
## No rights are granted to distribute any files unless they are distributed in
## Xilinx programmable logic devices.
##
## microblaze_v2_1_0.tcl
##
################################################################################

# Check IXCL interface to make sure it is connected and OPB addressable
proc check_icache_fsl {mhsinst} {
   set retval 0
   set connected 0
   set mhs_handle [xget_handle $mhsinst "PARENT"]

   set icache_base [xget_hw_parameter_value $mhsinst "C_ICACHE_BASEADDR"]
   set icache_high [xget_hw_parameter_value $mhsinst "C_ICACHE_HIGHADDR"]

   # Check if connected with the IXCL bus
   set ixcl_handle [xget_handle $mhsinst "BUS_INTERFACE" "IXCL"]

   set ixcl_name ""
   if {$ixcl_handle != ""} {
      set ixcl_name [xget_value $ixcl_handle "VALUE"]
   }

   # Needed to check for ixcl_name to establish whether IXCL is connected
   # ixcl_handle has a value whether connected or not
   if {$ixcl_name != ""} {
      set ixcl_busip_handle  [xget_connected_p2p_busif_handle $ixcl_handle ]

      set ixcl_busip_name ""
      if {$ixcl_busip_handle != ""} {
         set ixcl_busip_name [xget_value $ixcl_busip_handle "VALUE"]
      }

      if {$ixcl_busip_name != ""} {
         # puts "IXCL is connected."
         set ivalid 0
         set ip_handle [xget_handle $ixcl_busip_handle "PARENT"]
         set addrlist [xget_addr_values_list_for_ipinst $ip_handle]
         set addrlen [llength $addrlist]

         set i 0
         while {$i < $addrlen} {
            set base [lindex $addrlist $i]
            # puts "base: $base"
            incr i
            set high [lindex $addrlist $i]
            # puts "high: $high"
            incr i

            if {($icache_base >= $base) && ($icache_high <= $high)} {
              set ivalid 1
              set connected 1
            }
         }
         if {! $ivalid} {
            set busip_name [xget_value $ip_handle "NAME"]
            error "ICACHE address space \[$icache_base:$icache_high\] does not match IP \"$busip_name\" on bus \"$ixcl_name\"" "" "mdt_error"
            set retval [expr $retval + 1]
         }
      }
   }

   # Check if connected by port
   set iport_name [xget_hw_port_value $mhsinst "ICACHE_FSL_OUT_WRITE"]
   # puts "iport_name: $iport_name"

   if {$iport_name != ""} {
      set idest_list [xget_hw_connected_ports_handle $mhs_handle $iport_name "SINK"]
      foreach port $idest_list {
         set bus_handle [xget_handle $port "PARENT"]
         set ip_type_handle [xget_hw_option_handle $bus_handle "IPTYPE"]

         set ip_type ""
         if {$ip_type_handle != ""} {
            set ip_type [xget_value $ip_type_handle "VALUE"]
         }

         set bus_std_handle [xget_hw_option_handle $bus_handle "BUS_STD"]
         set bus_std ""
         if {$bus_std_handle != ""} {
            set bus_std [xget_value $bus_std_handle "VALUE"]
         }

         if {($ip_type == "BUS") && ($bus_std == "FSL")} {
            set fsl_bus_name [xget_value $bus_handle "NAME"]
            puts "WARNING ***********************************************************************"
            puts "WARNING **                           MicroBlaze"
            puts "WARNING ***********************************************************************"
            puts "WARNING ** MicroBlaze XCL is connected using FSL buses.  This type of connection"
            puts "WARNING ** has been deprecated.  Please use point-to-point XCL connections as"
            puts "WARNING ** XCL FSL bus-style connections will be removed in a future release."
            puts "WARNING ** Deprecated Instruction XCL FSL bus \"$fsl_bus_name\"."
            puts "WARNING ***********************************************************************"
            set ifslvalid 0
            set ip_port_name [xget_hw_port_value $bus_handle "FSL_S_Read"]
            set ip_dest_list [xget_hw_connected_ports_handle $mhs_handle $ip_port_name "SOURCE"]

            foreach ip_port $ip_dest_list {
               # Do not require valid address for connection
               set connected 1

               set ip_handle [xget_handle $ip_port "PARENT"]
               set addrlist [xget_addr_values_list_for_ipinst $ip_handle]

               set addrlen [llength $addrlist]

               set i 0
               while {$i < $addrlen} {
                  set base [lindex $addrlist $i]
                  incr i
                  set high [lindex $addrlist $i]
                  incr i

                  if {($icache_base >= $base) && ($icache_high <= $high)} {
                     set ifslvalid 1
                  }
               }
               if {$addrlen == 0} {
                  set busip_name [xget_value $ip_handle "NAME"]
                  puts "WARNING ***********************************************************************"
                  puts "WARNING **                           MicroBlaze"
                  puts "WARNING ***********************************************************************"
                  puts "WARNING ** ICACHE address space \[$icache_base:$icache_high\] is not present"
                  puts "WARNING ** on IP \"$busip_name\" on FSL bus \"$fsl_bus_name\""
                  puts "WARNING ** This will cause problems with Xilinx Platform Studio (XPS).  XPS"
                  puts "WARNING ** requires an OPB addressable interface on Xilinx CacheLink"
                  puts "WARNING ** (XCL) memory controllers.  The interface must be connected"
                  puts "WARNING ** in XPS, but does not need to be hooked up inside the IP."
                  puts "WARNING ***********************************************************************"
               } elseif {! $ifslvalid} {
                  set busip_name [xget_value $ip_handle "NAME"]
                  puts "WARNING ***********************************************************************"
                  puts "WARNING **                           MicroBlaze"
                  puts "WARNING ***********************************************************************"
                  puts "WARNING ** ICACHE address space \[$icache_base:$icache_high\] does not match"
                  puts "WARNING ** IP \"$busip_name\" on FSL bus \"$fsl_bus_name\""
                  puts "WARNING ***********************************************************************"
               }
            }
         }
      }
   }

   if {! $connected} {
      puts "WARNING ***********************************************************************"
      puts "WARNING **                           MicroBlaze"
      puts "WARNING ***********************************************************************"
      puts "WARNING ** The C_USE_ICACHE and C_ICACHE_USE_FSL parameters are enabled, but no"
      puts "WARNING ** IP is connected to the Instruction XCL interface."
      puts "WARNING ** This may be a false warning if one is making non-xcl connections"
      puts "WARNING ** to the XCL ports on MicroBlaze in the MHS file."
      puts "WARNING ***********************************************************************"
   }

   return $retval
}

# Check DXCL interface to make sure it is connected and OPB addressable
proc check_dcache_fsl {mhsinst} {
   set retval 0
   set connected 0
   set mhs_handle [xget_handle $mhsinst "PARENT"]

   set dcache_base [xget_hw_parameter_value $mhsinst "C_DCACHE_BASEADDR"]
   set dcache_high [xget_hw_parameter_value $mhsinst "C_DCACHE_HIGHADDR"]

   set family [xget_hw_parameter_value $mhsinst "C_FAMILY"]
   # puts "Family: $family"
   # It should already be lower case, but it never hurts to be sure
   set family [string tolower $family]
   set dcache_tag [xget_hw_parameter_value $mhsinst "C_DCACHE_ADDR_TAG"]

   if {$family == "spartan3"} {
      if {$dcache_tag > 19} {
         error "Spartan3, Spartan3E, or Virtex4 XCL.  Too small of data cache size for the address range.  Increase the data cache size." "" "mdt_error"
      }
   } elseif {$family == "spartan3e"} {
      if {$dcache_tag > 19} {
         error "Spartan3, Spartan3E, or Virtex4 XCL.  Too small of data cache size for the address range.  Increase the data cache size." "" "mdt_error"
      }
   } elseif {$family == "virtex4"} {
      if {$dcache_tag > 19} {
         error "Spartan3, Spartan3E, or Virtex4 XCL.  Too small of data cache size for the address range.  Increase the data cache size." "" "mdt_error"
      }
   }

   # Check if connected with the DXCL bus
   set dxcl_handle [xget_handle $mhsinst "BUS_INTERFACE" "DXCL"]

   set dxcl_name ""
   if {$dxcl_handle != ""} {
      set dxcl_name [xget_value $dxcl_handle "VALUE"]
   }

   # Needed to check for dxcl_name to establish whether DXCL is connected
   # dxcl_handle has a value whether connected or not
   if {$dxcl_name != ""} {
      set dxcl_busip_handle  [xget_connected_p2p_busif_handle $dxcl_handle ]

      set dxcl_busip_name ""
      if {$dxcl_busip_handle != ""} {
         set dxcl_busip_name [xget_value $dxcl_busip_handle "VALUE"]
      }

      if {$dxcl_busip_name != ""} {
	 # puts "DXCL is connected."
         set dvalid 0
         set ip_handle [xget_handle $dxcl_busip_handle "PARENT"]
         set addrlist [xget_addr_values_list_for_ipinst $ip_handle]
         set addrlen [llength $addrlist]

         set i 0
         while {$i < $addrlen} {
            set base [lindex $addrlist $i]
            # puts "base: $base"
            incr i
            set high [lindex $addrlist $i]
            # puts "high: $high"
            incr i

            if {($dcache_base >= $base) && ($dcache_high <= $high)} {
              set dvalid 1
              set connected 1
            }
         }
         if {! $dvalid} {
            set busip_name [xget_value $ip_handle "NAME"]
            error "DCACHE address space \[$dcache_base:$dcache_high\] does not match IP \"$busip_name\" on bus \"$dxcl_name\"" "" "mdt_error"
            set retval [expr $retval + 1]
         }
      }
   }

   # Check if connected by port
   set dport_name [xget_hw_port_value $mhsinst "DCACHE_FSL_OUT_WRITE"]

   if {$dport_name != ""} {
      set ddest_list [xget_hw_connected_ports_handle $mhs_handle $dport_name "SINK"]
      foreach port $ddest_list {
         set bus_handle [xget_handle $port "PARENT"]
         set ip_type_handle [xget_hw_option_handle $bus_handle "IPTYPE"]

         set ip_type ""
         if {$ip_type_handle != ""} {
            set ip_type [xget_value $ip_type_handle "VALUE"]
         }

         set bus_std_handle [xget_hw_option_handle $bus_handle "BUS_STD"]
         set bus_std ""
         if {$bus_std_handle != ""} {
            set bus_std [xget_value $bus_std_handle "VALUE"]
         }

         if {($ip_type == "BUS") && ($bus_std == "FSL")} {
            set fsl_bus_name [xget_value $bus_handle "NAME"]
            puts "WARNING ***********************************************************************"
            puts "WARNING **                           MicroBlaze"
            puts "WARNING ***********************************************************************"
            puts "WARNING ** MicroBlaze XCL is connected using FSL buses.  This type of connection"
            puts "WARNING ** has been deprecated.  Please use point-to-point XCL connections as"
            puts "WARNING ** XCL FSL bus-style connections will be removed in a future release."
            puts "WARNING ** Deprecated Data XCL FSL bus \"$fsl_bus_name\"."
            puts "WARNING ***********************************************************************"
            set dfslvalid 0
            set ip_port_name [xget_hw_port_value $bus_handle "FSL_S_Read"]
            set ip_dest_list [xget_hw_connected_ports_handle $mhs_handle $ip_port_name "SOURCE"]

            foreach ip_port $ip_dest_list {
               # Do not require valid address for connection
               set connected 1

               set ip_handle [xget_handle $ip_port "PARENT"]
               set addrlist [xget_addr_values_list_for_ipinst $ip_handle]

               set addrlen [llength $addrlist]

               set i 0
               while {$i < $addrlen} {
                  set base [lindex $addrlist $i]
                  incr i
                  set high [lindex $addrlist $i]
                  incr i

                  if {($dcache_base >= $base) && ($dcache_high <= $high)} {
                     set dfslvalid 1
                  }
               }
               if {$addrlen == 0} {
                  set busip_name [xget_value $ip_handle "NAME"]
                  puts "WARNING ***********************************************************************"
                  puts "WARNING **                           MicroBlaze"
                  puts "WARNING ***********************************************************************"
                  puts "WARNING ** DCACHE address space \[$dcache_base:$dcache_high\] is not present"
                  puts "WARNING ** on IP \"$busip_name\" on FSL bus \"$fsl_bus_name\""
                  puts "WARNING ** This will cause problems with Xilinx Platform Studio (XPS).  XPS"
                  puts "WARNING ** requires an OPB addressable interface on Xilinx CacheLink"
                  puts "WARNING ** (XCL) memory controllers.  The interface must be connected"
                  puts "WARNING ** in XPS, but does not need to be hooked up inside the IP."
                  puts "WARNING ***********************************************************************"
               } elseif {! $dfslvalid} {
                  set busip_name [xget_value $ip_handle "NAME"]
                  puts "WARNING ***********************************************************************"
                  puts "WARNING **                           MicroBlaze"
                  puts "WARNING ***********************************************************************"
                  puts "WARNING ** DCACHE address space \[$dcache_base:$dcache_high\] does not match"
                  puts "WARNING ** IP \"$busip_name\" on FSL bus \"$fsl_bus_name\""
                  puts "WARNING ***********************************************************************"
               }
            }
         }
      }
   }

   if {! $connected} {
      puts "WARNING ***********************************************************************"
      puts "WARNING **                           MicroBlaze"
      puts "WARNING ***********************************************************************"
      puts "WARNING ** The C_USE_DCACHE and C_DCACHE_USE_FSL parameters are enabled, but no"
      puts "WARNING ** IP is connected to the Data XCL interface."
      puts "WARNING ** This may be a false warning if one is making non-xcl connections"
      puts "WARNING ** to the XCL ports on MicroBlaze in the MHS file."
      puts "WARNING ***********************************************************************"
   }

   return $retval
}

proc check_icache {mhsinst} {
   set retval 0
   set icache_base [xget_hw_parameter_value $mhsinst "C_ICACHE_BASEADDR"]
   set icache_high [xget_hw_parameter_value $mhsinst "C_ICACHE_HIGHADDR"]

   # TCL does not do unsigned
   if {$icache_high < 0} {
      set icache_high [expr $icache_high & 0x7fffffff]
      if {$icache_base < 0} {
        # Strip out MSB in both of them
        set icache_base [expr $icache_base & 0x7fffffff]
      }
   }

   # MSB is high, and MSB was not high in icache_high
   if {$icache_base < 0} {
      error "C_ICACHE_BASEADDR >= C_ICACHE_HIGHADDR: $icache_base >= $icache_high" "" "mdt_error"
      set retval [expr $retval + 1]
   } elseif {$icache_base >= $icache_high} {
      error "C_ICACHE_BASEADDR >= C_ICACHE_HIGHADDR: $icache_base >= $icache_high" "" "mdt_error"
      set retval [expr $retval + 1]
   }

   return $retval
}

proc check_dcache {mhsinst} {
   set retval 0
   set dcache_base [xget_hw_parameter_value $mhsinst "C_DCACHE_BASEADDR"]
   set dcache_high [xget_hw_parameter_value $mhsinst "C_DCACHE_HIGHADDR"]

   # TCL does not do unsigned
   if {$dcache_high < 0} {
      set dcache_high [expr $dcache_high & 0x7fffffff]
      if {$dcache_base < 0} {
        # Strip out MSB in both of them
        set dcache_base [expr $dcache_base & 0x7fffffff]
      }
   }

   # MSB is high, and MSB was not high in dcache_high
   if {$dcache_base < 0} {
      error "C_DCACHE_BASEADDR >= C_DCACHE_HIGHADDR: $dcache_base >= $dcache_high" "" "mdt_error"
      set retval [expr $retval + 1]
   } elseif {$dcache_base >= $dcache_high} {
      error "C_DCACHE_BASEADDR >= C_DCACHE_HIGHADDR: $dcache_base >= $dcache_high" "" "mdt_error"
      set retval [expr $retval + 1]
   }

   return $retval
}

proc check_fslwidth {mhsinst} {
   set instname [xget_hw_parameter_value $mhsinst "C_INSTANCE"]
   set fsl_width [xget_hw_parameter_value $mhsinst "C_FSL_DATA_SIZE"]

   if {$fsl_width != 32} {
      puts "WARNING: Xilinx does not support C_FSL_DATA_SIZE other than 32 on $instname"
   }

   return 0
}

proc check_fpu {mhsinst} {
   set retval 0

   set family [xget_hw_parameter_value $mhsinst "C_FAMILY"]
   # puts "Family: $family"
   # It should already be lower case, but it never hurts to be sure
   set family [string tolower $family]

   if {$family == "virtex"} {
      error "MicroBlaze C_USE_FPU = 1. FPU is not supported on Virtex, Virtex-E, Spartan2, and Spartan2-E." "" "mdt_error"
      set retval [expr $retval + 1]
   } elseif {$family == "virtexe"} {
      error "MicroBlaze C_USE_FPU = 1. FPU is not supported on Virtex, Virtex-E, Spartan2, and Spartan2-E." "" "mdt_error"
      set retval [expr $retval + 1]
   } elseif {$family == "spartan2"} {
      error "MicroBlaze C_USE_FPU = 1. FPU is not supported on Virtex, Virtex-E, Spartan2, and Spartan2-E." "" "mdt_error"
      set retval [expr $retval + 1]
   } elseif {$family == "spartan2e"} {
      error "MicroBlaze C_USE_FPU = 1. FPU is not supported on Virtex, Virtex-E, Spartan2, and Spartan2-E." "" "mdt_error"
      set retval [expr $retval + 1]
   }
   return $retval
}

proc check_iplevel_settings {mhsinst} {
   set retval 0
   set use_icache [xget_hw_parameter_value $mhsinst "C_USE_ICACHE"]
   set use_dcache [xget_hw_parameter_value $mhsinst "C_USE_DCACHE"]
   set use_fpu [xget_hw_parameter_value $mhsinst "C_USE_FPU"]
   set num_fsl [xget_hw_parameter_value $mhsinst "C_FSL_LINKS"]

   if {$use_icache == "1"} {
      # puts "ICACHE is enabled"
      set reti [check_icache $mhsinst]
      set retval [expr $retval + $reti]

      set use_icache_fsl [xget_hw_parameter_value $mhsinst "C_ICACHE_USE_FSL"]
      if {$use_icache_fsl == "1"} {
         # puts "ICACHE_FSL is enabled"
         set reti [check_icache_fsl $mhsinst]
         set retval [expr $retval + $reti]
      }
   }

   if {$use_dcache == "1"} {
      # puts "DCACHE is enabled"
      set retd [check_dcache $mhsinst]
      set retval [expr $retval + $retd]

      set use_dcache_fsl [xget_hw_parameter_value $mhsinst "C_DCACHE_USE_FSL"]
      if {$use_dcache_fsl == "1"} {
        # puts "DCACHE_FSL is enabled"
        set retd [check_dcache_fsl $mhsinst]
        set retval [expr $retval + $retd]
      }
   }

   if {$use_fpu == "1"} {
      # puts "FPU is enabled"
      set retfpu [check_fpu $mhsinst]
      set retval [expr $retval + $retfpu]
   }

   if {$num_fsl > 0} {
      # puts "FSL is enabled"
      set retfw [check_fslwidth $mhsinst]
      set retval [expr $retval + $retfw]
   }

   return $retval
}

proc update_icache_tag_bits {param_handle} {
   set msb_base 0
   set msb_high 0
   set mhsinst [xget_hw_parent_handle $param_handle]

   set use_icache [xget_hw_parameter_value $mhsinst "C_USE_ICACHE"]
   set icache_base [xget_hw_parameter_value $mhsinst "C_ICACHE_BASEADDR"]
   set icache_high [xget_hw_parameter_value $mhsinst "C_ICACHE_HIGHADDR"]
   set icache_size [xget_hw_parameter_value $mhsinst "C_CACHE_BYTE_SIZE"]

   if {$use_icache == "0"} {
      return 0;
   }

   # Is ICache valid
   set icache_valid [check_icache $mhsinst]
   if {$icache_valid != 0} {
      return 0;
   }

   # TCL does not do unsigned
   if {$icache_base < 0} {
      set msb_base 1
   }
   if {$icache_high < 0} {
      set msb_high 1
   }
   # Handle case of cacheing the entire address space
   if {($msb_high  == "1") && ($msb_base == "0")} {
      set icache_addrbits 32
   } else {
      set icache_addrsize [expr $icache_high - $icache_base + 1]
      set icache_addrbits [expr int(log($icache_addrsize) / log(2))]
   }
   set icache_bits [expr int(log($icache_size) / log(2))]

   # Byte and half-word enable bits cancel out
   set tag_bits [expr $icache_addrbits - $icache_bits]
   # puts "ICACHE tag bits: $tag_bits"

   return $tag_bits
}

proc update_dcache_tag_bits {param_handle} {
   set msb_base 0
   set msb_high 0
   set mhsinst [xget_hw_parent_handle $param_handle]
   set use_dcache [xget_hw_parameter_value $mhsinst "C_USE_DCACHE"]

   set dcache_base [xget_hw_parameter_value $mhsinst "C_DCACHE_BASEADDR"]
   set dcache_high [xget_hw_parameter_value $mhsinst "C_DCACHE_HIGHADDR"]
   set dcache_size [xget_hw_parameter_value $mhsinst "C_DCACHE_BYTE_SIZE"]

   if {$use_dcache == "0"} {
      return 0;
   }

   # Is DCache valid
   set dcache_valid [check_dcache $mhsinst]
   if {$dcache_valid != 0} {
     return 0;
   }

   # TCL does not do unsigned
   if {$dcache_base < 0} {
      set msb_base 1
   }
   if {$dcache_high < 0} {
      set msb_high 1
   }
   # Handle case of cacheing the entire address space
   if {($msb_high  == "1") && ($msb_base == "0")} {
      set dcache_addrbits 32
   } else {
      set dcache_addrsize [expr $dcache_high - $dcache_base + 1]
      set dcache_addrbits [expr int(log($dcache_addrsize) / log(2))]
   }
   set dcache_bits [expr int(log($dcache_size) / log(2))]

   # Byte and half-word enable bits cancel out
   set tag_bits [expr $dcache_addrbits - $dcache_bits]
   # puts "DCACHE tag bits: $tag_bits"

   return $tag_bits
}

