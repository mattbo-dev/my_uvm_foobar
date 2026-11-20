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

  function void write(calc_observation obs);
      if (obs.kind == CALC_REQ_ACCEPTED) begin
          transaction_opcode = obs.opcode;
          case (obs.opcode)
              CALC_ADD: opcode_counts[0]++;
              CALC_SUB: opcode_counts[1]++;
              CALC_MUL: opcode_counts[2]++;
              CALC_INVALID: opcode_counts[3]++;
              default: opcode_counts[4]++;
          endcase
          if (obs.clear_status) clear_count++;
      end else if (obs.kind == CALC_STATUS_SNAPSHOT) begin
          current_status = obs.status;
          occupancy_counts[obs.status.result_count]++;
          if (obs.status.overflow_sticky) sticky_overflow_count++;
          if (obs.status.invalid_op_sticky) sticky_invalid_count++;
          void'(calc_cg.sample());
      end else if (obs.kind == CALC_REQ_BACKPRESSURE)
          req_backpressure_count++;
      else if (obs.kind == CALC_RESP_BACKPRESSURE)
          rsp_backpressure_count++;
      else if (obs.kind == CALC_PUSH_POP_EVENT) begin
          if (obs.push) push_count++;
          if (obs.pop) pop_count++;
          if (obs.push && obs.pop) simultaneous_count++;
      end else if (obs.kind == CALC_RESET_EVENT)
          reset_count++;
  endfunction

  function void report_phase(uvm_phase phase);
      `uvm_info("CALC_COVERAGE",
                $sformatf("Fallback counts: add=%0d sub=%0d mul=%0d invalid=%0d clear=%0d occupancy0-4=%0d/%0d/%0d/%0d/%0d req_bp=%0d rsp_bp=%0d push=%0d pop=%0d simultaneous=%0d overflow_sticky=%0d invalid_sticky=%0d reset=%0d",
                          opcode_counts[0], opcode_counts[1],
                          opcode_counts[2], opcode_counts[3],
                          clear_count, occupancy_counts[0],
                          occupancy_counts[1], occupancy_counts[2],
                          occupancy_counts[3], occupancy_counts[4],
                          req_backpressure_count, rsp_backpressure_count,
                          push_count, pop_count, simultaneous_count,
                          sticky_overflow_count, sticky_invalid_count,
                          reset_count),
                UVM_LOW)
  endfunction
endclass
