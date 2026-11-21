# my_uvm_foobar

A working Verilator/UVM 2020-3.2 example implementing an educational, synthesizable
buffered calculator. It replaces a smoke test with an independent scoreboard,
functional coverage, protocol assertions, directed/random/reset sequences, and
repeatable scripts.

## Features

- Synchronous-active-low reset and four-entry result FIFO
- Typed packed opcode and 32-bit status register
- UVM agent, monitor, sequencer, driver, scoreboard, coverage, and environment
- Directed, random, backpressure, invalid, reset, passive-agent, and combined tests
- Verilator binary build, FST tracing, structural coverage, and WSL VS Code tasks

## DUT and UVM overview

```text
Sequence -> Sequencer -> Driver -> calc_if -> DUT FIFO -> Monitor
                                            |           |
                                            +-> rsp/data+-> Scoreboard
                                            +-> status  -> Coverage
```

The request interface carries `opcode`, `operand_a`, `operand_b`, and handshakes.
Responses are consumed oldest-first. The status register exposes last result,
FIFO occupancy, sticky invalid/overflow flags, and reserved bits.

## Prerequisites

- WSL2 Ubuntu
- Verilator 5.054
- UVM Verilator distribution at `$HOME/tools/uvm-verilator/src`
- GTKWave
- Sigasi Visual HDL and VS Code WSL integration

## Quick start

```bash
CLEAN_BUILD=1 BUILD_MODE=normal SIM_THREADS=4 ./scripts/build.sh
UVM_TEST=calc_directed_test ./scripts/run.sh
UVM_TEST=calc_random_test SEED=42 NUM_TRANSACTIONS=100 ./scripts/run.sh
./scripts/regression.sh
./scripts/coverage_report.sh
```

Build and simulation output is under `sim/`, including `obj_normal_t4/`,
`logs/`, `waves.fst`, and `coverage/`.

## Documentation

- [Architecture](docs/architecture.md)
- [DUT protocol](docs/dut_protocol.md)
- [UVM walkthrough](docs/uvm_walkthrough.md)
- [Status register](docs/status_register.md)
- [Coverage and assertions](docs/coverage_and_assertions.md)
- [Build and run](docs/build_and_run.md)
- [Extending the testbench](docs/extending_the_testbench.md)
- [Verilator compatibility](docs/verilator_compatibility.md)
