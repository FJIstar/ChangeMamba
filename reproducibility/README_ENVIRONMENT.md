# ChangeMamba Reproduction Environment

This document records the validated environment used for the current
ChangeMamba reproduction.

## 1. Platform and GPU

Platform:

    AutoDL

GPU:

    NVIDIA A800 80GB PCIe

Driver:

    580.82.07

nvidia-smi reports driver support up to:

    CUDA 13.0

Important:

The CUDA 13.0 value shown by nvidia-smi reflects NVIDIA driver capability.
It does NOT mean the ChangeMamba environment is compiled with CUDA 13.0.

The actual CUDA Toolkit used by this project is CUDA 11.8.

---

## 2. CUDA Toolkit

Validated CUDA Toolkit:

    CUDA 11.8

CUDA_HOME:

    /usr/local/cuda-11.8

nvcc:

    /usr/local/cuda-11.8/bin/nvcc

Validated nvcc version:

    11.8.89

Required CUDA development headers were verified at:

    /usr/local/cuda-11.8/include/cuda_runtime.h
    /usr/local/cuda-11.8/include/cuda_runtime_api.h

Compiler:

    gcc 11.3.0

---

## 3. Conda environment

Environment name:

    changemamba

Reference environment:

    mamba2

The original mamba2 environment is treated as the golden reference
environment and should not be modified unnecessarily.

Activate the project environment with:

    conda activate changemamba

---

## 4. Core Python packages

Validated core versions:

    Python          3.10.x

    numpy           1.26.3

    torch           2.1.1+cu118
    torchvision     0.16.1+cu118
    torchaudio      2.1.1+cu118
    triton          2.1.0

    mamba-ssm       2.2.2
    causal-conv1d   1.4.0

    timm            0.4.12

The core scientific-computing stack should not be upgraded unless a
specific target repository proves that a different version is necessary.

---

## 5. PyTorch and CUDA compatibility

PyTorch version:

    2.1.1+cu118

PyTorch CUDA runtime:

    11.8

System CUDA Toolkit used for extension compilation:

    11.8

These versions are intentionally aligned.

---

## 6. PyTorch shared-library path

PyTorch shared libraries are located at:

    $CONDA_PREFIX/lib/python3.10/site-packages/torch/lib

The ChangeMamba CUDA extensions require this directory in LD_LIBRARY_PATH.

The validated environment configuration is:

    export CUDA_HOME=/usr/local/cuda-11.8
    export PATH=$CUDA_HOME/bin:$PATH
    export TORCH_LIB=$CONDA_PREFIX/lib/python3.10/site-packages/torch/lib
    export LD_LIBRARY_PATH=$TORCH_LIB:$CONDA_PREFIX/lib:$CUDA_HOME/lib64:${LD_LIBRARY_PATH:-}

These variables have been persisted in:

    $CONDA_PREFIX/etc/conda/activate.d/changemamba_cuda.sh

---

## 7. ChangeMamba source

Upstream repository:

    https://github.com/ChenHongruixuan/ChangeMamba

Validated upstream commit:

    9ce9cec13f9ea14bc0ad91f071577ec9b3a97983

Commit message:

    modify hyperparameter name

The repository was cloned using:

    git clone --depth 1 https://github.com/ChenHongruixuan/ChangeMamba.git

---

## 8. ChangeMamba selective_scan status

The ChangeMamba selective_scan extension was successfully compiled using:

    CUDA Toolkit 11.8
    PyTorch 2.1.1+cu118
    gcc 11.3.0

Validated extension imports:

    selective_scan_cuda_oflex   OK
    selective_scan_cuda_core    OK
    selective_scan_cuda_ndstate OK

These imports were verified with:

    python -c "import torch; import selective_scan_cuda_oflex; print('oflex OK')"

    python -c "import torch; import selective_scan_cuda_core; print('core OK')"

    python -c "import torch; import selective_scan_cuda_ndstate; print('ndstate OK')"

---

## 9. Dependency installation policy

Do NOT blindly run:

    pip install -r requirements.txt

The upstream requirements file contains unpinned core packages such as:

    torch
    torchvision
    torchaudio
    triton

For this reproduction, auxiliary dependencies are installed incrementally.

Preferred policy:

    pip install --no-deps PACKAGE==VERSION

After dependency changes, run:

    pip check

Before dependency changes, save:

    pip freeze

and:

    conda env export --no-builds

---

## 10. Important reproducibility files

Environment files are stored under:

    reproducibility/

Important files include:

    README_ENVIRONMENT.md
    TROUBLESHOOTING.md
    requirements_locked.txt
    environment.yml
    conda_explicit.txt
    upstream_commit.txt
    capture_environment.sh
    activate_changemamba.sh
    verify_environment.sh
    reproduction_record.md

Not all of these files may exist yet. They should be generated before the
first formal ChangeMamba experiment is recorded.

---

## 11. Current environment status

Validated:

    [OK] AutoDL instance
    [OK] NVIDIA A800 80GB PCIe
    [OK] NVIDIA driver
    [OK] CUDA Toolkit 11.8
    [OK] PyTorch 2.1.1+cu118
    [OK] NumPy 1.26.3
    [OK] mamba-ssm 2.2.2
    [OK] causal-conv1d 1.4.0
    [OK] ChangeMamba repository
    [OK] selective_scan compilation
    [OK] selective_scan_cuda_oflex
    [OK] selective_scan_cuda_core
    [OK] selective_scan_cuda_ndstate
    [OK] CUDA_HOME persistence
    [OK] PyTorch shared-library path persistence

Next stage:

    Project-level import verification
    WHU-CD dataset preparation
    Official checkpoint inference
    Reproduction metric comparison
