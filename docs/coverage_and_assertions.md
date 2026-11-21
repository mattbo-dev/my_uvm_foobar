# Coverage and Assertions

## Functional coverage

The coverage subscriber counts opcode values, clear status, occupancy, sticky
bits, backpressure, push/pop, simultaneous push/pop, and reset. It also defines
a Verilator-compatible covergroup for opcodes, occupancy, overflow sticky, and
invalid sticky.

The fallback counters additionally report zero/maximum/equal operands,
ADD-overflow, SUB-underflow, MUL-overflow, and empty-to-nonempty,
nonfull-to-full, and full-to-nonfull transitions.

Because some advanced cross and operand-category constructs differ across
Verilator distributions, explicit fallback counters preserve coverage intent.
The report prints fallback counts at test completion.

## Structural coverage

The build enables Verilator line, branch, expression, FSM, and toggle-related
coverage facilities. Run:

```bash
./scripts/coverage_report.sh
```

Outputs are:

- `sim/coverage/summary.txt`
- `sim/coverage/merged.dat`
- `sim/coverage/annotated/`

Functional percentages and structural percentages measure different things and
should not be combined.

## Assertions

The interface and top-level checks cover stable request fields, stable response
result, FIFO occupancy, empty/full exclusivity, reserved bits, and response
handshakes. Unsupported timing expressions were replaced with procedural
hold-state checks while preserving intent.
