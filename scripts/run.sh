#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOP_MODULE="${TOP_MODULE:-tb_top}"
SIM_THREADS="${SIM_THREADS:-4}"
BUILD_MODE="${BUILD_MODE:-normal}"
UVM_TEST="${UVM_TEST:-my_test}"
UVM_VERBOSITY="${UVM_VERBOSITY:-UVM_MEDIUM}"
LOG_FILE="${PROJECT_ROOT}/sim/${UVM_TEST}_${BUILD_MODE}_t${SIM_THREADS}.log"

BUILD_DIR="${PROJECT_ROOT}/sim/obj_${BUILD_MODE}_t${SIM_THREADS}"
EXECUTABLE="${BUILD_DIR}/V${TOP_MODULE}"

if [[ ! -x "${EXECUTABLE}" ]]; then
    echo "ERROR: Simulation executable does not exist:"
    echo "  ${EXECUTABLE}"
    echo
    echo "Build it first with:"
    echo "  BUILD_MODE=${BUILD_MODE} SIM_THREADS=${SIM_THREADS} ./scripts/build.sh"
    exit 1
fi

cd "${PROJECT_ROOT}/sim"

echo "Running ${EXECUTABLE}"
echo "UVM test:      ${UVM_TEST}"
echo "UVM verbosity: ${UVM_VERBOSITY}"

"${EXECUTABLE}" \
    "+UVM_TESTNAME=${UVM_TEST}" \
    "+UVM_VERBOSITY=${UVM_VERBOSITY}" \
    2>&1 | tee "${LOG_FILE}"

echo
echo "Simulation log saved to:"