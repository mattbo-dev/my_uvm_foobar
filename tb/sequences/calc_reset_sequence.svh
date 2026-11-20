class calc_reset_sequence extends calc_base_sequence;
  `uvm_object_utils(calc_reset_sequence)
  function new(string name = "calc_reset_sequence");
      super.new(name);
  endfunction

  task body();
      vif.rst_n = 1'b0;
      repeat (2) @(posedge vif.clk);
      vif.rst_n = 1'b1;
      repeat (2) @(posedge vif.clk);

      send_request(CALC_ADD, 8'h20, 8'h30, 0, 0, 8);
      send_request(CALC_MUL, 8'h10, 8'h10, 0, 0, 8);

      vif.rst_n = 1'b0;
      repeat (2) @(posedge vif.clk);
      vif.rst_n = 1'b1;
      repeat (2) @(posedge vif.clk);
      send_request(CALC_SUB, 8'h01, 8'h02, 0, 0, 1);
  endtask
endclass
