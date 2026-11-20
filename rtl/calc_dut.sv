`timescale 1ns/1ps

module calc_dut #(
    parameter int OPERAND_WIDTH = 8,
    parameter int RESULT_WIDTH = 16,
    parameter int FIFO_DEPTH = 4
) (
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic                         req_valid,
    input  calc_types_pkg::calc_opcode_t opcode,
    input  logic [OPERAND_WIDTH-1:0]     operand_a,
    input  logic [OPERAND_WIDTH-1:0]     operand_b,
    input  logic                         rsp_ready,
    input  logic                         clear_status,
    output logic                         req_ready,
    output logic                         rsp_valid,
    output logic [RESULT_WIDTH-1:0]      rsp_result,
    output calc_types_pkg::calc_status_t status_register
);

  import calc_types_pkg::*;

  localparam logic [OPERAND_WIDTH-1:0] OPERAND_MAX = {OPERAND_WIDTH{1'b1}};
  localparam int FIFO_PTR_WIDTH = $clog2(FIFO_DEPTH);

  logic [RESULT_WIDTH-1:0] fifo_mem [0:FIFO_DEPTH-1];
  logic [FIFO_PTR_WIDTH-1:0] read_ptr;
  logic [FIFO_PTR_WIDTH-1:0] write_ptr;
  logic [2:0] fifo_count;
  logic invalid_op_sticky_q;
  logic overflow_sticky_q;
  logic [15:0] last_result_q;

  wire fifo_empty = (fifo_count == 0);
  wire fifo_full = (fifo_count == FIFO_DEPTH);
  wire can_accept_valid = !fifo_full;
  wire is_invalid = (opcode == CALC_INVALID);
  wire pop = rsp_valid && rsp_ready;
  wire push = req_valid && req_ready && !is_invalid;

  assign req_ready = is_invalid ? 1'b1 : can_accept_valid;
  assign rsp_valid = !fifo_empty;
  assign rsp_result = fifo_empty ? '0 : fifo_mem[read_ptr];

  always_comb begin
      status_register = '0;
      status_register.reserved = '0;
      status_register.invalid_op_sticky = invalid_op_sticky_q;
      status_register.overflow_sticky = overflow_sticky_q;
      status_register.fifo_full = fifo_full;
      status_register.fifo_empty = fifo_empty;
      status_register.result_count = fifo_count;
      status_register.last_result = last_result_q;
  end

  always_ff @(posedge clk) begin
      if (!rst_n) begin
          read_ptr <= '0;
          write_ptr <= '0;
          fifo_count <= '0;
          invalid_op_sticky_q <= 1'b0;
          overflow_sticky_q <= 1'b0;
          last_result_q <= '0;
          for (int i = 0; i < FIFO_DEPTH; i++)
              fifo_mem[i] <= '0;
      end else begin
          logic [RESULT_WIDTH-1:0] calculated_result;
          logic overflow_event;
          logic invalid_event;

          calculated_result = '0;
          overflow_event = 1'b0;
          invalid_event = 1'b0;

          if (clear_status) begin
              invalid_op_sticky_q <= 1'b0;
              overflow_sticky_q <= 1'b0;
          end

          case (opcode)
              CALC_ADD: begin
                  calculated_result = {8'b0, operand_a} + {8'b0, operand_b};
                  if (({1'b0, operand_a} + {1'b0, operand_b}) > OPERAND_MAX)
                      overflow_event = 1'b1;
              end
              CALC_SUB: begin
                  calculated_result = operand_a - operand_b;
                  if (operand_a < operand_b)
                      overflow_event = 1'b1;
              end
              CALC_MUL: begin
                  calculated_result = {8'b0, operand_a} * {8'b0, operand_b};
                  if (({8'b0, operand_a} * {8'b0, operand_b}) > OPERAND_MAX)
                      overflow_event = 1'b1;
              end
              CALC_INVALID: begin
                  invalid_event = 1'b1;
                  calculated_result = '0;
              end
              default: begin
                  invalid_event = 1'b1;
              end
          endcase

          if (req_valid && req_ready && !is_invalid) begin
              fifo_mem[write_ptr] <= calculated_result;
              write_ptr <= (write_ptr == FIFO_DEPTH-1) ?
                           '0 : write_ptr + 1'b1;
              last_result_q <= calculated_result;
          end

          if (push && pop) begin
              read_ptr <= (read_ptr == FIFO_DEPTH-1) ?
                          '0 : read_ptr + 1'b1;
          end else if (push) begin
              fifo_count <= fifo_count + 1'b1;
          end else if (pop) begin
              read_ptr <= (read_ptr == FIFO_DEPTH-1) ?
                          '0 : read_ptr + 1'b1;
              fifo_count <= fifo_count - 1'b1;
          end

          if (invalid_event)
              invalid_op_sticky_q <= 1'b1;
          if (overflow_event)
              overflow_sticky_q <= 1'b1;
      end
  end

endmodule
