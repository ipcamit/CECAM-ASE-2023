# MACH2023
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/ipcamit/MACH2023/HEAD)

Examples and tutorials for MACH 2023

Contains:
1. Simple descriptor based models
2. ASE and LAMMPS scripts
3. Simple Si configurations

For laptop usage, initialize the env by
```bash
source ./build_env.sh # source, as it sets env variables and alias as well
```
and select your enviroment OS etc. It will take few minutes for compiling everything, so grab a coffee in the mean maybe ¯\_(ツ)_/¯.
If it finds installed conda on the system, it can utilize it for creating the environment, but best is to use the provided micromamba local environment.

For docker env, just do 
```bash
# Run ubuntu image
docker run -it --mount type=bind,source="$(pwd)",target=/home/user ubuntu /bin/bash
# setup user account, conda creates issues in root user
apt update && apt install -y ca-certificates
useradd user && su user
bash
cd /home/user
echo linux | source ./build_env.sh
```

Prerequisite: curl
