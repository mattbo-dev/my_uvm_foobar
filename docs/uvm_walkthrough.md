# UVM Walkthrough

`calc_seq_item` carries opcode, operands, idle cycles, response-ready delay,
clear-status intent, and a transaction number. Its explicit copy/compare/string
methods keep transactions readable.

Sequences are factory-created and send transactions through
`calc_base_sequence.send_request()`. The sequencer passes transactions to
`calc_driver` through `seq_item_port`.

The driver retrieves a virtual `calc_if` from `uvm_config_db` under `"vif"`,
drives only through the interface, holds request fields stable, and waits for
the request handshake before completing the item.

The monitor is passive. It captures handshakes at the rising edge and status
after NBA updates. It publishes fresh observation objects for accepted requests,
consumed responses, status snapshots, reset, backpressure, clear, and push/pop.

The agent creates a monitor always and driver/sequencer only in active mode.
The environment connects monitor ports to the independent scoreboard and coverage.

The scoreboard maintains its own FIFO and sticky model. It does not use DUT
signals. It checks response values, status fields, queue drainage, reset,
unexpected responses, and invalid behavior.

Tests raise objections during `run_phase`, start sequences, drain responses,
and drop objections. `calc_all_test` starts compatible sequences serially.
