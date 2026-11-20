class calc_driver extends uvm_driver #(calc_seq_item);
  virtual calc_if vif;
  `uvm_component_utils(calc_driver)

  function new(string name, uvm_component parent);
      super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db #(virtual calc_if)::get(this, "", "vif", vif))
          `uvm_fatal("NOVIF", "calc_driver virtual interface was not configured")
  endfunction

  task run_phase(uvm_phase phase);
      calc_seq_item req;

      vif.drv_cb.req_valid <= 1'b0;
      vif.drv_cb.rsp_ready <= 1'b0;
      vif.drv_cb.clear_status <= 1'b0;
      vif.drv_cb.opcode <= CALC_ADD;
      vif.drv_cb.operand_a <= '0;
      vif.drv_cb.operand_b <= '0;

      forever begin
          seq_item_port.get_next_item(req);

          repeat (req.idle_cycles) begin
              vif.drv_cb.req_valid <= 1'b0;
              vif.drv_cb.rsp_ready <= 1'b1;
              vif.drv_cb.clear_status <= 1'b0;
              @(vif.drv_cb);
          end

          if (req.rsp_ready_delay > 0) begin
              vif.drv_cb.rsp_ready <= 1'b0;
              repeat (req.rsp_ready_delay)
                  @(vif.drv_cb);
          end
          vif.drv_cb.rsp_ready <= 1'b1;

          vif.drv_cb.opcode <= req.opcode;
          vif.drv_cb.operand_a <= req.operand_a;
          vif.drv_cb.operand_b <= req.operand_b;
          vif.drv_cb.req_valid <= 1'b1;
          vif.drv_cb.clear_status <= req.clear_status;

          forever begin
              @(vif.drv_cb);
              if (vif.drv_cb.req_ready)
                  break;
          end

          vif.drv_cb.req_valid <= 1'b0;
          vif.drv_cb.clear_status <= 1'b0;

          seq_item_port.item_done();
      end
  endtask
endclass
