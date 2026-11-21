`timescale 1ns/1ps

module tb_top;
  import uvm_pkg::*;
  import calc_types_pkg::*;
  import calc_pkg::*;

  logic clk = 1'b0;
  calc_if vif(clk);

  calc_dut #(
      .OPERAND_WIDTH(8),
      .RESULT_WIDTH(16),
      .FIFO_DEPTH(4)
  ) dut_inst (
      .clk(clk),
      .rst_n(vif.rst_n),
      .req_valid(vif.req_valid),
      .opcode(vif.opcode),
      .operand_a(vif.operand_a),
      .operand_b(vif.operand_b),
      .rsp_ready(vif.rsp_ready),
      .clear_status(vif.clear_status),
      .req_ready(vif.req_ready),
      .rsp_valid(vif.rsp_valid),
      .rsp_result(vif.rsp_result),
      .status_register(vif.status_register)
  );

  always #5ns clk = ~clk;

  initial begin
      vif.drive_reset(3);
  end

  initial begin
      uvm_config_db #(virtual calc_if)::set(null, "*", "vif", vif);
      run_test();
  end

  initial begin
      #10ms;
      $fatal(1, "TIMEOUT: simulation exceeded 10 ms");
  end

  initial begin
      if ($test$plusargs("WAVES")) begin
          $dumpfile("waves.fst");
          $dumpvars(0, tb_top);
      end
  end

  initial begin
      if (CALC_STATUS_BITS != 32)
          $fatal(1, "calc_status_t must be exactly 32 bits");
      if (CALC_OPCODE_BITS != 2)
          $fatal(1, "calc_opcode_t must be exactly 2 bits");
  end

endmodule
