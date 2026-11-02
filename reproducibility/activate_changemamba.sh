#!/usr/bin/env bash

# ChangeMamba validated environment:
# PyTorch cu118 + CUDA Toolkit 11.8

export CUDA_HOME=/usr/local/cuda-11.8
export PATH=$CUDA_HOME/bin:$PATH

export TORCH_LIB=$CONDA_PREFIX/lib/python3.10/site-packages/torch/lib

export LD_LIBRARY_PATH=$TORCH_LIB:$CONDA_PREFIX/lib:$CUDA_HOME/lib64:${LD_LIBRARY_PATH:-}

echo "CUDA_HOME=$CUDA_HOME"
echo "TORCH_LIB=$TORCH_LIB"
echo "nvcc=$(which nvcc)"
