class calc_directed_sequence extends calc_base_sequence;
  `uvm_object_utils(calc_directed_sequence)

  function new(string name = "calc_directed_sequence");
      super.new(name);
  endfunction

  task body();
      send_calc_request(CALC_ADD, 8'd10, 8'd20);
      send_calc_request(CALC_ADD, 8'd200, 8'd100);
      send_clear_only();
      send_calc_request(CALC_SUB, 8'd200, 8'd50);
      send_calc_request(CALC_SUB, 8'd20, 8'd30);
      send_calc_request(CALC_MUL, 8'd20, 8'd10);
      send_calc_request(CALC_MUL, 8'd16, 8'd16);
      send_calc_request(CALC_ADD, 8'h00, 8'h00);
      send_calc_request(CALC_ADD, 8'hff, 8'hff);
      send_calc_request(CALC_ADD, 8'h7f, 8'h7f);
      send_calc_request(CALC_INVALID, 8'h12, 8'h34);
      send_calc_request(CALC_ADD, 8'h01, 8'h02, 1'b1);

      repeat (4) send_calc_request(CALC_ADD, 8'h10, 8'h20, 1'b0, 0, 8);
      repeat (4) send_calc_request(CALC_ADD, 8'h30, 8'h40, 1'b0, 0, 0);
      send_calc_request(CALC_INVALID, 8'hff, 8'hff, 1'b0, 0, 2);
  endtask
endclass
