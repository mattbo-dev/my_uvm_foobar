# Extending the Testbench

## Add an opcode

Extend `calc_opcode_t`, DUT decode/result logic, scoreboard prediction,
coverage bins, directed sequences, and assertions. Keep encoding values explicit.

## Add a sequence or test

Create a sequence under `tb/sequences/`, include it in `tb/calc_pkg.sv`, then
register and start it in a test under `tb/tests/`.

## Add coverage

Add explicit fallback counters and a modest coverpoint/bin or cross. Keep
coverage separate from scoreboard comparison.

## Add status fields

Extend `calc_status_t` while preserving exact bit order and 32-bit width.
Update named RTL/status assignments, scoreboard checks, assertions, FST docs,
and any coverage bins.

## Change FIFO depth

Update the DUT parameter and status `result_count` width assumptions. Update
occupancy coverage and scoreboard arrays. The current fixed four-entry example
is intentionally educational.

## Passive mode and future extensions

Set the agent passive to instantiate only the monitor. A future second agent
can publish a config object and independent virtual interface. A bus or RAL
model can be added as another monitor/adapter pair while retaining the current
calculator protocol as the reference.
