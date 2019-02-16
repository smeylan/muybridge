#!/bin/bash
#SBATCH -e slurm.err
#SBATCH -o slurm.out
#SBATCH -p artai-gpu --gres=gpu:1
#SBATCH --account=artai
#SBATCH --mem=10G
##SBATCH -c 8
module load Python-GPU/3.6.5
CUDA_VISIBLE_DEVICES=0 python pix2pix.py \
  --mode train \
  --output_dir muybridge_train \
  --max_epochs 200 \
  --input_dir continuous_runs/model_inputs/0/ \
  --which_direction BtoA \