class calc_backpressure_sequence extends calc_base_sequence;
  `uvm_object_utils(calc_backpressure_sequence)
  function new(string name = "calc_backpressure_sequence");
      super.new(name);
  endfunction

  task body();
      repeat (4) send_calc_request(CALC_ADD, 8'h10, 8'h01, 0, 0, 8);
      send_calc_request(CALC_INVALID, 8'hff, 8'hff, 0, 0, 2);
      repeat (4) send_calc_request(CALC_MUL, 8'h10, 8'h10, 0, 0, 0);
  endtask
endclass
