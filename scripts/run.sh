#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOP_MODULE="${TOP_MODULE:-tb_top}"
SIM_THREADS="${SIM_THREADS:-4}"
BUILD_MODE="${BUILD_MODE:-normal}"
UVM_TEST="${UVM_TEST:-calc_directed_test}"
UVM_VERBOSITY="${UVM_VERBOSITY:-UVM_MEDIUM}"
SEED="${SEED:-42}"
NUM_TRANSACTIONS="${NUM_TRANSACTIONS:-100}"
WAVES="${WAVES:-1}"
LOG_FILE="${PROJECT_ROOT}/sim/${UVM_TEST}_seed${SEED}_${BUILD_MODE}_t${SIM_THREADS}.log"

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

mkdir -p "${PROJECT_ROOT}/sim"
cd "${PROJECT_ROOT}/sim"

echo "Running ${EXECUTABLE}"
echo "UVM test:      ${UVM_TEST}"
echo "UVM verbosity: ${UVM_VERBOSITY}"

SIM_ARGS=(
    "+UVM_TESTNAME=${UVM_TEST}"
    "+UVM_VERBOSITY=${UVM_VERBOSITY}"
    "+SEED=${SEED}"
    "+NUM_TRANSACTIONS=${NUM_TRANSACTIONS}"
)
if [[ "${WAVES}" != "0" ]]; then
    SIM_ARGS+=("+WAVES")
fi

set +e
"${EXECUTABLE}" "${SIM_ARGS[@]}" 2>&1 | tee "${LOG_FILE}"
SIM_STATUS=${PIPESTATUS[0]}
set -e

if [[ ${SIM_STATUS} -ne 0 ]]; then
    echo "ERROR: Simulator process exited with status ${SIM_STATUS}"
    exit "${SIM_STATUS}"
fi

if grep -Eq "^UVM_(ERROR|FATAL) .*\\[" "${LOG_FILE}" ||
   grep -Eq "SB_UN(DRAINED|EXPECTED)|Scoreboard mismatch|ASSERT:" "${LOG_FILE}"; then
    echo "ERROR: UVM error, assertion, or scoreboard mismatch found"
    exit 1
fi

if ! grep -q "CALC_SCOREBOARD_COMPLETE" "${LOG_FILE}"; then
    echo "ERROR: Missing CALC_SCOREBOARD_COMPLETE marker"
    exit 1
fi

if grep -q "CALC_SCOREBOARD_COMPLETE result=FAIL" "${LOG_FILE}"; then
    echo "ERROR: Scoreboard reported FAIL"
    exit 1
fi

echo
echo "Simulation log: ${LOG_FILE}"
if [[ "${WAVES}" != "0" ]]; then
    echo "Waveform:       ${PROJECT_ROOT}/sim/waves.fst"
fi
echo "Coverage data:  ${BUILD_DIR}/coverage.dat"