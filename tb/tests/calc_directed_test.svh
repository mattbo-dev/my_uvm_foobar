class calc_directed_test extends calc_base_test;
  `uvm_component_utils(calc_directed_test)
  function new(string name = "calc_directed_test", uvm_component parent = null);
      super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
      calc_directed_sequence seq;
      calc_invalid_sequence invalid_seq;
      phase.raise_objection(this);
      seq = calc_directed_sequence::type_id::create("seq");
      seq.start(env.agent.sequencer);
      drain_responses();
      invalid_seq = calc_invalid_sequence::type_id::create("invalid_seq");
      invalid_seq.start(env.agent.sequencer);
      drain_responses();
      `uvm_info("TEST_SUMMARY", "CALC_TEST_COMPLETE directed PASS", UVM_LOW)
      phase.drop_objection(this);
  endtask
endclass
