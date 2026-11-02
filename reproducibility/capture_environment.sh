#!/usr/bin/env bash

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/environment_snapshot.txt"

log_step() {
    echo
    echo "[$1] $2"
}

run_to_file() {
    local title="$1"
    shift

    {
        echo
        echo "=============================================="
        echo "$title"
        echo "=============================================="
        timeout 20s "$@" 2>&1 || echo "[WARNING] Command failed or timed out: $*"
    } >> "$OUTPUT_FILE"
}

echo "=============================================="
echo "ChangeMamba Environment Capture"
echo "=============================================="

echo "Project root:"
echo "$PROJECT_ROOT"

echo
echo "Output:"
echo "$OUTPUT_FILE"

: > "$OUTPUT_FILE"

{
    echo "=============================================="
    echo "ChangeMamba Environment Snapshot"
    echo "=============================================="
    echo
    echo "Capture time:"
    date
    echo
    echo "Project root:"
    echo "$PROJECT_ROOT"
} >> "$OUTPUT_FILE"

log_step "1/10" "Capturing system information..."
run_to_file "SYSTEM" uname -a

if [ -f /etc/os-release ]; then
    {
        echo
        echo "OS RELEASE"
        cat /etc/os-release
    } >> "$OUTPUT_FILE"
fi

log_step "2/10" "Capturing Conda environment..."

{
    echo
    echo "=============================================="
    echo "CONDA"
    echo "=============================================="
    echo "CONDA_DEFAULT_ENV=${CONDA_DEFAULT_ENV:-UNSET}"
    echo "CONDA_PREFIX=${CONDA_PREFIX:-UNSET}"
} >> "$OUTPUT_FILE"

timeout 15s conda env list >> "$OUTPUT_FILE" 2>&1 || \
    echo "[WARNING] conda env list timed out" >> "$OUTPUT_FILE"

log_step "3/10" "Capturing Python..."

{
    echo
    echo "=============================================="
    echo "PYTHON"
    echo "=============================================="
    which python
    python --version
} >> "$OUTPUT_FILE" 2>&1

log_step "4/10" "Capturing GPU and NVIDIA driver..."
run_to_file "GPU / NVIDIA DRIVER" nvidia-smi

log_step "5/10" "Capturing CUDA toolkit..."

{
    echo
    echo "=============================================="
    echo "CUDA TOOLKIT"
    echo "=============================================="
    echo "CUDA_HOME=${CUDA_HOME:-UNSET}"
    which nvcc || true
    nvcc --version || true

    echo
    echo "CUDA headers:"

    if [ -n "${CUDA_HOME:-}" ]; then
        test -f "$CUDA_HOME/include/cuda_runtime.h" \
            && echo "cuda_runtime.h OK" \
            || echo "cuda_runtime.h MISSING"

        test -f "$CUDA_HOME/include/cuda_runtime_api.h" \
            && echo "cuda_runtime_api.h OK" \
            || echo "cuda_runtime_api.h MISSING"
    fi
} >> "$OUTPUT_FILE" 2>&1

log_step "6/10" "Capturing compiler information..."

{
    echo
    echo "=============================================="
    echo "COMPILERS"
    echo "=============================================="

    which gcc || true
    gcc --version | head -1 || true

    which g++ || true
    g++ --version | head -1 || true
} >> "$OUTPUT_FILE" 2>&1

log_step "7/10" "Checking core Python packages..."

python - <<'PY' >> "$OUTPUT_FILE" 2>&1
print()
print("==============================================")
print("CORE PYTHON PACKAGES")
print("==============================================")

import sys
print("python =", sys.version.replace("\n", " "))

modules = [
    ("numpy", "numpy"),
    ("torch", "torch"),
    ("torchvision", "torchvision"),
    ("torchaudio", "torchaudio"),
    ("triton", "triton"),
    ("mamba_ssm", "mamba_ssm"),
    ("causal_conv1d", "causal_conv1d"),
    ("timm", "timm"),
]

for label, module_name in modules:
    try:
        module = __import__(module_name)
        print(label, "=", getattr(module, "__version__", "UNKNOWN"))
    except Exception as e:
        print(label, "= ERROR:", repr(e))

try:
    import torch
    print("torch CUDA =", torch.version.cuda)
    print("CUDA available =", torch.cuda.is_available())
    if torch.cuda.is_available():
        print("GPU =", torch.cuda.get_device_name(0))
except Exception as e:
    print("PyTorch CUDA check ERROR:", repr(e))
PY

log_step "8/10" "Checking selective_scan extensions..."

python - <<'PY' >> "$OUTPUT_FILE" 2>&1
print()
print("==============================================")
print("SELECTIVE SCAN")
print("==============================================")

import torch

for name in [
    "selective_scan_cuda_oflex",
    "selective_scan_cuda_core",
    "selective_scan_cuda_ndstate",
]:
    try:
        __import__(name)
        print(name, "OK")
    except Exception as e:
        print(name, "ERROR:", repr(e))
PY

log_step "9/10" "Capturing ChangeMamba Git version..."

{
    echo
    echo "=============================================="
    echo "CHANGE MAMBA SOURCE"
    echo "=============================================="

    cd "$PROJECT_ROOT" || exit 1

    timeout 10s git rev-parse HEAD || true
    timeout 10s git log -1 --oneline || true
} >> "$OUTPUT_FILE" 2>&1

log_step "10/10" "Running lightweight package checks..."

{
    echo
    echo "=============================================="
    echo "PIP CHECK"
    echo "=============================================="
} >> "$OUTPUT_FILE"

timeout 20s python -m pip check >> "$OUTPUT_FILE" 2>&1 || \
    echo "[WARNING] pip check returned warnings/errors or timed out" >> "$OUTPUT_FILE"

{
    echo
    echo "=============================================="
    echo "IMPORTANT PACKAGE VERSIONS"
    echo "=============================================="
} >> "$OUTPUT_FILE"

timeout 20s python -m pip list --disable-pip-version-check \
    | grep -E "numpy|torch|vision|audio|triton|mamba|causal|timm|pytest|fvcore|yacs|tensorboardX|submitit|chardet" \
    >> "$OUTPUT_FILE" 2>&1 || true

{
    echo
    echo "=============================================="
    echo "END OF SNAPSHOT"
    echo "=============================================="
} >> "$OUTPUT_FILE"

echo
echo "=============================================="
echo "Environment snapshot completed successfully"
echo "=============================================="

echo
ls -lh "$OUTPUT_FILE"

echo
echo "Saved to:"
echo "$OUTPUT_FILE"

exit 0
