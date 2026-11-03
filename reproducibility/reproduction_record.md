# ChangeMamba Reproduction Record

This document records the validated ChangeMamba reproduction workflow,
environment, dataset protocol, checkpoint inference, and training results.

The purpose is to keep the reproduction traceable and reusable for later
baseline comparison and subsequent binary change detection research.

---

## 1. Project Information

Paper:

    ChangeMamba: Remote Sensing Change Detection With Spatio-Temporal State Space Model

Task:

    Remote Sensing Binary Change Detection (BCD)

Upstream repository:

    https://github.com/ChenHongruixuan/ChangeMamba

Windows-side source/data-protocol audit commit:

    9ce9cec13f9ea14bc0ad91f071577ec9b3a97983

Commit message:

    modify hyperparameter name

Server reproduction branch:

    reproduction/a800-cu118

Environment/reproduction branch reference commit:

    9ec6f6c8da5071c03d84e1af70e6e9d56007b55d

Important:

The Windows-side upstream commit and the server reproduction branch serve
different purposes.

The upstream commit was used to audit the released BCD source/data protocol.

The reproduction/a800-cu118 branch records the validated A800 CUDA 11.8
reproduction environment and experiment documentation.

---

## 2. Hardware

Cloud platform:

    AutoDL

GPU:

    NVIDIA A800 80GB PCIe

GPU memory:

    81920 MiB

GPU compute capability:

    8.0

Driver:

    580.82.07

nvidia-smi reported CUDA capability:

    CUDA 13.0

MIG:

    Disabled

Important:

The CUDA 13.0 value reported by nvidia-smi represents the maximum CUDA
version supported by the NVIDIA driver.

The actual ChangeMamba runtime and compilation environment uses CUDA 11.8.

---

## 3. Software Environment

Conda environment:

    changemamba

Python:

    3.10.14

PyTorch:

    2.1.1+cu118

PyTorch CUDA runtime:

    11.8

torchvision:

    0.16.1+cu118

torchaudio:

    2.1.1+cu118

NVCC:

    CUDA 11.8

NumPy:

    1.26.3

Triton:

    2.1.0

timm:

    0.4.12

einops:

    0.8.0

mamba-ssm:

    2.2.2

causal-conv1d:

    1.4.0

Additional runtime dependencies added during formal BCD reproduction:

    imageio 2.38.0
    scipy   1.11.4

The additional packages were installed incrementally without changing the
validated PyTorch/CUDA/Mamba stack.

---

## 4. Mamba / CUDA Validation

Validated:

    torch.cuda.is_available() = True
    GPU = NVIDIA A800 80GB PCIe
    selective_scan_fn = OK

Validated ChangeMamba selective-scan extensions:

    selective_scan_cuda_oflex   OK
    selective_scan_cuda_core    OK
    selective_scan_cuda_ndstate OK

Known environment fixes and recovery procedures are documented in:

    reproducibility/TROUBLESHOOTING.md

Dependency policy:

Do not blindly run:

    pip install -r requirements.txt

Missing auxiliary dependencies should be installed incrementally and the
core environment should be revalidated afterwards.

---

## 5. Server Directory Layout

Project source:

    /root/autodl-tmp/projects/ChangeMamba

BCD datasets:

    /root/autodl-tmp/data/ChangeMamba

Checkpoints:

    /root/autodl-tmp/checkpoints/ChangeMamba

Results:

    /root/autodl-tmp/results/ChangeMamba

Logs:

    /root/autodl-tmp/logs/ChangeMamba

---

## 6. Released BCD Data Protocol

Source inspection confirmed that the released BCD implementation expects:

    dataset/
    ├── train/
    │   ├── T1/
    │   ├── T2/
    │   └── GT/
    ├── test/
    │   ├── T1/
    │   ├── T2/
    │   └── GT/
    ├── train_set.txt
    └── test_set.txt

The implementation does not directly support:

    A / B / label

List files are mandatory.

Each line must contain the filename including its extension, for example:

    00000.png

The released BCD loader reads the GT and applies:

    label = loader(label_path) / 255

The task code later converts labels to integer class values.

Therefore binary GT masks must use:

    0 / 255

rather than:

    0 / 1

---

## 7. SYSU Dataset

Original validated split:

    train = 12000
    val   = 4000
    test  = 4000

Image size:

    256 x 256

Original structure:

    A / B / label

ChangeMamba structure:

    T1 / T2 / GT

GT encoding:

    0 / 255

Official-reproduction split used:

    train = 12000
    test  = 4000

Server-side validation:

    T1/T2/GT counts match
    list counts match
    file pairing validated

Status:

    PASS

---

## 8. WHU-CD Dataset

Validated data version:

    256 x 256 cropped WHU-CD

Split:

    train = 4536
    val   = 504
    test  = 2760

Original GT encoding:

    0 / 1

Because the released ChangeMamba BCD loader divides GT values by 255,
0/1 masks cannot be used directly.

GT conversion:

    0 -> 0
    1 -> 255

Converted GT files used in official reproduction:

    7296

Final GT format:

    single-channel uint8 PNG
    values strictly in {0,255}

Original files were not modified.

Status:

    PASS

---

## 9. LEVIR-CD+ Dataset

Validated original LEVIR-CD+:

    train pairs = 637
    test pairs  = 348

Original image size:

    1024 x 1024

Tiling:

    tile size = 256
    stride    = 256
    overlap   = 0

Each source pair produces:

    4 x 4 = 16 patches

Final patch counts:

    train = 10192
    test  = 5568

A/B/GT use identical crop coordinates.

32 original train GT files contained non-binary values:

    156
    254

GT normalization:

    gt == 0 -> 0
    gt > 0  -> 255

Final GT format:

    single-channel uint8 PNG
    values strictly in {0,255}

Excluded metadata:

    .DS_Store
    __MACOSX
    ._*

Original files were not modified.

Status:

    PASS

---

## 10. Important Evaluation Protocol Note

The released BCD implementation creates a loader named:

    Validation

However, source inspection confirmed that this loader actually uses:

    test_dataset_path
    test_data_name_list

The training process evaluates this test split every 500 iterations.

The released implementation also uses the evaluation result for
best-checkpoint selection.

Therefore:

    released-code reproduction = test split used during model selection

This behavior is retained only for strict reproduction of the released code.

Future research experiments must use an independent:

    train / validation / test

protocol.

---

## 11. Official SYSU MambaBCD-Tiny Checkpoint Inference

Model:

    MambaBCD-Tiny

Official checkpoint:

    MambaBCD_Tiny_SYSU_F1_0.8316.pth

Checkpoint MD5:

    95a894d72fda983bf12de4d090308a7c

Checkpoint type:

    collections.OrderedDict
    model state_dict only

Checkpoint loading:

    matched         514
    missing         0
    unexpected      0
    mismatched      0
    legacy_remapped 304

Inference results:

    Recall     0.7976
    Precision  0.8685
    OA         0.9238
    F1         0.8316
    IoU        0.7117
    Kappa      0.7824

Result:

    PASS

The reproduced F1 exactly matches the checkpoint filename:

    F1 = 0.8316

This validates the complete inference chain:

    environment
    -> ChangeMamba source
    -> Mamba/selective scan
    -> official checkpoint
    -> SYSU dataset
    -> evaluation

---

## 12. SYSU MambaBCD-Small Training

Training follows the released README recipe.

Model:

    MambaBCD-Small

Dataset:

    SYSU

Training configuration:

    batch size     16
    crop size      256
    max iterations 20000
    learning rate  1e-4
    weight decay   5e-3
    optimizer      AdamW
    eval interval  500

Config:

    changedetection/configs/vssm1/vssm_small_224.yaml

Encoder initialization:

    VMamba-Small ImageNet pretrained checkpoint

Pretrained encoder load:

    matched     398
    missing     8
    unexpected  4
    mismatched  0

Missing parameters:

    outnorm0.weight
    outnorm0.bias
    outnorm1.weight
    outnorm1.bias
    outnorm2.weight
    outnorm2.bias
    outnorm3.weight
    outnorm3.bias

Unexpected parameters belong to the ImageNet classification head:

    classifier.norm.weight
    classifier.norm.bias
    classifier.head.weight
    classifier.head.bias

No parameter shape mismatch was observed.

---

## 13. SYSU MambaBCD-Small Training Results

First evaluation at iteration 500:

    Recall     0.7514
    Precision  0.8466
    OA         0.9093
    F1         0.7961
    IoU        0.6613
    Kappa      0.7380

Final evaluation at iteration 20000:

    Recall     0.7679
    Precision  0.8900
    OA         0.9229
    F1         0.8245
    IoU        0.7014
    Kappa      0.7754

Best checkpoint:

    iteration = 2500

Selection metric:

    Kappa

Best checkpoint metrics:

    Recall     0.8075
    Precision  0.8648
    OA         0.9248
    F1         0.8352
    IoU        0.7170
    Kappa      0.7866

Training status:

    COMPLETED

The best checkpoint outperformed the final 20000-iteration model in F1,
IoU, and Kappa.

The late-stage model showed higher precision but lower recall, indicating
that the model became more conservative as training continued.

---

## 14. Current Reproduction Status

Validated:

    [OK] A800 CUDA 11.8 environment
    [OK] PyTorch / Mamba stack
    [OK] selective scan
    [OK] SYSU dataset
    [OK] WHU-CD dataset
    [OK] LEVIR-CD+ dataset
    [OK] official SYSU Tiny checkpoint inference
    [OK] SYSU Small training
    [OK] periodic evaluation
    [OK] best-checkpoint selection
    [OK] checkpoint saving

Pending:

    [ ] independent inference verification of SYSU Small best_model.pth
    [ ] official SYSU MambaBCD-Small checkpoint comparison
    [ ] WHU-CD official checkpoint inference
    [ ] WHU-CD training reproduction
    [ ] LEVIR-CD+ official checkpoint inference
    [ ] LEVIR-CD+ training reproduction

---

## 15. Next Actions

1. Independently infer SYSU using the locally trained Small best_model.pth.
2. Confirm that independent inference reproduces approximately:

       F1    0.8352
       Kappa 0.7866

3. Download the official SYSU MambaBCD-Small checkpoint.
4. Run the same inference protocol with the official Small checkpoint.
5. Compare official Small and reproduced Small under the same dataset and
   evaluation pipeline.
6. Continue with WHU-CD after SYSU reproduction is fully closed.
