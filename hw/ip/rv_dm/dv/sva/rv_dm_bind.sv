// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module rv_dm_bind;

  bind rv_dm tlul_assert #(
    .EndpointType("Device")
  ) tlul_assert_device (
    .clk_i,
    .rst_ni,
    .h2d  (regs_tl_d_i),
    .d2h  (regs_tl_d_o)
  );

  bind rv_dm tlul_assert #(
    .EndpointType("Host")
  ) tlul_assert_host (
    .clk_i,
    .rst_ni,
    .h2d  (sba_tl_h_o),
    .d2h  (sba_tl_h_i)
  );

endmodule
