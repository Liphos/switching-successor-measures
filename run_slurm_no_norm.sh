#!/bin/bash
#SBATCH --job-name=ssm_fb_sweep
#SBATCH --output=logs/ssm_fb_%A_%a.out
#SBATCH --error=logs/ssm_fb_%A_%a.err
#SBATCH --array=0-29                    
#SBATCH --time=08:00:00
#SBATCH --cpus-per-task=10
#SBATCH --gres=gpu:volta:1              
#SBATCH --constraint=volta32gb
unset SLURM_CPU_BIND

# 1. Define Arrays
SEEDS=(3917 3502 8948 9460 4729 2226 1744 7742 4501 6341)
ENVS=("medium" "large" "giant")

# 2. Map SLURM_ARRAY_TASK_ID (0-29) to Seed and Env indices
SEED_IDX=$(( SLURM_ARRAY_TASK_ID / 3 ))
ENV_IDX=$(( SLURM_ARRAY_TASK_ID % 3 ))

SEED=${SEEDS[$SEED_IDX]}
ENV=${ENVS[$ENV_IDX]}

# Activate the project's local venv.
source .venv/bin/activate

# 3. Run a single clean srun step
srun python main.py \
    --env_name=ogbench-antmaze-${ENV}-navigate-v0 \
    --agent=agents/fb.py \
    --wandb_run_group=fb_lower_target_no_back_norm \
    --agent.backward_repr_norm_type="None" \
    --seed="$SEED"