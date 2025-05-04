# EECS645 - Computer Architecture Tutorial with gem5

This repository contains scripts and resources for running simple simulations using the gem5 simulator as part of the EECS645 (Introduction to Computer Architecture) course.

## Repository Structure

```
gem5-tutorial-EECS645/
├── ckpts/                   # Holds checkpoints taken during simulations
├── gem5/                    # Official gem5 repository
├── resources-linux/         # Boot loader and disk image for Linux (for full system simulations)
├── runDir/                  # Output directory for simulation results
├── guest-scripts/           # Scripts that run inside the simulated system
│   ├── read.sh              # Memory read benchmark
│   ├── write.sh             # Memory write benchmark
└── run-sim.sh               # Helper script for running gem5 simulations
```

## Setup Instructions

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/gem5-tutorial-EECS645.git
   cd gem5-tutorial-EECS645
   ```

2. Download the `resources-linux` folder from [OneDrive](https://kansas-my.sharepoint.com/:f:/g/personal/a972m888_home_ku_edu/EvoI4KKUdNdBsnKZAE04q0sBJy2FWsR0INKamLdbM_RyEA?e=EYQPyO).

3. Extract and place the `resources-linux` folder in the repository root directory.

4. Build gem5 (this may take some time):
   ```bash
   cd gem5
   scons build/ARM/gem5.fast -j4  # Replace 4 with the number of CPU cores on your machine
   cd ..
   ```