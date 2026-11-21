class calc_coverage extends uvm_subscriber #(calc_observation);
  int opcode_counts [5];
  int clear_count;
  int occupancy_counts [0:4];
  int sticky_overflow_count;
  int sticky_invalid_count;
  int req_backpressure_count;
  int rsp_backpressure_count;
  int push_count;
  int pop_count;
  int simultaneous_count;
  int reset_count;
  int operand_zero_count;
  int operand_max_count;
  int operand_equal_count;
  int add_overflow_count;
  int sub_underflow_count;
  int mul_overflow_count;
  int empty_to_nonempty_count;
  int nonfull_to_full_count;
  int full_to_nonfull_count;
  int last_status_count;
  bit last_status_valid;

  `uvm_component_utils(calc_coverage)

  covergroup calc_cg;
      option.per_instance = 1;
      cp_opcode: coverpoint transaction_opcode {
          bins add = {CALC_ADD};
          bins sub = {CALC_SUB};
          bins mul = {CALC_MUL};
          bins invalid = {CALC_INVALID};
      }
      cp_occupancy: coverpoint current_status.result_count {
          bins empty = {0};
          bins one = {1};
          bins two = {2};
          bins three = {3};
          bins full = {4};
      }
      cp_overflow: coverpoint current_status.overflow_sticky {
          bins clear = {0};
          bins sticky = {1};
      }
      cp_invalid: coverpoint current_status.invalid_op_sticky {
          bins clear = {0};
          bins sticky = {1};
      }
  endgroup

  calc_opcode_t transaction_opcode;
  calc_status_t current_status;

  function new(string name, uvm_component parent);
      super.new(name, parent);
      calc_cg = new();
  endfunction

  function void write(calc_observation t);
      if (t.kind == CALC_REQ_ACCEPTED) begin
          transaction_opcode = t.opcode;
          if (t.operand_a == 0 || t.operand_b == 0)
              operand_zero_count++;
          if (t.operand_a == 8'hff || t.operand_b == 8'hff)
              operand_max_count++;
          if (t.operand_a == t.operand_b)
              operand_equal_count++;
          case (t.opcode)
              CALC_ADD:
                  if (({9'b0, t.operand_a} + {9'b0, t.operand_b}) > 255)
                      add_overflow_count++;
              CALC_SUB:
                  if (t.operand_a < t.operand_b)
                      sub_underflow_count++;
              CALC_MUL:
                  if (({8'b0, t.operand_a} * {8'b0, t.operand_b}) > 255)
                      mul_overflow_count++;
              default:
                  // Invalid and unknown encodings are counted separately.
                  begin end
          endcase
          case (t.opcode)
              CALC_ADD: opcode_counts[0]++;
              CALC_SUB: opcode_counts[1]++;
              CALC_MUL: opcode_counts[2]++;
              CALC_INVALID: opcode_counts[3]++;
              default: opcode_counts[4]++;
          endcase
      end else if (t.kind == CALC_STATUS_SNAPSHOT) begin
          current_status = t.status;
          occupancy_counts[t.status.result_count]++;
          if (last_status_valid) begin
              if (last_status_count == 0 && t.status.result_count != 0)
                  empty_to_nonempty_count++;
              if (last_status_count != 4 && t.status.result_count == 4)
                  nonfull_to_full_count++;
              if (last_status_count == 4 && t.status.result_count != 4)
                  full_to_nonfull_count++;
          end
          last_status_count = t.status.result_count;
          last_status_valid = 1;
          if (t.status.overflow_sticky) sticky_overflow_count++;
          if (t.status.invalid_op_sticky) sticky_invalid_count++;
          void'(calc_cg.sample());
      end else if (t.kind == CALC_REQ_BACKPRESSURE)
          req_backpressure_count++;
      else if (t.kind == CALC_CLEAR_EVENT)
          clear_count++;
      else if (t.kind == CALC_RESP_BACKPRESSURE)
          rsp_backpressure_count++;
      else if (t.kind == CALC_PUSH_POP_EVENT) begin
          if (t.push) push_count++;
          if (t.pop) pop_count++;
          if (t.push && t.pop) simultaneous_count++;
      end else if (t.kind == CALC_RESET_EVENT)
          reset_count++;
  endfunction

  function void report_phase(uvm_phase phase);
      `uvm_info("CALC_COVERAGE",
                $sformatf("Fallback counts: add=%0d sub=%0d mul=%0d invalid=%0d clear=%0d occupancy0-4=%0d/%0d/%0d/%0d/%0d req_bp=%0d rsp_bp=%0d push=%0d pop=%0d simultaneous=%0d overflow_sticky=%0d invalid_sticky=%0d reset=%0d operands_zero=%0d max=%0d equal=%0d add_overflow=%0d sub_underflow=%0d mul_overflow=%0d empty_to_nonempty=%0d nonfull_to_full=%0d full_to_nonfull=%0d",
                          opcode_counts[0], opcode_counts[1],
                          opcode_counts[2], opcode_counts[3],
                          clear_count, occupancy_counts[0],
                          occupancy_counts[1], occupancy_counts[2],
                          occupancy_counts[3], occupancy_counts[4],
                          req_backpressure_count, rsp_backpressure_count,
                          push_count, pop_count, simultaneous_count,
                          sticky_overflow_count, sticky_invalid_count,
                          reset_count, operand_zero_count, operand_max_count,
                          operand_equal_count, add_overflow_count,
                          sub_underflow_count, mul_overflow_count,
                          empty_to_nonempty_count, nonfull_to_full_count,
                          full_to_nonfull_count),
                UVM_LOW)
  endfunction
endclass
