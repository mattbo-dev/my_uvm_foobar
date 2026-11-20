class calc_env extends uvm_env;
  calc_agent agent;
  calc_scoreboard scoreboard;
  calc_coverage coverage;

  `uvm_component_utils(calc_env)

  function new(string name, uvm_component parent);
      super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agent = calc_agent::type_id::create("agent", this);
      scoreboard = calc_scoreboard::type_id::create("scoreboard", this);
      coverage = calc_coverage::type_id::create("coverage", this);
  endfunction

  function void connect_phase(uvm_phase phase);
      agent.monitor.accepted_port.connect(scoreboard.observation_imp);
      agent.monitor.response_port.connect(scoreboard.observation_imp);
      agent.monitor.status_port.connect(scoreboard.observation_imp);
      agent.monitor.status_port.connect(coverage.analysis_export);
      agent.monitor.event_port.connect(scoreboard.observation_imp);
      agent.monitor.accepted_port.connect(coverage.analysis_export);
      agent.monitor.event_port.connect(coverage.analysis_export);
  endfunction
endclass
