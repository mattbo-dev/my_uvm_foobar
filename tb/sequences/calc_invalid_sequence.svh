class calc_invalid_sequence extends calc_base_sequence;
  `uvm_object_utils(calc_invalid_sequence)
  function new(string name = "calc_invalid_sequence");
      super.new(name);
  endfunction
  task body();
      send_request(CALC_INVALID, 8'h10, 8'h20, 0, 0, 1);
      repeat (2) send_request(CALC_ADD, 8'h10, 8'h20, 0, 0, 2);
      send_request(CALC_INVALID, 8'h40, 8'h80, 0, 0, 2);
      repeat (2) send_request(CALC_ADD, 8'h10, 8'h20, 0, 0, 8);
      send_request(CALC_INVALID, 8'hff, 8'hff, 0, 0, 1);
  endtask
endclass
