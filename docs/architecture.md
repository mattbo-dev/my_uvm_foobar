# Architecture

## Data flow

```text
+----------+   +------------+   +--------+   calc_if   +-----+
| Sequence |->>| Sequencer  |->>| Driver |----------->| DUT |
+----------+   +------------+   +--------+             +-----+
                                                      | rsp
+----------+                                           v
| Monitor  |<------------------------------------------+
+----+-----+
     | accepted/status/response/reset observations
     +-----------------> Scoreboard
     +-----------------> Coverage
```

The agent is active by default. It creates the sequencer, driver, and passive
monitor. Passive mode creates only the monitor.

## Responsibilities

| Component | Responsibility |
|---|---|
| `calc_seq_item` | Stimulus and response-ready/clear/idle intent |
| Sequences | Reusable directed, random, backpressure, invalid, and reset scenarios |
| Sequencer/driver | Request generation and race-free interface driving |
| Monitor | Passive observation of handshakes, status, reset, and protocol events |
| Agent | Bundles sequencer, driver, and monitor in active/passive modes |
| Scoreboard | Independent FIFO/reference prediction and complete status checks |
| Coverage | Functional bins/crosses plus explicit fallback counters |
| Environment | Creates and connects agent, scoreboard, and coverage |

## Request and response flow

The sequence creates a transaction and sends it through the sequencer. The
driver holds request fields stable until `req_valid && req_ready`. The monitor
publishes a fresh accepted-request observation. The DUT executes valid requests
and buffers 16-bit results. A response is consumed when `rsp_valid && rsp_ready`.
