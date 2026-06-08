#!/bin/bash
#SBATCH --job-name=ssm_fb_medium
#SBATCH --output=logs/ssm_fb_medium_%A_%a.out
#SBATCH --error=logs/ssm_fb_medium_%A_%a.err
#SBATCH --array=0-9
#SBATCH --time=08:00:00
#SBATCH --cpus-per-task=10
#SBATCH --gres=gpu:volta:1
#SBATCH --constraint=volta32gb

SEEDS=(3917 3502 8948 9460 4729 2226 1744 7742 4501 6341)
SEED=${SEEDS[$SLURM_ARRAY_TASK_ID]}

# Activate the project's local venv.
source .venv/bin/activate

python main.py --env_name=ogbench-antmaze-medium-navigate-v0 --agent=agents/fbpiswitch.py --train_steps=500_000 --agent.frozen_path="/checkpoint/glevy/fb_hier/sd3502_s_64119910.0.20260604_163929" --agent.high_alpha=1e-3  --seed="$SEED"
