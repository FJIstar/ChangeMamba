#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=============================================="
echo "ChangeMamba Environment Verification"
echo "=============================================="

echo
echo "Project root:"
echo "$PROJECT_ROOT"

echo
echo "[1/8] Conda environment"

echo "CONDA_DEFAULT_ENV=${CONDA_DEFAULT_ENV:-UNSET}"
echo "CONDA_PREFIX=${CONDA_PREFIX:-UNSET}"

if [ "${CONDA_DEFAULT_ENV:-}" != "changemamba" ]; then
    echo "WARNING: current Conda environment is not 'changemamba'."
fi

if [ -z "${CONDA_PREFIX:-}" ]; then
    echo "ERROR: CONDA_PREFIX is not set."
    exit 1
fi

echo
echo "[2/8] Python"

which python
python --version

echo
echo "[3/8] CUDA toolkit"

echo "CUDA_HOME=${CUDA_HOME:-UNSET}"

if [ -z "${CUDA_HOME:-}" ]; then
    echo "ERROR: CUDA_HOME is not set."
    exit 1
fi

which nvcc
nvcc --version

if [ ! -f "$CUDA_HOME/include/cuda_runtime.h" ]; then
    echo "ERROR: cuda_runtime.h not found"
    exit 1
fi

if [ ! -f "$CUDA_HOME/include/cuda_runtime_api.h" ]; then
    echo "ERROR: cuda_runtime_api.h not found"
    exit 1
fi

echo "CUDA headers OK"

echo
echo "[4/8] GPU and PyTorch"

python - <<'PY'
import torch

print("torch =", torch.__version__)
print("torch CUDA =", torch.version.cuda)
print("CUDA available =", torch.cuda.is_available())

assert torch.__version__ == "2.1.1+cu118", \
    f"Unexpected torch version: {torch.__version__}"

assert torch.version.cuda == "11.8", \
    f"Unexpected torch CUDA version: {torch.version.cuda}"

assert torch.cuda.is_available(), \
    "CUDA is not available in PyTorch"

print("GPU =", torch.cuda.get_device_name(0))
PY

echo
echo "[5/8] Core Python packages"

python - <<'PY'
import numpy
import torchvision
import torchaudio
import triton
import mamba_ssm
import causal_conv1d
import timm

expected = {
    "numpy": ("1.26.3", numpy.__version__),
    "torchvision": ("0.16.1+cu118", torchvision.__version__),
    "torchaudio": ("2.1.1+cu118", torchaudio.__version__),
    "triton": ("2.1.0", triton.__version__),
    "mamba_ssm": ("2.2.2", mamba_ssm.__version__),
    "causal_conv1d": ("1.4.0", causal_conv1d.__version__),
    "timm": ("0.4.12", timm.__version__),
}

for name, (target, actual) in expected.items():
    print(f"{name} = {actual}")

    assert actual == target, \
        f"{name}: expected {target}, got {actual}"

print("Core package versions OK")
PY

echo
echo "[6/8] PyTorch shared-library path"

TORCH_LIB_EXPECTED="$CONDA_PREFIX/lib/python3.10/site-packages/torch/lib"

echo "Expected torch lib:"
echo "$TORCH_LIB_EXPECTED"

if [ ! -f "$TORCH_LIB_EXPECTED/libc10.so" ]; then
    echo "ERROR: libc10.so not found"
    exit 1
fi

echo "libc10.so OK"

case ":${LD_LIBRARY_PATH:-}:" in
    *":$TORCH_LIB_EXPECTED:"*)
        echo "torch/lib is present in LD_LIBRARY_PATH"
        ;;
    *)
        echo "ERROR: torch/lib is missing from LD_LIBRARY_PATH"
        exit 1
        ;;
esac

echo
echo "[7/8] ChangeMamba selective_scan kernels"

python - <<'PY'
import torch
import selective_scan_cuda_oflex
import selective_scan_cuda_core
import selective_scan_cuda_ndstate

print("selective_scan_cuda_oflex   OK")
print("selective_scan_cuda_core    OK")
print("selective_scan_cuda_ndstate OK")
PY

echo
echo "[8/8] ChangeMamba repository"

cd "$PROJECT_ROOT"

CURRENT_COMMIT="$(git rev-parse HEAD)"
EXPECTED_COMMIT="9ce9cec13f9ea14bc0ad91f071577ec9b3a97983"

echo "Current commit:"
echo "$CURRENT_COMMIT"

if [ "$CURRENT_COMMIT" != "$EXPECTED_COMMIT" ]; then
    echo "WARNING: repository commit differs from validated upstream commit."
    echo "Validated upstream commit:"
    echo "$EXPECTED_COMMIT"
fi

echo
echo "=============================================="
echo "ChangeMamba environment verification PASSED"
echo "=============================================="

exit 0
