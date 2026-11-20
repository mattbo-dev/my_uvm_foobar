class calc_random_test extends calc_base_test;
  `uvm_component_utils(calc_random_test)
  function new(string name = "calc_random_test", uvm_component parent = null);
      super.new(name, parent);
  endfunction
  task run_phase(uvm_phase phase);
      calc_random_sequence seq;
      int unsigned n;
      int unsigned seed;
      n = 0;
      seed = 42;
      void'($value$plusargs("NUM_TRANSACTIONS=%d", n));
      void'($value$plusargs("SEED=%d", seed));
      if (n < 100) n = 100;
      phase.raise_objection(this);
      seq = calc_random_sequence::type_id::create("seq");
      seq.start(env.agent.sequencer);
      drain_responses();
      `uvm_info("TEST_SUMMARY",
                $sformatf("CALC_TEST_COMPLETE random PASS seed=%0d transactions=%0d", seed, n),
                UVM_LOW)
      phase.drop_objection(this);
  endtask
endclass
