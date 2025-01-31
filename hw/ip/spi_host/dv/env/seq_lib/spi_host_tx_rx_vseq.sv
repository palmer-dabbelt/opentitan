// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

// this sequence has the tasks that combine basic tasks
// from base_vseq into more elaborate actions
// such as build a full spi transaction (which is consist of cmd/addr/dummy/data segments
// or transmit a transaction which is setting up the dut, program fifo and enable transmit
// for each individual segment.
//
// these task can be easily leveraged to build more complex sequences
//

class spi_host_tx_rx_vseq extends spi_host_base_vseq;
  `uvm_object_utils(spi_host_tx_rx_vseq)
  `uvm_object_new

  semaphore spi_host_atomic = new(1);


  virtual task start_spi_host_trans(int num_transactions);
    spi_host_status_t status;
    program_spi_host_regs();
    wait_ready_for_command();
    csr_rd(.ptr(ral.status), .value(status));
    cfg.seq_cfg.host_spi_min_len = 4;
    cfg.seq_cfg.host_spi_max_len = 16;

    for(int n = 0; n < num_transactions; n++) begin
      generate_transaction();
      send_trans(transaction);
      cfg.clk_rst_vif.wait_clks(100);
    end
  endtask


  virtual task read_rx_fifo();
    bit [7:0] fifo_entries = 0;
    bit [7:0] read_q[$];

    csr_rd(.ptr(ral.status.rxqd), .value(fifo_entries));
    `uvm_info("READ_DBG", $sformatf("num entries %d", fifo_entries), UVM_LOW)
    do begin
      for(int i = 0; i <fifo_entries; i++) begin
        access_data_fifo(read_q, RxFifo);
      end
      csr_spinwait(.ptr(ral.status.active), .exp_data(1'b0));
      csr_rd(.ptr(ral.status.rxqd), .value(fifo_entries));
             `uvm_info("READ_DBG", $sformatf("num entries_ %d", fifo_entries), UVM_LOW)
    end while (fifo_entries > 0 );

    // wait for all accesses to complete
    wait_no_outstanding_access();

    // read out status/intr_state CSRs to check
    check_status_and_clear_intrs();

  endtask : start_spi_host_trans


  // sending tx requests to the agent
  virtual task send_trans(spi_transaction_item trans);
    spi_segment_item segment = new();
    `uvm_info("RX FIFO", $sformatf("New TRansaction"), UVM_LOW)
    while (trans.segments.size() > 0) begin
      // wait on DUT ready
      segment = trans.segments.pop_back();
      wait_ready_for_command();
      // lock fifo to this seq
      spi_host_atomic.get(1);
      // write data to fifo
      if(segment.command_reg.direction  != RxOnly) begin
        access_data_fifo(segment.spi_data, TxFifo);
      end
      program_command_reg(segment.command_reg);
      spi_host_atomic.put(1);
    end
  endtask : send_trans


  virtual task generate_transaction();
    transaction_init();
    `DV_CHECK_RANDOMIZE_FATAL(transaction)
    `uvm_info(`gfn, $sformatf("%s",transaction.convert2string()), UVM_LOW);
  endtask

endclass : spi_host_tx_rx_vseq
