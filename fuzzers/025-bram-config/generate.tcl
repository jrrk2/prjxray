# Copyright (C) 2017-2020  The Project X-Ray Authors
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC
create_project -force -part $::env(XRAY_PART) design design
read_verilog top.v
synth_design -top top

set_property -dict "PACKAGE_PIN $::env(XRAY_PIN_00) IOSTANDARD LVCMOS18" [get_ports clk]
set_property -dict "PACKAGE_PIN $::env(XRAY_PIN_01) IOSTANDARD LVCMOS18" [get_ports stb]
set_property -dict "PACKAGE_PIN $::env(XRAY_PIN_02) IOSTANDARD LVCMOS18" [get_ports di]
set_property -dict "PACKAGE_PIN $::env(XRAY_PIN_03) IOSTANDARD LVCMOS18" [get_ports do]

create_pblock roi

add_cells_to_pblock [get_pblocks roi] [get_cells roi]
resize_pblock [get_pblocks roi] -add "$::env(XRAY_ROI)"

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property BITSTREAM.GENERAL.PERFRAMECRC YES [current_design]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF]

place_design
route_design

write_checkpoint -force design.dcp
write_bitstream -force design.bit

set fp [open "design.csv" "w"]
puts $fp "site,IS_CLKARDCLK_INVERTED,IS_CLKBWRCLK_INVERTED"
foreach ram [get_cells "roi/inst_*/ram"] {
    set site [get_sites -of_objects [get_bels -of_objects $ram]]
    set IS_CLKARDCLK_INVERTED [get_property IS_CLKARDCLK_INVERTED $ram]
    set IS_CLKBWRCLK_INVERTED [get_property IS_CLKBWRCLK_INVERTED $ram]
    puts $fp "$site,$IS_CLKARDCLK_INVERTED,$IS_CLKBWRCLK_INVERTED"
}
close $fp
