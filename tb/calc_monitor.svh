class calc_monitor extends uvm_monitor;
  virtual calc_if vif;
  uvm_analysis_port #(calc_observation) accepted_port;
  uvm_analysis_port #(calc_observation) response_port;
  uvm_analysis_port #(calc_observation) status_port;
  uvm_analysis_port #(calc_observation) event_port;
  int unsigned cycle_number;

  `uvm_component_utils(calc_monitor)

  function new(string name, uvm_component parent);
      super.new(name, parent);
      accepted_port = new("accepted_port", this);
      response_port = new("response_port", this);
      status_port = new("status_port", this);
      event_port = new("event_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db #(virtual calc_if)::get(this, "", "vif", vif))
          `uvm_fatal("NOVIF", "calc_monitor virtual interface was not configured")
  endfunction

  task run_phase(uvm_phase phase);
      bit last_reset;
      last_reset = 1'b0;
      forever begin
          @(posedge vif.clk);
          begin
              bit reset_active;
              bit accepted;
              bit request_bp;
              bit consumed;
              bit response_bp;
              bit clear_now;
              bit push_now;
              bit pop_now;
              calc_opcode_t accepted_opcode;
              logic [7:0] accepted_a;
              logic [7:0] accepted_b;
              logic [15:0] consumed_result;

              reset_active = !vif.rst_n;
              accepted = vif.req_valid && vif.req_ready;
              request_bp = vif.req_valid && !vif.req_ready;
              consumed = vif.rsp_valid && vif.rsp_ready;
              response_bp = vif.rsp_valid && !vif.rsp_ready;
              clear_now = vif.clear_status;
              push_now = accepted && (vif.opcode != CALC_INVALID);
              pop_now = consumed;
              accepted_opcode = vif.opcode;
              accepted_a = vif.operand_a;
              accepted_b = vif.operand_b;
              consumed_result = vif.rsp_result;

              if (reset_active) begin
                  if (!last_reset) begin
                      calc_observation obs;
                      #1step;
                      obs = new("reset_observation");
                      obs.kind = CALC_RESET_EVENT;
                      obs.reset_event = 1'b1;
                      obs.status = vif.status_register;
                      event_port.write(obs);
                  end
                  last_reset = 1'b1;
                  continue;
              end
              last_reset = 1'b0;

              if (accepted) begin
                  calc_observation req_obs;
                  req_obs = new("accepted_request");
                  req_obs.kind = CALC_REQ_ACCEPTED;
                  req_obs.opcode = accepted_opcode;
                  req_obs.operand_a = accepted_a;
                  req_obs.operand_b = accepted_b;
                  req_obs.clear_status = clear_now;
                  accepted_port.write(req_obs);
              end

              if (request_bp) begin
                  calc_observation bp;
                  bp = new("request_backpressure");
                  bp.kind = CALC_REQ_BACKPRESSURE;
                  bp.backpressure = 1'b1;
                  event_port.write(bp);
              end

              if (consumed) begin
                  calc_observation rsp;
                  rsp = new("consumed_response");
                  rsp.kind = CALC_RESP_CONSUMED;
                  rsp.rsp_result = consumed_result;
                  response_port.write(rsp);
              end

              if (response_bp) begin
                  calc_observation bp;
                  bp = new("response_backpressure");
                  bp.kind = CALC_RESP_BACKPRESSURE;
                  bp.backpressure = 1'b1;
                  event_port.write(bp);
              end

              if (clear_now) begin
                  calc_observation clr;
                  clr = new("clear_status_event");
                  clr.kind = CALC_CLEAR_EVENT;
                  clr.clear_status = 1'b1;
                  event_port.write(clr);
              end

              if (push_now || pop_now) begin
                  calc_observation pp;
                  pp = new("fifo_push_pop");
                  pp.kind = CALC_PUSH_POP_EVENT;
                  pp.push = push_now;
                  pp.pop = pop_now;
                  event_port.write(pp);
              end

              #1step;
              begin
                  calc_observation status_obs;
                  status_obs = new("status_snapshot");
                  status_obs.kind = CALC_STATUS_SNAPSHOT;
                  status_obs.status = vif.status_register;
                  status_port.write(status_obs);
              end
          end
      end
  endtask
endclass
