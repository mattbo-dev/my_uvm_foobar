class calc_scoreboard extends uvm_scoreboard;
  uvm_analysis_imp #(calc_observation, calc_scoreboard) observation_imp;

  logic [15:0] expected_fifo [0:3];
  logic [1:0] expected_read_ptr;
  logic [1:0] expected_write_ptr;
  logic [2:0] expected_count;
  logic [15:0] expected_last_result;
  bit expected_overflow;
  bit expected_invalid;

  int accepted_valid;
  int accepted_invalid;
  int expected_responses;
  int consumed_responses;
  int status_checks;
  int passed_comparisons;
  int failed_comparisons;
  int reset_events;
  int clear_events;
  int reset_suppress_cycles;

  `uvm_component_utils(calc_scoreboard)

  function new(string name, uvm_component parent);
      super.new(name, parent);
      observation_imp = new("observation_imp", this);
      reset_model();
  endfunction

  function void write(calc_observation obs);
      case (obs.kind)
          CALC_REQ_ACCEPTED: write_req(obs);
          CALC_RESP_CONSUMED: write_rsp(obs);
          CALC_STATUS_SNAPSHOT: write_status(obs);
          CALC_RESET_EVENT,
          CALC_CLEAR_EVENT,
          CALC_PUSH_POP_EVENT,
          CALC_REQ_BACKPRESSURE,
          CALC_RESP_BACKPRESSURE: write_event(obs);
          default:
              // Unknown opcodes are handled as invalid requests.
              begin end
      endcase
  endfunction

  function void reset_model();
      expected_read_ptr = '0;
      expected_write_ptr = '0;
      expected_count = '0;
      expected_last_result = '0;
      expected_overflow = 1'b0;
      expected_invalid = 1'b0;
      for (int i = 0; i < 4; i++)
          expected_fifo[i] = '0;
  endfunction

  function void write_req(calc_observation obs);
      logic [15:0] result;
      logic [16:0] wide_sum;
      logic [15:0] wide_product;
      bit overflow;
      overflow = 1'b0;
      result = '0;
      if (obs.opcode == CALC_INVALID) begin
          accepted_invalid++;
          expected_invalid = 1'b1;
          return;
      end

      accepted_valid++;
      case (obs.opcode)
          CALC_ADD: begin
              wide_sum = {9'b0, obs.operand_a} + {9'b0, obs.operand_b};
              result = wide_sum[15:0];
              if (wide_sum > 255)
                  overflow = 1'b1;
          end
          CALC_SUB: begin
              result = obs.operand_a - obs.operand_b;
              if (obs.operand_a < obs.operand_b)
                  overflow = 1'b1;
          end
          CALC_MUL: begin
              wide_product = {8'b0, obs.operand_a} * {8'b0, obs.operand_b};
              result = wide_product;
              if (wide_product > 255)
                  overflow = 1'b1;
          end
          default:
              // Unknown opcode values do not enqueue a result.
              begin end
      endcase

      if (overflow)
          expected_overflow = 1'b1;
      expected_fifo[expected_write_ptr] = result;
      expected_write_ptr =
          (expected_write_ptr == 3) ? 2'b00 : expected_write_ptr + 1'b1;
      expected_last_result = result;
      expected_responses++;
  endfunction

  function void write_rsp(calc_observation obs);
      logic [15:0] expected;
      if (expected_count == 0) begin
          failed_comparisons++;
          `uvm_error("SB_UNEXPECTED_RESPONSE",
                     $sformatf("Unexpected response 0x%04h; expected queue empty",
                               obs.rsp_result))
          return;
      end
      expected = expected_fifo[expected_read_ptr];
      consumed_responses++;
      if (obs.rsp_result !== expected) begin
          failed_comparisons++;
          `uvm_error("SB_RESPONSE",
                     $sformatf("Response mismatch: expected=0x%04h actual=0x%04h",
                               expected, obs.rsp_result))
      end else begin
          passed_comparisons++;
          `uvm_info("SB_RESPONSE",
                    $sformatf("Matched response 0x%04h", expected),
                    UVM_HIGH)
      end
      expected_read_ptr =
          (expected_read_ptr == 3) ? 2'b00 : expected_read_ptr + 1'b1;
  endfunction

  function void write_status(calc_observation obs);
      calc_status_t expected_status;
      if (reset_suppress_cycles > 0) begin
          reset_suppress_cycles--;
          return;
      end
      status_checks++;
      expected_status = '0;
      expected_status.reserved = '0;
      expected_status.invalid_op_sticky = expected_invalid;
      expected_status.overflow_sticky = expected_overflow;
      expected_status.fifo_full = (expected_count == 4);
      expected_status.fifo_empty = (expected_count == 0);
      expected_status.result_count = expected_count;
      expected_status.last_result = expected_last_result;

      if (obs.status.reserved != '0) begin
          failed_comparisons++;
          `uvm_error("SB_RESERVED",
                     $sformatf("reserved expected=0 actual=%03b",
                               obs.status.reserved))
      end
      if (obs.status.invalid_op_sticky !== expected_status.invalid_op_sticky) begin
          failed_comparisons++;
          `uvm_error("SB_STATUS",
                     $sformatf("invalid_op_sticky expected=%0b actual=%0b",
                               expected_status.invalid_op_sticky,
                               obs.status.invalid_op_sticky))
      end
      if (obs.status.overflow_sticky !== expected_status.overflow_sticky) begin
          failed_comparisons++;
          `uvm_error("SB_STATUS",
                     $sformatf("overflow_sticky expected=%0b actual=%0b",
                               expected_status.overflow_sticky,
                               obs.status.overflow_sticky))
      end
      if (obs.status.fifo_full !== expected_status.fifo_full ||
          obs.status.fifo_empty !== expected_status.fifo_empty ||
          obs.status.result_count !== expected_status.result_count ||
          obs.status.last_result !== expected_status.last_result ||
          obs.status.reserved != '0) begin
          failed_comparisons++;
          `uvm_error("SB_STATUS",
                     $sformatf("Status mismatch: expected=0x%08h actual=0x%08h",
                               expected_status, obs.status))
      end else begin
          passed_comparisons++;
      end
  endfunction

  function void write_event(calc_observation obs);
      if (obs.kind == CALC_RESET_EVENT) begin
          reset_events++;
          reset_model();
          reset_suppress_cycles = 100;
          if (obs.status.invalid_op_sticky != 0 ||
              obs.status.overflow_sticky != 0 ||
              obs.status.result_count != 0 ||
              obs.status.last_result != 0 ||
              !obs.status.fifo_empty ||
              obs.status.fifo_full) begin
              failed_comparisons++;
              `uvm_error("SB_RESET_STATUS",
                         $sformatf("Reset status not cleared: 0x%08h",
                                   obs.status))
          end
      end else if (obs.kind == CALC_CLEAR_EVENT) begin
          clear_events++;
          expected_overflow = 1'b0;
          expected_invalid = 1'b0;
      end else if (obs.kind == CALC_PUSH_POP_EVENT) begin
          if (obs.push)
              expected_count = expected_count + 1'b1;
          if (obs.pop)
              expected_count = expected_count - 1'b1;
      end
  endfunction

  function void check_phase(uvm_phase phase);
      if (expected_count != 0) begin
          failed_comparisons++;
          `uvm_error("SB_UNDRAINED",
                     $sformatf("Expected queue still has %0d responses",
                               expected_count))
      end
  endfunction

  function void report_phase(uvm_phase phase);
      string result;
      result = (failed_comparisons == 0) ? "PASS" : "FAIL";
      `uvm_info("SB_SUMMARY",
                $sformatf("%s accepted_valid=%0d accepted_invalid=%0d expected_responses=%0d consumed_responses=%0d status_checks=%0d passed=%0d failed=%0d resets=%0d clears=%0d",
                          result, accepted_valid, accepted_invalid,
                          expected_responses, consumed_responses, status_checks,
                          passed_comparisons, failed_comparisons,
                          reset_events, clear_events),
                UVM_LOW)
      `uvm_info("CALC_SCOREBOARD_COMPLETE",
                $sformatf("CALC_SCOREBOARD_COMPLETE result=%s", result),
                UVM_LOW)
  endfunction
endclass
