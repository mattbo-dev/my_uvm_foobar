class calc_reset_sequence extends calc_base_sequence;
  `uvm_object_utils(calc_reset_sequence)
  function new(string name = "calc_reset_sequence");
      super.new(name);
  endfunction

  task body();
      vif.drive_reset(2);

      send_calc_request(CALC_ADD, 8'h20, 8'h30, 0, 0, 8);
      send_calc_request(CALC_MUL, 8'h10, 8'h10, 0, 0, 8);

      vif.drive_reset(2);
      send_calc_request(CALC_SUB, 8'h01, 8'h02, 0, 0, 1);
  endtask
endclass
