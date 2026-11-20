#!/usr/bin/env bash

# Catch errors for any piped commands, unset variables, and exit on any error.
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_ROOT="${PROJECT_ROOT}/sim"
TOP_MODULE="${TOP_MODULE:-tb_top}"

# Number of threads in the generated simulation model.
SIM_THREADS="${SIM_THREADS:-4}"

# Development modes:
#   fast    = faster compilation, no waveform tracing
#   normal  = balanced compilation with FST tracing
#   release = slower compilation, optimized simulation
BUILD_MODE="${BUILD_MODE:-normal}"

# If UVM_HOME is not already exported, use this default.
UVM_HOME="${UVM_HOME:-${HOME}/tools/uvm-verilator/src}"

# Logging
LOG_DIR="${BUILD_ROOT}/logs"
BUILD_LOG="${LOG_DIR}/build_${BUILD_MODE}_t${SIM_THREADS}.log"

case "${BUILD_MODE}" in
    fast)
        CXX_OPT="-O0"
        TRACE_OPTIONS=()
        ;;

    normal)
        CXX_OPT="-O1"
        TRACE_OPTIONS=(
            --trace-fst
        )
        ;;

    release)
        CXX_OPT="-O3 -march=native"
        TRACE_OPTIONS=(
            --trace-fst
        )
        ;;

    *)
        echo "ERROR: Unknown BUILD_MODE: ${BUILD_MODE}"
        echo "Valid modes: fast, normal, release"
        exit 1
        ;;
esac

# Separate output directories prevent different thread configurations
# and optimization modes from overwriting one another.
BUILD_DIR="${BUILD_ROOT}/obj_${BUILD_MODE}_t${SIM_THREADS}"
EXECUTABLE="${BUILD_DIR}/V${TOP_MODULE}"

if ! command -v verilator >/dev/null 2>&1; then
    echo "ERROR: Verilator was not found in PATH."
    exit 1
fi

if [[ ! -f "${UVM_HOME}/uvm_pkg.sv" ]]; then
    echo "ERROR: Cannot find:"
    echo "  ${UVM_HOME}/uvm_pkg.sv"
    echo
    echo "Set UVM_HOME to the UVM src directory."
    exit 1
fi

for source_file in \
    "${PROJECT_ROOT}/rtl/dut.sv" \
    "${PROJECT_ROOT}/tb/my_uvm_pkg.sv" \
    "${PROJECT_ROOT}/tb/tb_top.sv"
do
    if [[ ! -f "${source_file}" ]]; then
        echo "ERROR: Missing source file:"
        echo "  ${source_file}"
        exit 1
    fi
done

mkdir -p "${BUILD_DIR}"
mkdir -p "${LOG_DIR}"

echo "--------------------------------------------------"
echo "Verilator:       $(verilator --version)"
echo "Project root:    ${PROJECT_ROOT}"
echo "UVM_HOME:        ${UVM_HOME}"
echo "Top module:      ${TOP_MODULE}"
echo "Build mode:      ${BUILD_MODE}"
echo "C++ optimization:${CXX_OPT}"
echo "Build jobs:      all available processors"
echo "Sim threads:     ${SIM_THREADS}"
echo "Output:          ${BUILD_DIR}"
echo "--------------------------------------------------"

verilator \
    --binary \
    --timing \
    --assert \
    -Wall \
    -Wno-fatal \
    -j 0 \
    --threads "${SIM_THREADS}" \
    -CFLAGS "${CXX_OPT}" \
    --top-module "${TOP_MODULE}" \
    --Mdir "${BUILD_DIR}" \
    "${TRACE_OPTIONS[@]}" \
    +define+UVM_NO_DPI \
    "+incdir+${UVM_HOME}" \
    "+incdir+${PROJECT_ROOT}/rtl" \
    "+incdir+${PROJECT_ROOT}/tb" \
    "${UVM_HOME}/uvm_pkg.sv" \
    "${PROJECT_ROOT}/rtl/dut.sv" \
    "${PROJECT_ROOT}/tb/my_uvm_pkg.sv" \
    "${PROJECT_ROOT}/tb/tb_top.sv" \
    2>&1 | tee "${BUILD_LOG}"

echo
echo "Build completed successfully."
echo
echo "Executable:"
echo "  ${EXECUTABLE}"
echo
echo "Build log:"
echo "  ${BUILD_LOG}"
