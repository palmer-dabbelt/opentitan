// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#include "sw/device/lib/dif/dif_base.h"

#include <stdbool.h>

// `extern` declarations to give the inline functions in the corresponding
// header a link location.
extern bool dif_is_valid_toggle(dif_toggle_t val);
extern bool dif_toggle_to_bool(dif_toggle_t val);
extern dif_toggle_t dif_bool_to_toggle(bool val);
