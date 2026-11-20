`timescale 1ns/1ps

package calc_types_pkg;

  typedef enum logic [1:0] {
      CALC_ADD     = 2'b00,
      CALC_SUB     = 2'b01,
      CALC_MUL     = 2'b10,
      CALC_INVALID = 2'b11
  } calc_opcode_t;

  typedef struct packed {
      logic [8:0]  reserved;
      logic        invalid_op_sticky;
      logic        overflow_sticky;
      logic        fifo_full;
      logic        fifo_empty;
      logic [2:0]  result_count;
      logic [15:0] last_result;
  } calc_status_t;

  localparam int CALC_STATUS_BITS = $bits(calc_status_t);
  localparam int CALC_OPCODE_BITS = $bits(calc_opcode_t);

endpackage
