#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_MODE="${BUILD_MODE:-normal}"
SIM_THREADS="${SIM_THREADS:-4}"
export BUILD_MODE SIM_THREADS

FAILURES=0

"${PROJECT_ROOT}/scripts/build.sh"

run_test() {
    local test_name="$1"
    local seed="$2"
    local transactions="$3"
    if UVM_TEST="${test_name}" SEED="${seed}" NUM_TRANSACTIONS="${transactions}" \
       "${PROJECT_ROOT}/scripts/run.sh"; then
        echo "PASS ${test_name} seed=${seed}"
    else
        echo "FAIL ${test_name} seed=${seed}"
        FAILURES=$((FAILURES + 1))
    fi
}

run_test calc_directed_test 1 100
run_test calc_backpressure_test 42 100
run_test calc_reset_test 42 100
run_test calc_passive_test 42 100
run_test calc_random_test 1 100
run_test calc_random_test 42 150
run_test calc_random_test 2026 200
run_test calc_all_test 42 100

if command -v verilator_coverage >/dev/null 2>&1; then
    mkdir -p "${PROJECT_ROOT}/sim/coverage"
    find "${PROJECT_ROOT}/sim/obj_${BUILD_MODE}_t${SIM_THREADS}" \
        -maxdepth 1 -type f -name 'coverage.dat' -print \
        > "${PROJECT_ROOT}/sim/coverage/coverage_files.txt"
    while IFS= read -r datum; do
        [[ -n "${datum}" ]] && cp "${datum}" "${PROJECT_ROOT}/sim/coverage/"
    done < "${PROJECT_ROOT}/sim/coverage/coverage_files.txt"
fi

if [[ "${FAILURES}" -ne 0 ]]; then
    echo "Regression failed: ${FAILURES} test(s)"
    exit 1
fi

echo "Regression passed"
