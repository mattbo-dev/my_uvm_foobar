`timescale 1ns/1ps

interface calc_if(input logic clk);
  import calc_types_pkg::*;

  logic rst_n;
  logic req_valid;
  calc_opcode_t opcode;
  logic [7:0] operand_a;
  logic [7:0] operand_b;
  logic rsp_ready;
  logic clear_status;
  logic req_ready;
  logic rsp_valid;
  logic [15:0] rsp_result;
  calc_status_t status_register;

  clocking drv_cb @(posedge clk);
      default input #1step output #1step;
      output req_valid, opcode, operand_a, operand_b, rsp_ready, clear_status;
      input req_ready, rsp_valid, rsp_result, status_register;
  endclocking

  clocking mon_cb @(posedge clk);
      default input #1step output #0;
      input rst_n, req_valid, opcode, operand_a, operand_b,
            rsp_ready, clear_status, req_ready, rsp_valid,
            rsp_result, status_register;
  endclocking

  modport dut_mp(
      input clk, rst_n, req_valid, opcode, operand_a, operand_b,
            rsp_ready, clear_status,
      output req_ready, rsp_valid, rsp_result, status_register
  );

  logic rsp_hold_active;
  logic [15:0] rsp_hold_result;
  logic req_hold_active;
  calc_opcode_t req_hold_opcode;
  logic [7:0] req_hold_a;
  logic [7:0] req_hold_b;

  initial begin
      rst_n = 1'b0;
  end

  task automatic drive_reset(input int unsigned cycles);
      rst_n <= 1'b0;
      repeat (cycles) @(posedge clk);
      rst_n <= 1'b1;
      repeat (2) @(posedge clk);
  endtask

  always @(posedge clk) begin
      if (!rst_n) begin
          rsp_hold_active = 1'b0;
          req_hold_active = 1'b0;
      end else begin
          if (rsp_valid && !rsp_ready) begin
              if (rsp_hold_active && rsp_hold_result !== rsp_result)
                  $error("ASSERT: rsp_result changed while stalled");
              rsp_hold_active = 1'b1;
              rsp_hold_result = rsp_result;
          end else begin
              rsp_hold_active = 1'b0;
          end

          if (req_valid && !req_ready) begin
              if (req_hold_active &&
                  (req_hold_opcode !== opcode ||
                   req_hold_a !== operand_a ||
                   req_hold_b !== operand_b))
                  $error("ASSERT: request fields changed while backpressured");
              req_hold_active = 1'b1;
              req_hold_opcode = opcode;
              req_hold_a = operand_a;
              req_hold_b = operand_b;
          end else begin
              req_hold_active = 1'b0;
          end
          if (status_register.result_count > 4)
              $error("ASSERT: FIFO occupancy exceeded 4");
          if (status_register.fifo_empty && status_register.fifo_full)
              $error("ASSERT: FIFO cannot be empty and full");
          if (status_register.reserved != '0)
              $error("ASSERT: reserved status bits are not zero");
      end
  end

  always @(posedge clk) begin
      if (!rst_n) begin
          #1step;
          if (status_register.result_count != 0 ||
              status_register.last_result != 0 ||
              status_register.invalid_op_sticky != 0 ||
              status_register.overflow_sticky != 0 ||
              !status_register.fifo_empty ||
              status_register.fifo_full)
              $error("ASSERT: reset did not clear FIFO, last_result, and sticky bits");
      end else begin
          if (clear_status) begin
              #1step;
              if (req_valid && req_ready) begin
                  if (opcode == CALC_INVALID &&
                      status_register.invalid_op_sticky != 1)
                      $error("ASSERT: clear_status lost same-cycle invalid sticky event");
                  if ((opcode == CALC_ADD &&
                       (({9'b0, operand_a} + {9'b0, operand_b}) > 255)) ||
                      (opcode == CALC_SUB && operand_a < operand_b) ||
                      (opcode == CALC_MUL &&
                       (({8'b0, operand_a} * {8'b0, operand_b}) > 255))) begin
                      if (status_register.overflow_sticky != 1)
                          $error("ASSERT: clear_status lost same-cycle overflow sticky event");
                  end
              end
          end
      end
  end

endinterface
