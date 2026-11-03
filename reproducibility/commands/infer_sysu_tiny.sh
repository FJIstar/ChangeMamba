#!/usr/bin/env bash
set -e

PROJECT=/root/autodl-tmp/projects/ChangeMamba
DATA=/root/autodl-tmp/data/ChangeMamba
CKPT=/root/autodl-tmp/checkpoints/ChangeMamba
RESULT=/root/autodl-tmp/results/ChangeMamba

cd "$PROJECT/changedetection"

python script/infer_MambaBCD.py \
  --dataset 'SYSU' \
  --model_type 'MambaBCD_Tiny' \
  --test_dataset_path "$DATA/SYSU/test" \
  --test_data_list_path "$DATA/SYSU/test_set.txt" \
  --cfg "$PROJECT/changedetection/configs/vssm1/vssm_tiny_224_0229flex.yaml" \
  --model_checkpoint_path "$CKPT/MambaBCD_Tiny_SYSU_F1_0.8316.pth" \
  --result_saved_path "$RESULT/SYSU_Tiny_official"
