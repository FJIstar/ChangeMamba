# WHU-CD ChangeMamba Reproduction Summary

## 1. Dataset

- Dataset: WHU-CD, 256x256 patch version
- Training samples: 4536
- Test samples: 2760
- Directory protocol: T1 / T2 / GT
- GT encoding: 0 / 255
- Test list: 2760 unique entries
- T1/T2/GT file consistency: PASS

## 2. Official MambaBCD-Tiny Inference

Checkpoint: MambaBCD_Tiny_WHU_F1_0.9409.pth

Checkpoint MD5:
08b24771a54869df4055b2d0a224e5bf

- Matched parameters: 514
- Missing / unexpected / mismatched: 0 / 0 / 0

Results:

- Recall: 0.9124
- Precision: 0.9600
- OA: 0.9955
- F1: 0.9356
- IoU: 0.8790
- Kappa: 0.9333

Note: The measured F1 differs from the checkpoint
filename value of 0.9409.

## 3. Official MambaBCD-Small Inference

Checkpoint: MambaBCD_Small_WHU_F1_0.9404.pth

Checkpoint MD5:
dc39834943e3a6985a8cca43985051a0

- Matched parameters: 712
- Missing / unexpected / mismatched: 0 / 0 / 0

Results:

- Recall: 0.9202
- Precision: 0.9589
- OA: 0.9958
- F1: 0.9391
- IoU: 0.8852
- Kappa: 0.9369

Note: The measured F1 differs from the checkpoint
filename value of 0.9404.

## 4. Local MambaBCD-Small Training

- Model: MambaBCD-Small
- Batch size: 16
- Crop size: 256
- Max iterations: 20000
- Optimizer: AdamW
- Learning rate: 1e-4
- Weight decay: 5e-3
- Encoder: VMamba-Small pretrained
- Evaluation interval: 500 iterations
- Selection metric: Kappa

Pretrained loading:

- Matched: 398
- Missing: 8
- Unexpected: 4
- Mismatched: 0

Training finished successfully.

Final iteration 20000:

- Recall: 0.9042
- Precision: 0.9621
- OA: 0.9953
- F1: 0.9323
- IoU: 0.8731
- Kappa: 0.9298

Best iteration 13000:

- Recall: 0.9199
- Precision: 0.9587
- OA: 0.9957
- F1: 0.9389
- IoU: 0.8849
- Kappa: 0.9367

Checkpoint best_score:
0.9367143519251685

## 5. Independent Inference Verification

The complete training checkpoint was exported to a pure
model state_dict containing 712 parameter keys.

Independent loading:

- Matched: 712
- Missing: 0
- Unexpected: 0
- Mismatched: 0

Independent inference:

- Recall: 0.9199
- Precision: 0.9587
- OA: 0.9957
- F1: 0.9389
- IoU: 0.8849
- Kappa: 0.9367

All six metrics match the training best checkpoint
to four decimal places.

Status: PASS

## 6. Official vs Local Comparison

| Metric | Official Small | Local Small |
|---|---:|---:|
| Recall | 0.9202 | 0.9199 |
| Precision | 0.9589 | 0.9587 |
| OA | 0.9958 | 0.9957 |
| F1 | 0.9391 | 0.9389 |
| IoU | 0.8852 | 0.8849 |
| Kappa | 0.9369 | 0.9367 |

F1 difference (local minus official): -0.0002

## 7. Protocol Limitations

The released training implementation uses the test split
for periodic evaluation and best-checkpoint selection.

Therefore this experiment reproduces the released-code
protocol, not an independent validation/test protocol.

The observed differences between checkpoint filename
metrics and measured metrics remain unresolved.

## 8. Final Status

WHU-Tiny official inference: PASS (pipeline)
WHU-Small official inference: PASS (pipeline)
WHU-Small training: PASS
WHU-Small checkpoint export: PASS
WHU-Small independent inference: PASS
Official/local Small comparison: COMPLETED

Next dataset: LEVIR-CD+
