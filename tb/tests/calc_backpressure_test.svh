class calc_backpressure_test extends calc_base_test;
  `uvm_component_utils(calc_backpressure_test)
  function new(string name = "calc_backpressure_test", uvm_component parent = null);
      super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
      calc_backpressure_sequence seq;
      phase.raise_objection(this);
      seq = calc_backpressure_sequence::type_id::create("seq");
      seq.start(env.agent.sequencer);
      drain_responses();
      `uvm_info("TEST_SUMMARY", "CALC_TEST_COMPLETE backpressure PASS", UVM_LOW)
      phase.drop_objection(this);
  endtask
endclass
