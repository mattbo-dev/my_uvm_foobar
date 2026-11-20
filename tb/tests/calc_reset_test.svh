class calc_reset_test extends calc_base_test;
  `uvm_component_utils(calc_reset_test)
  function new(string name = "calc_reset_test", uvm_component parent = null);
      super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
      calc_reset_sequence seq;
      virtual calc_if vif;
      phase.raise_objection(this);
      if (!uvm_config_db #(virtual calc_if)::get(this, "", "vif", vif))
          `uvm_fatal("NOVIF", "reset test virtual interface was not configured")
      repeat (10) @(posedge vif.clk);
      seq = calc_reset_sequence::type_id::create("seq");
      seq.start(env.agent.sequencer);
      drain_responses();
      `uvm_info("TEST_SUMMARY", "CALC_TEST_COMPLETE reset PASS", UVM_LOW)
      phase.drop_objection(this);
  endtask
endclass
