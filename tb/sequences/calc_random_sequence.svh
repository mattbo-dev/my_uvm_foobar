class calc_random_sequence extends calc_base_sequence;
  int unsigned num_transactions;
  int unsigned seed;
  `uvm_object_utils(calc_random_sequence)

  function new(string name = "calc_random_sequence");
      super.new(name);
  endfunction

  function int unsigned next_random();
      seed = seed * 32'h08088405 + 32'h5d1e3b9f;
      return seed;
  endfunction

  function int unsigned between(int unsigned lo, int unsigned hi);
      if (hi == lo) return lo;
      return lo + (next_random() % (hi - lo + 1));
  endfunction

  task body();
      int n;
      $value$plusargs("NUM_TRANSACTIONS=%d", num_transactions);
      $value$plusargs("SEED=%d", seed);
      if (num_transactions == 0) num_transactions = 100;
      if (seed == 0) seed = 42;
      n = num_transactions;
      repeat (n) begin
          calc_seq_item req;
          int op_sel;
          op_sel = between(0, 9);
          req = calc_seq_item::type_id::create("random_req");
          if (op_sel < 3) req.opcode = CALC_ADD;
          else if (op_sel < 6) req.opcode = CALC_SUB;
          else if (op_sel < 8) req.opcode = CALC_MUL;
          else req.opcode = CALC_INVALID;
          case (between(0, 7))
              0: req.operand_a = 8'h00;
              1: req.operand_a = 8'hff;
              2: req.operand_a = 8'h7f;
              default: req.operand_a = between(0, 255);
          endcase
          case (between(0, 7))
              0: req.operand_b = 8'h00;
              1: req.operand_b = 8'hff;
              2: req.operand_b = req.operand_a;
              default: req.operand_b = between(0, 255);
          endcase
          req.idle_cycles = between(0, 5);
          req.rsp_ready_delay = between(0, 8);
          req.clear_status = (between(0, 19) == 0);
          req.transaction_number = next_transaction_number++;
          start_item(req);
          finish_item(req);
      end
  endtask
endclass
