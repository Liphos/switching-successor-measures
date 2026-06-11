#!/bin/bash
#SBATCH --job-name=ssm_fb_sweep
#SBATCH --output=logs/ssm_fb_%A_%a.out
#SBATCH --error=logs/ssm_fb_%A_%a.err
#SBATCH --array=0-119
#SBATCH --time=08:00:00
#SBATCH --cpus-per-task=10
#SBATCH --gres=gpu:volta:1
#SBATCH --constraint=volta32gb
unset SLURM_CPU_BIND

# 1. Define Arrays
SEEDS=(3917 3502 8948 9460 4729 2226 1744 7742 4501 6341)
ENVS=("medium" "large" "giant")
ALPHAS=(0.03 0.1 0.3 1.0)

# 2. Map SLURM_ARRAY_TASK_ID (0-119) to Seed, Env and Alpha indices
#    layout: alpha is the fastest-varying index, then env, then seed.
ALPHA_IDX=$(( SLURM_ARRAY_TASK_ID % ${#ALPHAS[@]} ))
REST=$(( SLURM_ARRAY_TASK_ID / ${#ALPHAS[@]} ))
ENV_IDX=$(( REST % ${#ENVS[@]} ))
SEED_IDX=$(( REST / ${#ENVS[@]} ))

SEED=${SEEDS[$SEED_IDX]}
ENV=${ENVS[$ENV_IDX]}
ALPHA=${ALPHAS[$ALPHA_IDX]}

# Activate the project's local venv.
source .venv/bin/activate

# 3. Run a single clean srun step
srun python main.py \
    --env_name=ogbench-antmaze-${ENV}-navigate-v0 \
    --agent=agents/fb.py \
    --wandb_run_group=fb_sweep_alpha${ALPHA} \
    --agent.alpha=${ALPHA} \
    --seed="$SEED"