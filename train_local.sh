CUDA_VISIBLE_DEVICES=0 python pix2pix.py \
  --mode train \
  --output_dir muybridge_train \
  --max_epochs 200 \
  --input_dir continuous_runs/model_inputs/0/ \
  --which_direction BtoA \