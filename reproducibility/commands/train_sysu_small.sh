#!/usr/bin/env bash
set -e

PROJECT=/root/autodl-tmp/projects/ChangeMamba
DATA=/root/autodl-tmp/data/ChangeMamba
CKPT=/root/autodl-tmp/checkpoints/ChangeMamba

cd "$PROJECT/changedetection"

python script/train_MambaBCD.py \
  --dataset 'SYSU' \
  --batch_size 16 \
  --crop_size 256 \
  --max_iters 20000 \
  --model_type 'MambaBCD_Small' \
  --model_param_path "$CKPT/train_SYSU_Small" \
  --train_dataset_path "$DATA/SYSU/train" \
  --train_data_list_path "$DATA/SYSU/train_set.txt" \
  --test_dataset_path "$DATA/SYSU/test" \
  --test_data_list_path "$DATA/SYSU/test_set.txt" \
  --cfg "$PROJECT/changedetection/configs/vssm1/vssm_small_224.yaml" \
  --encoder_pretrained_path "$CKPT/pretrained/vssm_small_0229_ckpt_epoch_222.pth"
