package my_uvm_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  class my_test extends uvm_test;

    `uvm_component_utils(my_test)

    function new(string name = "my_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
      phase.raise_objection(this);

      `uvm_info("MY_TEST", "UVM test started successfully", UVM_MEDIUM)

      #100ns;

      `uvm_info("MY_TEST", "UVM test completed successfully", UVM_MEDIUM)

      phase.drop_objection(this);
    endtask

  endclass

endpackage
