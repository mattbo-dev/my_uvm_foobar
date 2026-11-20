#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_MODE="${BUILD_MODE:-normal}"
SIM_THREADS="${SIM_THREADS:-4}"
BUILD_DIR="${PROJECT_ROOT}/sim/obj_${BUILD_MODE}_t${SIM_THREADS}"
COVERAGE_DIR="${PROJECT_ROOT}/sim/coverage"
mkdir -p "${COVERAGE_DIR}"

if ! command -v verilator_coverage >/dev/null 2>&1; then
    echo "ERROR: verilator_coverage is not installed"
    exit 1
fi

DATA_FILES=()
while IFS= read -r -d '' data_file; do
    DATA_FILES+=("${data_file}")
done < <(find "${PROJECT_ROOT}/sim" -type f -name 'coverage.dat' -print0)

if [[ "${#DATA_FILES[@]}" -eq 0 ]]; then
    echo "ERROR: No coverage.dat files found under ${PROJECT_ROOT}/sim"
    exit 1
fi

SUMMARY="${COVERAGE_DIR}/summary.txt"
verilator_coverage "${DATA_FILES[@]}" > "${SUMMARY}"

MERGED="${COVERAGE_DIR}/merged.dat"
if [[ "${#DATA_FILES[@]}" -gt 1 ]]; then
    verilator_coverage --write "${MERGED}" "${DATA_FILES[@]}"
else
    cp "${DATA_FILES[0]}" "${MERGED}"
fi

ANNOTATED="${COVERAGE_DIR}/annotated"
mkdir -p "${ANNOTATED}"
verilator_coverage --annotate "${ANNOTATED}" "${MERGED}"

echo "Structural coverage summary: ${SUMMARY}"
echo "Merged coverage data:         ${MERGED}"
echo "Annotated source:             ${ANNOTATED}"
