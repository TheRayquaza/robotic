import numpy as np
import matplotlib.pyplot as plt

from lerobot.common.datasets.lerobot_dataset import LeRobotDataset

# ============================================================
# Configuration
# ============================================================

HF_USER = "your_hf_username"      # <-- change this
DATASET_NAME = "so101_reach_task"
SPLIT = "train"

NUM_JOINTS = 6        # exclude gripper
NOISE_STD = 0.02      # Gaussian noise level
TEMPORAL_SHIFT = 2    # number of timesteps

# ============================================================
# 1. Load dataset
# ============================================================

dataset = LeRobotDataset.from_pretrained(
    f"{HF_USER}/{DATASET_NAME}",
    split=SPLIT,
)

print(f"Episodes: {dataset.num_episodes}, FPS: {dataset.fps}")

# ============================================================
# 2. Utility functions
# ============================================================

def compute_global_stats(dataset, num_joints, max_episodes=None):
    states_all = []
    actions_all = []

    n_eps = dataset.num_episodes
    if max_episodes is not None:
        n_eps = min(n_eps, max_episodes)

    for i in range(n_eps):
        ep = dataset.get_episode(i)
        states_all.append(ep["observation.state"])
        actions_all.append(ep["action"][:, :num_joints])

    states = np.concatenate(states_all, axis=0)
    actions = np.concatenate(actions_all, axis=0)

    return (
        states.mean(axis=0),
        states.std(axis=0) + 1e-8,
        actions.mean(axis=0),
        actions.std(axis=0) + 1e-8,
    )


def normalize(x, mean, std):
    return (x - mean) / std


def add_gaussian_noise(x, sigma):
    return x + np.random.normal(0.0, sigma, size=x.shape)


def temporal_shift(states, actions, shift):
    assert shift > 0
    return states[shift:], actions[:-shift]


# ============================================================
# 3. Compute normalization statistics
# ============================================================

state_mean, state_std, act_mean, act_std = compute_global_stats(
    dataset,
    num_joints=NUM_JOINTS,
)

# ============================================================
# 4. Load one episode (example)
# ============================================================

episode = dataset.get_episode(0)

states = episode["observation.state"]
actions = episode["action"][:, :NUM_JOINTS]  # exclude gripper

states_n = normalize(states, state_mean, state_std)
actions_n = normalize(actions, act_mean, act_std)

# ============================================================
# 5. Visualization BEFORE augmentation
# ============================================================

plt.figure(figsize=(12, 3))
plt.plot(actions_n[:, 0])
plt.title("Joint 1 action – normalized (original)")
plt.xlabel("Time")
plt.ylabel("Value")
plt.tight_layout()
plt.show()

# ============================================================
# 6. Augmentations
# ============================================================

# --- Augmentation 1: Gaussian noise ---
states_noise = add_gaussian_noise(states_n, NOISE_STD)
actions_noise = add_gaussian_noise(actions_n, NOISE_STD)

# --- Augmentation 2: Temporal shift ---
states_shift, actions_shift = temporal_shift(
    states_n, actions_n, TEMPORAL_SHIFT
)

# ============================================================
# 7. Visualization AFTER augmentation
# ============================================================

fig, axes = plt.subplots(3, 1, figsize=(12, 7), sharex=True)

axes[0].plot(actions_n[:, 0])
axes[0].set_title("Original normalized")

axes[1].plot(actions_noise[:, 0])
axes[1].set_title("Gaussian noise")

axes[2].plot(actions_shift[:, 0])
axes[2].set_title("Temporal shift")

plt.xlabel("Time")
plt.tight_layout()
plt.show()

# ============================================================
# 8. Build augmented LeRobot episodes
# ============================================================

augmented_episodes = []

augmented_episodes.append(
    {
        "observation.state": states_noise,
        "action": actions_noise,
    }
)

augmented_episodes.append(
    {
        "observation.state": states_shift,
        "action": actions_shift,
    }
)

# ============================================================
# 9. Create augmented LeRobot dataset
# ============================================================

aug_dataset = LeRobotDataset.from_episodes(
    episodes=augmented_episodes,
    fps=dataset.fps,
)

print(f"Augmented dataset episodes: {aug_dataset.num_episodes}")

# ============================================================
# 10. Sanity check
# ============================================================

aug_ep = aug_dataset.get_episode(0)

print("Augmented episode shapes:")
print("States:", aug_ep["observation.state"].shape)
print("Actions:", aug_ep["action"].shape)
