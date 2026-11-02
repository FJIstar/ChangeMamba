# ChangeMamba Reproduction Troubleshooting

This document records the environment problems encountered during the
ChangeMamba reproduction on AutoDL and their validated solutions.

---

## 1. Conda clone failed with TUNA 403

Observed error:

    CondaHTTPError: HTTP 403 FORBIDDEN
    mirrors.tuna.tsinghua.edu.cn

Another error was also observed:

    [Errno 116] Stale file handle

Cause:

The AutoDL-preinstalled mamba2 environment contains historical Conda package
metadata pointing to the TUNA mirror. Therefore, even after changing the
current Conda channel configuration, the command

    conda create -n changemamba --clone mamba2 -y

may still try to retrieve historical packages from TUNA.

The Conda package cache also produced stale-file-handle errors, so repeatedly
retrying conda clone was considered unreliable.

Decision:

- Keep mamba2 as the golden reference environment.
- Do not modify mamba2 unnecessarily.
- Create a separate changemamba environment.
- Do not interpret a TUNA 403 error as a general network failure.

Network access to Anaconda official repositories was independently verified:

    curl -I https://repo.anaconda.com/pkgs/main/linux-64/repodata.json

Result:

    HTTP/2 200

---

## 2. Git clone temporarily failed with GnuTLS error

Observed error:

    fatal: unable to access
    https://github.com/ChenHongruixuan/ChangeMamba.git/
    GnuTLS recv error (-110):
    The TLS connection was non-properly terminated.

Diagnosis:

GitHub itself was reachable:

    curl -I https://github.com

Result:

    HTTP/2 200

The repository was also reachable:

    git ls-remote https://github.com/ChenHongruixuan/ChangeMamba.git

The returned HEAD was:

    9ce9cec13f9ea14bc0ad91f071577ec9b3a97983

Therefore this was treated as a temporary HTTPS/TLS transfer interruption,
not a repository-address error.

Working solution:

    cd /root/autodl-tmp/projects
    rm -rf ChangeMamba
    git clone --depth 1 https://github.com/ChenHongruixuan/ChangeMamba.git

Validated ChangeMamba commit:

    9ce9cec13f9ea14bc0ad91f071577ec9b3a97983

Commit message:

    modify hyperparameter name

---

## 3. Do not blindly install the upstream requirements.txt

The ChangeMamba requirements.txt contains unpinned core packages:

    torch
    torchvision
    torchaudio
    triton

Running

    pip install -r requirements.txt

could replace a known-good PyTorch/CUDA environment.

Reproduction policy:

- Keep PyTorch fixed.
- Keep torchvision fixed.
- Keep torchaudio fixed.
- Keep Triton fixed.
- Keep NumPy fixed.
- Keep mamba-ssm fixed.
- Keep causal-conv1d fixed.
- Install only missing auxiliary packages.
- Prefer pip install --no-deps for auxiliary packages.
- Run pip check after installation.

Validated core versions:

    numpy          1.26.3
    torch          2.1.1+cu118
    torchvision    0.16.1+cu118
    torchaudio     2.1.1+cu118
    triton         2.1.0
    mamba-ssm      2.2.2
    causal-conv1d  1.4.0

---

## 4. Auxiliary packages were installed incrementally

The following ChangeMamba auxiliary packages were added explicitly:

    timm==0.4.12
    pytest==9.2.0
    chardet==5.2.0
    yacs==0.1.8
    termcolor==3.3.0
    submitit==1.5.4
    tensorboardX==2.6.5
    fvcore==0.1.5.post20221221

Additional dependencies identified using pip check were also installed
explicitly:

    pluggy==1.6.0
    iniconfig==2.3.0
    pygments==2.21.0
    exceptiongroup==1.2.2
    tomli==2.0.1
    cloudpickle==3.1.1
    protobuf==4.25.3
    tabulate==0.9.0
    iopath==0.1.10
    portalocker==2.8.2

The important point is that NumPy, PyTorch, torchvision, CUDA, mamba-ssm,
and causal-conv1d were not upgraded.

---

## 5. RequestsDependencyWarning caused by chardet version

Observed warning:

    RequestsDependencyWarning:
    urllib3 or chardet/charset_normalizer doesn't match a supported version

The environment contained:

    requests            2.28.1
    urllib3             1.26.13
    charset-normalizer  2.1.1

A newer chardet version caused the warning.

Solution:

    pip install --no-deps chardet==5.2.0

This avoided upgrading requests, urllib3, or the scientific-computing stack.

---

## 6. pytest failed because dependencies were intentionally not auto-installed

Observed errors included:

    ModuleNotFoundError: No module named 'pluggy'

and:

    ModuleNotFoundError: No module named 'exceptiongroup'

Cause:

pytest was installed using --no-deps to prevent pip from automatically
upgrading unrelated packages.

Missing dependencies were therefore installed explicitly.

Examples:

    pip install --no-deps pluggy==1.6.0
    pip install --no-deps iniconfig==2.3.0
    pip install --no-deps pygments==2.21.0
    pip install --no-deps exceptiongroup==1.2.2
    pip install --no-deps tomli==2.0.1

Verification:

    python -c "import pytest; print(pytest.__version__)"

Validated result:

    pytest 9.2.0

---

## 7. pip check revealed lightweight missing dependencies

pip check reported missing dependencies for fvcore, pytest, submitit,
and tensorboardX.

Examples included:

    fvcore requires iopath
    fvcore requires tabulate
    pytest requires exceptiongroup
    pytest requires tomli
    submitit requires cloudpickle
    tensorboardX requires protobuf

The missing packages were installed individually rather than allowing pip
to resolve and potentially upgrade the full dependency tree.

After correction, pip check only reported:

    ninja 1.11.1.1 is not supported on this platform

However, Ninja itself worked:

    which ninja

returned:

    /root/miniconda3/envs/changemamba/bin/ninja

and:

    ninja --version

returned a valid Ninja version.

Therefore this pip metadata warning was not treated as a blocker.

---

## 8. selective_scan compilation failed because CUDA headers were missing

Observed errors:

    fatal error: cuda_runtime.h: No such file or directory

and:

    fatal error: cuda_runtime_api.h: No such file or directory

The relevant environment was:

    PyTorch       2.1.1+cu118
    PyTorch CUDA  11.8
    nvcc          11.8
    gcc           11.3.0
    GPU           NVIDIA A800 80GB PCIe

During the failed build, CUDA_HOME was:

    /root/miniconda3/envs/changemamba

That Conda environment contained nvcc, but not the complete CUDA Toolkit
development headers.

A complete CUDA 11.8 Toolkit was found at:

    /usr/local/cuda-11.8

The required headers were confirmed at:

    /usr/local/cuda-11.8/include/cuda_runtime.h
    /usr/local/cuda-11.8/include/cuda_runtime_api.h

Validated fix:

    export CUDA_HOME=/usr/local/cuda-11.8
    export PATH=$CUDA_HOME/bin:$PATH
    export LD_LIBRARY_PATH=$CUDA_HOME/lib64:$LD_LIBRARY_PATH

Verification:

    echo $CUDA_HOME
    which nvcc
    nvcc --version

Expected CUDA_HOME:

    /usr/local/cuda-11.8

Expected nvcc:

    /usr/local/cuda-11.8/bin/nvcc

Before rebuilding, old build products were removed:

    cd /root/autodl-tmp/projects/ChangeMamba/kernels/selective_scan
    rm -rf build
    rm -rf *.egg-info

The extension was rebuilt with:

    MAX_JOBS=4 pip install . -v

---

## 9. selective_scan import failed because libc10.so was not found

After successful compilation, importing the CUDA extension produced:

    ImportError: libc10.so: cannot open shared object file:
    No such file or directory

The file did exist:

    /root/miniconda3/envs/changemamba/lib/python3.10/site-packages/torch/lib/libc10.so

PyTorch's library directory was:

    /root/miniconda3/envs/changemamba/lib/python3.10/site-packages/torch/lib

Root cause:

The Linux dynamic linker did not have the PyTorch torch/lib directory in
LD_LIBRARY_PATH.

Validated fix:

    export TORCH_LIB=$CONDA_PREFIX/lib/python3.10/site-packages/torch/lib

    export LD_LIBRARY_PATH=$TORCH_LIB:$CONDA_PREFIX/lib:$CUDA_HOME/lib64:${LD_LIBRARY_PATH:-}

After applying this fix, all three ChangeMamba extensions imported correctly.

Verification commands:

    python -c "import torch; import selective_scan_cuda_oflex; print('oflex OK')"

    python -c "import torch; import selective_scan_cuda_core; print('core OK')"

    python -c "import torch; import selective_scan_cuda_ndstate; print('ndstate OK')"

Validated results:

    oflex OK
    core OK
    ndstate OK

---

## 10. CUDA and PyTorch library paths were made persistent

To avoid manually setting CUDA_HOME and LD_LIBRARY_PATH after every login,
the following Conda activation file was created:

    $CONDA_PREFIX/etc/conda/activate.d/changemamba_cuda.sh

Its contents are:

    export CUDA_HOME=/usr/local/cuda-11.8
    export PATH=$CUDA_HOME/bin:$PATH
    export TORCH_LIB=$CONDA_PREFIX/lib/python3.10/site-packages/torch/lib
    export LD_LIBRARY_PATH=$TORCH_LIB:$CONDA_PREFIX/lib:$CUDA_HOME/lib64:${LD_LIBRARY_PATH:-}

Therefore, after:

    conda activate changemamba

the required CUDA and PyTorch shared-library paths should be restored
automatically.

---

## 11. Validated hardware and software environment

Platform:

    AutoDL

GPU:

    NVIDIA A800 80GB PCIe

Driver:

    580.82.07

nvidia-smi reports driver support up to:

    CUDA 13.0

This does NOT mean ChangeMamba is using CUDA 13.0.

The actual CUDA Toolkit used to compile ChangeMamba is:

    CUDA Toolkit 11.8

Validated compiler:

    nvcc 11.8.89

Validated GCC:

    gcc 11.3.0

Python environment:

    Python          3.10.x
    NumPy           1.26.3
    PyTorch         2.1.1+cu118
    torchvision     0.16.1+cu118
    torchaudio      2.1.1+cu118
    Triton          2.1.0
    mamba-ssm       2.2.2
    causal-conv1d   1.4.0
    timm            0.4.12

CUDA configuration:

    CUDA_HOME=/usr/local/cuda-11.8

ChangeMamba upstream repository:

    https://github.com/ChenHongruixuan/ChangeMamba

Validated upstream commit:

    9ce9cec13f9ea14bc0ad91f071577ec9b3a97983

Validated selective_scan extensions:

    selective_scan_cuda_oflex   OK
    selective_scan_cuda_core    OK
    selective_scan_cuda_ndstate OK

---

## 12. Reproduction rules for future servers

The goal is reproducibility and environment stability, not package freshness.

Rules:

1. Do not upgrade a working core package only because a newer version exists.

2. Keep the validated PyTorch, CUDA, NumPy, Mamba, and Triton versions fixed
   unless the target repository clearly requires a different version.

3. Use a project-specific Conda environment.

4. Keep a known-good environment as a golden reference.

5. Before modifying dependencies, save:

       pip freeze

   and:

       conda env export --no-builds

6. Prefer explicit installation of missing auxiliary packages.

7. Prefer --no-deps when protecting a validated scientific-computing stack.

8. Run pip check after dependency changes.

9. Verify CUDA extensions explicitly before beginning training.

10. Record the exact Git commit used for every reproduced paper.

11. Do not use the GPU server as the only copy of source code,
    environment documentation, checkpoints, or experiment logs.

---

## 13. Current success checkpoint

Completed:

    [OK] AutoDL instance verified
    [OK] NVIDIA A800 80GB detected
    [OK] PyTorch 2.1.1+cu118 verified
    [OK] CUDA Toolkit 11.8 verified
    [OK] ChangeMamba official repository cloned
    [OK] ChangeMamba upstream commit recorded
    [OK] Core NumPy/PyTorch stack preserved
    [OK] Auxiliary packages installed incrementally
    [OK] selective_scan successfully compiled
    [OK] selective_scan_cuda_oflex imported
    [OK] selective_scan_cuda_core imported
    [OK] selective_scan_cuda_ndstate imported
    [OK] CUDA_HOME problem diagnosed and fixed
    [OK] libc10.so problem diagnosed and fixed
    [OK] Conda activation script created

Next stage:

    1. Verify the environment after deactivate/reactivate.
    2. Verify ChangeMamba project-level imports.
    3. Prepare WHU-CD.
    4. Run official MambaBCD-Tiny checkpoint inference.
    5. Compare reproduced metrics with the historical and official results.
