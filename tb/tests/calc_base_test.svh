class calc_base_test extends uvm_test;
  calc_env env;
  `uvm_component_utils(calc_base_test)
  function new(string name = "calc_base_test", uvm_component parent = null);
      super.new(name, parent);
  endfunction
  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = calc_env::type_id::create("env", this);
      uvm_config_db #(uvm_active_passive_enum)::set(this, "env.agent",
                                                    "is_active", UVM_ACTIVE);
  endfunction
  task drain_responses(int unsigned cycles = 300);
      virtual calc_if vif;
      if (!uvm_config_db #(virtual calc_if)::get(this, "", "vif", vif))
          `uvm_fatal("NOVIF", "base test virtual interface was not configured")
      repeat (cycles) begin
          @(posedge vif.clk);
          vif.rsp_ready <= 1'b1;
      end
  endtask
endclass
