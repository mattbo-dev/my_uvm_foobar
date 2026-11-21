# Build and Run

## Commands

```bash
bash -n scripts/build.sh
bash -n scripts/run.sh
bash -n scripts/regression.sh
bash -n scripts/coverage_report.sh

CLEAN_BUILD=1 BUILD_MODE=normal SIM_THREADS=4 ./scripts/build.sh
UVM_TEST=calc_directed_test ./scripts/run.sh
UVM_TEST=calc_random_test SEED=42 NUM_TRANSACTIONS=100 ./scripts/run.sh
UVM_TEST=calc_random_test SEED=2026 NUM_TRANSACTIONS=150 ./scripts/run.sh
UVM_TEST=calc_backpressure_test ./scripts/run.sh
UVM_TEST=calc_reset_test ./scripts/run.sh
UVM_TEST=calc_passive_test ./scripts/run.sh
UVM_TEST=calc_all_test ./scripts/run.sh
./scripts/regression.sh
./scripts/coverage_report.sh
```

## Environment

- `BUILD_MODE`: `fast`, `normal`, or `release`
- `SIM_THREADS`: generated model thread count
- `CLEAN_BUILD=1`: remove only the selected build directory
- `UVM_TEST`: test name
- `SEED`: deterministic random seed
- `NUM_TRANSACTIONS`: random transaction count
- `UVM_VERBOSITY`: UVM verbosity
- `WAVES=0`: disable FST dumping

`UVM_HOME` defaults to `$HOME/tools/uvm-verilator/src`.

## Logs and waves

- Executable: `sim/obj_<mode>_t<threads>/Vtb_top`
- Build log: `sim/logs/build_<mode>_t<threads>.log`
- Simulation log: `sim/<test>_seed<seed>_<mode>_t<threads>.log`
- Waveform: `sim/waves.fst`
- Structural coverage: `sim/coverage/`

Scripts use `tee` and `pipefail`, and simulation logs are checked for UVM
errors, fatal assertions, the scoreboard completion marker, and timeout.
