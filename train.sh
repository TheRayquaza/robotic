python lerobot/src/lerobot/scripts/lerobot_train.py \
  --dataset.repo_id="ankithreddy/so101_pickplace_tools" \
  --policy.type="act" \
  --output_dir="outputs/bc2" \
  --policy.device="cuda" \
  --job_name="act_so101_test" \
  --policy.repo_id="therayquaza/policy_so101_pickplace_tools" \
  --steps=1000 \
  --batch_size=16
