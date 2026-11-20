class calc_all_test extends calc_base_test;
  `uvm_component_utils(calc_all_test)
  function new(string name = "calc_all_test", uvm_component parent = null);
      super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
      calc_directed_sequence directed;
      calc_backpressure_sequence backpressure;
      calc_reset_sequence reset_seq;
      calc_random_sequence random_seq;
      phase.raise_objection(this);
      directed = calc_directed_sequence::type_id::create("directed");
      directed.start(env.agent.sequencer);
      drain_responses(100);
      backpressure = calc_backpressure_sequence::type_id::create("backpressure");
      backpressure.start(env.agent.sequencer);
      drain_responses(100);
      reset_seq = calc_reset_sequence::type_id::create("reset_seq");
      reset_seq.start(env.agent.sequencer);
      drain_responses(100);
      random_seq = calc_random_sequence::type_id::create("random_seq");
      random_seq.start(env.agent.sequencer);
      drain_responses();
      `uvm_info("TEST_SUMMARY", "CALC_TEST_COMPLETE all PASS", UVM_LOW)
      phase.drop_objection(this);
  endtask
endclass
