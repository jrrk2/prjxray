# Copyright (C) 2017-2020  The Project X-Ray Authors
#
# Use of this source code is governed by a ISC-style
# license that can be found in the LICENSE file or at
# https://opensource.org/licenses/ISC
#
# SPDX-License-Identifier: ISC
source "$::env(SRC_DIR)/template.tcl"

# set vals "SLOW MEDIUM FAST"
# ERROR: [Common 17-69] Command failed: Slew type 'MEDIUM' is not supported by I/O standard 'LVCMOS18'
set prop SLEW
set port [get_ports do]
source "$::env(SRC_DIR)/sweep.tcl"
