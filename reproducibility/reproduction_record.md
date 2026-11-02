# ChangeMamba Reproduction Record

This document records the formal reproduction process and experimental
results for ChangeMamba.

The goal is to keep the reproduction traceable, comparable, and reusable
for later CDMamba, CD-Lamba, SChanger, and the proposed PCRM-DAIM-CSM model.

---

## 1. Paper Information

Paper:

    ChangeMamba

Task:

    Remote Sensing Binary Change Detection

Upstream repository:

    https://github.com/ChenHongruixuan/ChangeMamba

Validated upstream commit:

    9ce9cec13f9ea14bc0ad91f071577ec9b3a97983

Commit message:

    modify hyperparameter name

Repository checkout type:

    shallow clone (--depth 1)

Reproduction date:

    2026-11-02

---

## 2. Hardware

Cloud platform:

    AutoDL

GPU:

    NVIDIA A800 80GB PCIe

GPU memory:

    81920 MiB

Driver:

    580.82.07

nvidia-smi driver CUDA capability:

    CUDA 13.0

Important:

The CUDA 13.0 value above represents driver capability.
The actual CUDA Toolkit used for ChangeMamba is CUDA 11.8.

CPU:

    TBD

System RAM:

    TBD

Disk configuration:

    TBD

---

## 3. Software Environment

Operating system:

    Ubuntu 22.04 based AutoDL container

Conda environment:

    changemamba

Python:

    3.10.x

NumPy:

    1.26.3

PyTorch:

    2.1.1+cu118

torchvision:

    0.16.1+cu118

torchaudio:

    2.1.1+cu118

Triton:

    2.1.0

mamba-ssm:

    2.2.2

causal-conv1d:

    1.4.0

timm:

    0.4.12

CUDA Toolkit:

    11.8

CUDA_HOME:

    /usr/local/cuda-11.8

nvcc:

    11.8.89

gcc:

    11.3.0

---

## 4. selective_scan Validation

The following ChangeMamba CUDA extensions were compiled and verified:

    selective_scan_cuda_oflex   OK
    selective_scan_cuda_core    OK
    selective_scan_cuda_ndstate OK

Known environment fixes are documented in:

    reproducibility/TROUBLESHOOTING.md

---

## 5. Dataset

Primary first reproduction dataset:

    WHU-CD

Dataset root:

    TBD

Dataset organization:

    TBD

Train split:

    TBD

Validation split:

    TBD

Test split:

    TBD

Image size:

    TBD

Number of train samples:

    TBD

Number of validation samples:

    TBD

Number of test samples:

    TBD

Ground-truth encoding:

    TBD

Dataset preprocessing:

    TBD

Dataset audit completed:

    NO

Notes:

    The first goal is to verify the exact dataset structure and split before
    running official checkpoint inference or training.

---

## 6. Model

Model family:

    MambaBCD

Initial reproduction model:

    MambaBCD_Tiny

Model config:

    TBD

Encoder config:

    TBD

Input crop size:

    256 x 256 expected, to be verified against the current official code

Batch size:

    TBD

Number of parameters:

    TBD

FLOPs:

    TBD

---

## 7. Official Checkpoint

Official checkpoint source:

    TBD

Checkpoint filename:

    TBD

Checkpoint SHA-256:

    TBD

Checkpoint model type:

    MambaBCD_Tiny

Checkpoint loading argument:

    --model_checkpoint_path

Important:

Do not confuse full-model checkpoint loading with encoder-only pretrained
weights.

The current official code distinguishes at least:

    encoder_pretrained_path
    model_checkpoint_path
    resume_training_path

Exact command will be recorded after verification against the current
official repository.

---

## 8. Inference Reproduction

Inference command:

    TBD

Dataset:

    WHU-CD

Model:

    MambaBCD_Tiny

Checkpoint:

    TBD

Input size:

    TBD

Batch size:

    TBD

Inference date:

    TBD

Peak GPU memory:

    TBD

Inference time:

    TBD

---

## 9. Training Configuration

Training command:

    TBD

Optimizer:

    TBD

Learning rate:

    TBD

Weight decay:

    TBD

Scheduler:

    TBD

Batch size:

    TBD

Crop size:

    TBD

Iterations:

    TBD

Epochs:

    TBD

Loss:

    TBD

AMP:

    TBD

Random seed:

    TBD

Number of workers:

    TBD

Checkpoint frequency:

    TBD

Validation frequency:

    TBD

---

## 10. Official Reported Results

Dataset:

    WHU-CD

Model:

    MambaBCD_Tiny

Official F1:

    TBD

Official IoU:

    TBD

Official Precision:

    TBD

Official Recall:

    TBD

Source of official result:

    TBD

---

## 11. Historical Local Result

A previous successful ChangeMamba reproduction had approximately:

    Dataset: WHU-CD
    Model: MambaBCD_Tiny
    F1: approximately 0.9409

Important:

This value is retained only as a historical calibration reference.

The exact previous code version, data split, checkpoint, and training
conditions may differ from the current 2026 reorganized official repository.

Therefore, the current reproduction should not assume that the exact same
metric must be obtained.

---

## 12. Current Reproduced Results

Dataset:

    WHU-CD

Model:

    MambaBCD_Tiny

F1:

    TBD

IoU:

    TBD

Precision:

    TBD

Recall:

    TBD

Overall Accuracy:

    TBD

Other metrics:

    TBD

---

## 13. Efficiency Results

Parameters:

    TBD

FLOPs:

    TBD

Peak GPU memory during inference:

    TBD

Peak GPU memory during training:

    TBD

Average inference time per image pair:

    TBD

Training time:

    TBD

GPU utilization observations:

    TBD

---

## 14. Reproduction Comparison

Official F1:

    TBD

Historical local F1:

    approximately 0.9409

Current reproduced F1:

    TBD

Absolute difference from official:

    TBD

Absolute difference from historical result:

    TBD

Possible reasons for differences:

    TBD

---

## 15. Problems Encountered

Environment-level problems:

    See reproducibility/TROUBLESHOOTING.md

Dataset-level problems:

    TBD

Checkpoint-level problems:

    TBD

Code-level problems:

    TBD

Training-level problems:

    TBD

---

## 16. Reproduction Status

Environment:

    PASS

GPU:

    PASS

CUDA:

    PASS

PyTorch:

    PASS

Mamba:

    PASS

selective_scan:

    PASS

Project import:

    NOT TESTED YET

Dataset audit:

    NOT STARTED

Official checkpoint inference:

    NOT STARTED

Short training test:

    NOT STARTED

Full training reproduction:

    NOT STARTED

Metric comparison:

    NOT STARTED

---

## 17. Next Actions

The next actions are:

    1. Verify environment again after deactivate/reactivate.
    2. Verify ChangeMamba project-level imports.
    3. Audit WHU-CD directory organization.
    4. Verify WHU-CD split files.
    5. Obtain and hash the official MambaBCD_Tiny checkpoint.
    6. Run official checkpoint inference.
    7. Record F1, IoU, Precision, Recall, memory, and runtime.
    8. Run a short training sanity check.
    9. Run formal baseline reproduction only after the above steps pass.
    10. Use the same recording structure for CDMamba, CD-Lamba, SChanger,
        and the proposed PCRM-DAIM-CSM model.

---

## 18. Reproducibility Principle

Do not modify multiple variables at the same time.

For each reproduction stage, record:

    code commit
    environment
    dataset split
    checkpoint
    config
    command
    random seed
    metrics
    runtime
    memory

Only after the official baseline is verified should architecture-level
modifications be introduced.
