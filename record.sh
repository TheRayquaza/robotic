lerobot-record \
    --robot.type=so101_follower \
    --robot.port="/dev/ttyACM0" \
    --robot.id=my_awesome_follower_arm \
    --robot.cameras='{"up": {"type": "opencv", "index_or_path": "/dev/video0", "width": 640, "height": 480, "fps": 30}, "side": {"type": "opencv", "index_or_path": "/dev/video3", "width": 640, "height": 480, "fps": 30}}' \
    --teleop.type=so101_leader \
    --teleop.port="/dev/ttyACM1" \
    --teleop.id=my_awesome_leader_arm \
    --display_data=true \
    --dataset.repo_id="therayquaza/grab_the_red_lock" \
    --dataset.num_episodes=10 \
    --dataset.single_task="Grab the red lock" \
    --policy.device=cuda \
    --policy.type="" \
    --policy.push_to_hub=true


---

lerobot-record \
    --robot.type=so101_follower \
    --robot.port=/dev/ttyACM1 \
    --robot.id=my_awesome_follower_arm \
    --robot.cameras="{ front: {type: opencv, index_or_path: 2, width: 640, height: 480, fps: 30}, wrist: {type: opencv, index_or_path: 0, width: 640, height: 480, fps: 30}}" \
    --teleop.type=so101_leader \
    --teleop.port=/dev/ttyACM0 \
    --teleop.id=my_awesome_leader_arm \
    --display_data=false \
    --dataset.reset_time_s=5 \
    --dataset.episode_time_s=15 \
    --dataset.num_episodes=10 \
    --dataset.repo_id=therayquaza/record-test2 \
    --dataset.single_task="Reach the pen" \
    --dataset.push_to_hub=true
