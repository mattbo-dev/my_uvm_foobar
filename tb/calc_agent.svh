class calc_agent extends uvm_agent;
  calc_sequencer sequencer;
  calc_driver driver;
  calc_monitor monitor;

  `uvm_component_utils(calc_agent)

  function new(string name, uvm_component parent);
      super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      monitor = calc_monitor::type_id::create("monitor", this);
      if (get_is_active()) begin
          sequencer = calc_sequencer::type_id::create("sequencer", this);
          driver = calc_driver::type_id::create("driver", this);
      end
  endfunction

  function void connect_phase(uvm_phase phase);
      if (get_is_active())
          driver.seq_item_port.connect(sequencer.seq_item_export);
  endfunction
endclass
