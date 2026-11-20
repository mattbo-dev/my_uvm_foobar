# Status Register

```systemverilog
typedef struct packed {
    logic [8:0]  reserved;          // status_register[31:23]
    logic        invalid_op_sticky; // status_register[22]
    logic        overflow_sticky;   // status_register[21]
    logic        fifo_full;         // status_register[20]
    logic        fifo_empty;        // status_register[19]
    logic [2:0]  result_count;      // status_register[18:16]
    logic [15:0] last_result;       // status_register[15:0]
} calc_status_t;
```

## Field mapping

| Field | Bits | Meaning |
|---|---:|---|
| `reserved` | 31:23 | Always zero |
| `invalid_op_sticky` | 22 | Sticky invalid-operation event |
| `overflow_sticky` | 21 | Sticky add/mul overflow or sub underflow |
| `fifo_full` | 20 | Occupancy is four |
| `fifo_empty` | 19 | Occupancy is zero |
| `result_count` | 18:16 | Current occupancy |
| `last_result` | 15:0 | Last accepted valid calculation result |

The struct is exactly 32 bits. Named access is used throughout:

```systemverilog
status.reserved
status.invalid_op_sticky
status.overflow_sticky
status.fifo_full
status.fifo_empty
status.result_count
status.last_result
```

## Observed GTKWave hierarchy

A fresh Verilator 5.054 FST was converted successfully. The exact hierarchy
includes:

```text
tb_top
  dut_inst
    status_register
      reserved
      invalid_op_sticky
      overflow_sticky
      fifo_full
      fifo_empty
      result_count
      last_result
```

Open `sim/waves.fst` in GTKWave and expand `tb_top -> dut_inst ->
status_register`. The same struct also appears as a 32-bit signal under
`dut_inst.status_register`.
