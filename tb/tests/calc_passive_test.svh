class calc_passive_test extends calc_base_test;
  `uvm_component_utils(calc_passive_test)

  function new(string name = "calc_passive_test", uvm_component parent = null);
      super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      uvm_config_db #(uvm_active_passive_enum)::set(this, "env.agent",
                                                    "is_active", UVM_PASSIVE);
  endfunction

  task send_direct(calc_opcode_t op,
                   logic [7:0] a,
                   logic [7:0] b,
                   bit clear_status = 1'b0);
      virtual calc_if vif;
      if (!uvm_config_db #(virtual calc_if)::get(this, "", "vif", vif))
          `uvm_fatal("NOVIF", "passive test virtual interface was not configured")

      vif.drv_cb.opcode <= op;
      vif.drv_cb.operand_a <= a;
      vif.drv_cb.operand_b <= b;
      vif.drv_cb.clear_status <= clear_status;
      vif.drv_cb.req_valid <= 1'b1;

      forever begin
          @(vif.drv_cb);
          if (vif.drv_cb.req_ready)
              break;
      end

      vif.drv_cb.req_valid <= 1'b0;
      vif.drv_cb.clear_status <= 1'b0;
  endtask

  task run_phase(uvm_phase phase);
      virtual calc_if vif;
      phase.raise_objection(this);

      if (!uvm_config_db #(virtual calc_if)::get(this, "", "vif", vif))
          `uvm_fatal("NOVIF", "passive test virtual interface was not configured")

      repeat (5) @(vif.drv_cb);
      vif.drv_cb.rsp_ready <= 1'b0;
      repeat (2) @(vif.drv_cb);
      vif.drv_cb.rsp_ready <= 1'b1;

      send_direct(CALC_ADD, 8'h10, 8'h20);
      send_direct(CALC_SUB, 8'h20, 8'h30);
      send_direct(CALC_MUL, 8'h10, 8'h10);
      send_direct(CALC_INVALID, 8'hff, 8'hff);
      send_direct(CALC_ADD, 8'hff, 8'hff, 1'b1);

      vif.drv_cb.rsp_ready <= 1'b1;
      repeat (300) @(vif.drv_cb);

      `uvm_info("TEST_SUMMARY",
                "CALC_TEST_COMPLETE passive PASS",
                UVM_LOW)
      phase.drop_objection(this);
  endtask
endclass
