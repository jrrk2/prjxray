# Copyright (C) 2017-2020  The Project X-Ray Authors
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC
source "$::env(XRAY_DIR)/utils/utils.tcl"

proc build_project {} {
    create_project -force -part $::env(XRAY_PART) piplist piplist

    read_verilog $::env(XRAY_FUZZERS_DIR)/piplist/piplist.v
    synth_design -top top

    set_property -dict "PACKAGE_PIN $::env(XRAY_PIN_00) IOSTANDARD LVCMOS18" [get_ports i]
    set_property -dict "PACKAGE_PIN $::env(XRAY_PIN_01) IOSTANDARD LVCMOS18" [get_ports o]

    create_pblock roi
    resize_pblock [get_pblocks roi] -add "$::env(XRAY_ROI)"

    set_property CFGBVS VCCO [current_design]
    set_property CONFIG_VOLTAGE 3.3 [current_design]
    set_property BITSTREAM.GENERAL.PERFRAMECRC YES [current_design]

    place_design
    route_design

    write_checkpoint -force piplist.dcp
}

proc dump_pips {} {
    proc print_tile_pips {tile_type filename} {
        set tile [lindex [get_tiles -filter "TYPE == $tile_type"] 0]
        puts "Dumping PIPs for tile $tile ($tile_type) to $filename"
        set fp [open $filename w]
        foreach pip [lsort [get_pips -filter {IS_DIRECTIONAL} -of_objects [get_tiles $tile]]] {
            set src [get_wires -uphill -of_objects $pip]
            set dst [get_wires -downhill -of_objects $pip]
            if {[llength [get_nodes -uphill -of_objects [get_nodes -of_objects $dst]]] != 1} {
                puts $fp "$tile_type.[regsub {.*/} $dst ""].[regsub {.*/} $src ""]"
            }
        }
        close $fp
    }

    print_tile_pips INT_L pips_int_l.txt
    print_tile_pips INT_R pips_int_r.txt
    puts "Done"

}

proc run {} {
    build_project
    dump_pips
}

run
