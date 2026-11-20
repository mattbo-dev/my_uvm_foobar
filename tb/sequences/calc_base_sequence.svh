class calc_base_sequence extends uvm_sequence #(calc_seq_item);
  virtual calc_if vif;
  int unsigned next_transaction_number;

  `uvm_object_utils(calc_base_sequence)

  function new(string name = "calc_base_sequence");
      super.new(name);
  endfunction

  task pre_body();
      if (!uvm_config_db #(virtual calc_if)::get(m_sequencer, "", "vif", vif))
          `uvm_fatal("NOVIF", "calc_base_sequence virtual interface was not configured")
  endtask

  task send_request(calc_opcode_t op,
                   logic [7:0] a,
                   logic [7:0] b,
                   bit clear_status = 0,
                   int unsigned idle = 1,
                   int unsigned ready_delay = 2);
      calc_seq_item req;
      req = calc_seq_item::type_id::create("req");
      req.opcode = op;
      req.operand_a = a;
      req.operand_b = b;
      req.clear_status = clear_status;
      req.idle_cycles = idle;
      req.rsp_ready_delay = ready_delay;
      req.transaction_number = next_transaction_number++;
      start_item(req);
      finish_item(req);
  endtask
endclass
