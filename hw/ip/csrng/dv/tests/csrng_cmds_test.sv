// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class csrng_cmds_test extends csrng_base_test;

  `uvm_component_utils(csrng_cmds_test)
  `uvm_component_new

  function void configure_env();
    super.configure_env();

    cfg.num_cmds_min      = 0;
    cfg.num_cmds_max      = 20;
    cfg.sw_app_enable_pct = 100;

    `DV_CHECK_RANDOMIZE_FATAL(cfg)
    `uvm_info(`gfn, $sformatf("%s", cfg.convert2string()), UVM_LOW)
  endfunction
endclass : csrng_cmds_test
