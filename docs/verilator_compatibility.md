# Verilator Compatibility

## Installed toolchain

- Verilator 5.054
- UVM 2020-3.2 Verilator-compatible distribution
- GTKWave 3.3.126
- `+define+UVM_NO_DPI`

## Choices and substitutions

- Package bodies do not contain `$bits` runtime initializers; module/top-level
  elaboration checks verify the 32-bit status and 2-bit opcode widths.
- Random stimulus uses a deterministic software LCG seeded from `SEED` plusarg
  rather than constrained-random solver features.
- `$past` stability expressions were replaced by procedural hold-state checks
  for reliable Verilator execution.
- Coverage uses a small covergroup plus explicit fallback counters.
- The monitor captures handshakes at rising edge and status after NBA updates.
- The scoreboard uses widened arithmetic to match DUT mathematical overflow.

## Remaining warnings

The build may report UVM NO_DPI informational/warning IDs and width or unused
signal warnings. They are not converted to fatal except by existing
`-Wno-fatal`.

## Deferred features

Large randomized bin sets, advanced temporal assertions, external
constraint solvers, RAL, a second agent, and a formal bus model remain future
learning exercises rather than silent compatibility substitutions.
