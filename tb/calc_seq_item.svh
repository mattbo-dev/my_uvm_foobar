class calc_seq_item extends uvm_sequence_item;
  rand calc_opcode_t opcode;
  rand logic [7:0] operand_a;
  rand logic [7:0] operand_b;
  rand int unsigned idle_cycles;
  rand int unsigned rsp_ready_delay;
  rand bit clear_status;
  int unsigned transaction_number;

  constraint modest_delays {
      idle_cycles <= 8;
      rsp_ready_delay <= 8;
  }

  `uvm_object_utils(calc_seq_item)

  function new(string name = "calc_seq_item");
      super.new(name);
  endfunction

  function void do_copy(uvm_object rhs);
      calc_seq_item rhs_t;
      if (!$cast(rhs_t, rhs))
          `uvm_fatal("COPY", "calc_seq_item copy type mismatch")
      super.do_copy(rhs);
      opcode = rhs_t.opcode;
      operand_a = rhs_t.operand_a;
      operand_b = rhs_t.operand_b;
      idle_cycles = rhs_t.idle_cycles;
      rsp_ready_delay = rhs_t.rsp_ready_delay;
      clear_status = rhs_t.clear_status;
      transaction_number = rhs_t.transaction_number;
  endfunction

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
      calc_seq_item rhs_t;
      if (!$cast(rhs_t, rhs)) return 0;
      return super.do_compare(rhs, comparer) &&
             opcode == rhs_t.opcode &&
             operand_a == rhs_t.operand_a &&
             operand_b == rhs_t.operand_b &&
             idle_cycles == rhs_t.idle_cycles &&
             rsp_ready_delay == rhs_t.rsp_ready_delay &&
             clear_status == rhs_t.clear_status &&
             transaction_number == rhs_t.transaction_number;
  endfunction

  function string convert2string();
      return $sformatf("tx=%0d op=%s a=0x%02h b=0x%02h idle=%0d ready_delay=%0d clear=%0b",
                       transaction_number, opcode.name(), operand_a, operand_b,
                       idle_cycles, rsp_ready_delay, clear_status);
  endfunction
endclass
