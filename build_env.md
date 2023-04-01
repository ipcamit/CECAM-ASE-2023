<!-- #!/bin/bash -->
## Build env for MACH 2023 KLIFF Tutorial
This is a work in progress, but it should work for now.
This script is meant to be run on a fresh Ubuntu 20.04 install. And probably MacOS, but who knows.

Every command below is explained with its purpose, in hope that if something
 goes wrong, you can diagnose by looking for the intended effect of the line.

`set -e` will exit the script if any command fails, just some insurance. 
Should work for bash shell, if it gives issue, kindly switch to bash shell.
```bash
set -e
```
Before going forward, it expects that your system wil have these to necessary
 prerequisites: bzip2, curl. Most likely they will come preinstalled in your 
 system. If not, on Mac you need `brew install bzip2`, on Linux, you can use
 the provided gzip compressed binary I included in this repo.

# ------------------------------------------------------------
### 1. Set base directory 
Everything is installed in a MACH2023 directory, which is created in the current
 directory. The install path is set to `MACH2023/install_path`. The `install_path/bin`
 is added to the PATH variable, so that the executables can be found.
 If things go south, you can always delete the MACH2023 directory and start over. The variables to the directories are: `BASE_DIR`, `MACH2023_PATH`, `MACH_INSTALL_PATH`.

```bash
echo "Setting base directories..."
export BASE_DIR=$PWD
export MACH2023_PATH=$PWD/MACH2023
export MACH_INSTALL_PATH=$MACH2023_PATH/install_path
export PATH="$MACH_INSTALL_PATH/bin:"$PATH

mkdir $MACH2023_PATH $MACH_INSTALL_PATH $MACH_INSTALL_PATH/bin
```

# ------------------------------------------------------------
### 2. If no conda, install it 
Instead of using conda, I am using micromamba, which is a lightweight version of conda.
Biggest benefit of micromamba is that it does not require admin privileges to install, and remains contained in the directory it is installed in.
If you want to use conda, you can skip this step, and just install the packages in the next step.
All the packages are installed in the `MACH2023/install_path/env` directory.
Here the script will ask you for your OS, and will download the appropriate
 micromamba binary. Linux binary is downloaded from the repo. If it gives you
 you can comment out line #56 #57 and uncomment line line #55.

```bash
echo "Installing micromamba"
mkdir $MACH_INSTALL_PATH/env
cd $MACH_INSTALL_PATH
# Get OS infor from user for install
echo "What is your platform (Note WSL==linux)? [linux, mac_arm64, mac_intel, win]"
read  -r OS 

# if Linux:
if [ "$OS" = "linux" ]; then
    #curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba
    cp $BASE_DIR/micromamba_bin/linux.tar.gz .
    tar -xvf linux.tar.gz
# if mac_arm64:
elif [ "$OS" = "mac_arm64" ]; then
    echo "WARNING: LIBTORCH IS NOT SUPPORTED ON ARM64 MACS"
    echo "So, you will not be able to run the examples on LAMMPS"
    echo "See:"
    echo "https://github.com/pytorch/pytorch/issues/63558#issuecomment-1066916150"
    curl -Ls https://micro.mamba.pm/api/micromamba/osx-arm64/latest | tar -xvj bin/micromamba
# if mac_intel:
elif [ "$OS" = "mac_intel" ]; then
    curl -Ls https://micro.mamba.pm/api/micromamba/osx-64/latest | tar -xvj bin/micromamba
# if win:
elif [ "$OS" = "win" ]; then
    echo "Please install micromamba manually"
    echo "Instructions: https://mamba.readthedocs.io/en/latest/installation.html"
    exit 0
else
    echo "Invalid OS, exiting..."
    exit 0
fi
# Install micromamba

export MAMBA_ROOT_PREFIX=$MACH_INSTALL_PATH/env  # optional, defaults to ~/micromamba
eval "$($MACH_INSTALL_PATH/bin/micromamba shell hook -s bash)"

micromamba activate
```
# ------------------------------------------------------------

### 3. Install conda packages 

These packages might be already installed in your system, but it is better to
 install them in a conda environment, so that they do not interfere with the
 system packages. If you want to skip this step, check the available packages 
 in your system and install the ones missing.
```bash
# Try the following commands:
# gcc --version
# gfortran --version
# g++ --version
# python --version
# make --version
# cmake --version
# git --version
# pkg-config --version

# If any of these fail, you need to install them
# if gcc < 11.0.0, then preferably install the latest packages from conda
echo "Installing conda packages..."
micromamba install cxx-compiler gfortran make cmake git python=3.10 pkg-config unzip pybind11 jupyterlab -y -c conda-forge
```
Now base env is ready.

# ------------------------------------------------------------
### 4. Install KIM API 
For minimal headache, I am installing the KIM API from source. It is a pretty 
straight forward process. The KIM API is installed in the `MACH2023/install_path` directory. The configuration file is kept in the same directory.
As a sanity check, I am trying to install a model from the KIM API collection.
```bash
echo "Installing KIM API..."

cd $MACH_INSTALL_PATH
git clone https://github.com/openkim/kim-api
cd kim-api && mkdir build && cd build

export KIM_API_CONFIGURATION_FILE=$MACH_INSTALL_PATH/kim-config
export KIM_API_USER_CONFIGURATION_FILE=$MACH_INSTALL_PATH/kim-config

cmake -DCMAKE_INSTALL_PREFIX=$MACH_INSTALL_PATH .. -DCMAKE_BUILD_TYPE=Release -DKIM_API_USER_CONFIGURATION_FILE=$KIM_API_USER_CONFIGURATION_FILE
make -j2 && make install

source kim-api-activate
kim-api-collections-management install system SW_StillingerWeber_1985_Si__MO_405512056662_006
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MACH_INSTALL_PATH/lib
```

# ------------------------------------------------------------
### 5. Install LAMMPS 
Installing LAMMPS from scratch. Its straight forward, so I am not going to explain it. Some packages are installed "just in case".
```bash
echo "Installing LAMMPS..."

curl -Ls https://github.com/lammps/lammps/archive/refs/tags/stable_23Jun2022.tar.gz --output $MACH_INSTALL_PATH/lammps.tar.gz
cd $MACH_INSTALL_PATH
tar -xvf lammps.tar.gz
cd lammps-stable_23Jun2022

mkdir build && cd build
cmake ../cmake -DCMAKE_BUILD_TYPE=Release \
               -DBUILD_MPI=no -DBUILD_OMP=yes\
               -DPKG_EXTRA-MOLECULE=on -DPKG_EXTRA-PAIR=on\
               -DPKG_KIM=on -DDOWNLOAD_KIM=no\
               -DPKG_KSPACE=on -DPKG_MANYBODY=on\
               -DPKG_MEAM=on -DPKG_MISC=on\
               -DPKG_MOLECULE=on -DPKG_QEQ=on\
               -DPKG_MOLFILE=on -DCMAKE_INSTALL_PREFIX=$MACH_INSTALL_PATH
make -j2 && make install
```

# ------------------------------------------------------------
### 6. Install Python things 
Installing required Python packages. I am using `pip` to install the packages.
It consists of PyTorch, PyG, some KLIFF dependencies and some tools that might be useful for KIM.

```bash
echo "Installing Python packages..."

# pytorch and pyg
pip install torch==1.13.1+cpu torchvision==0.14.1+cpu torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cpu
pip install torch_geometric torch_scatter torch_sparse torch_cluster -f https://data.pyg.org/whl/torch-1.13.0+cpu.html

# KLIFF dependencies
pip install ase markupsafe==2.0.1 edn_format==0.7.5 kim-edn==1.3.1 kim-property==2.4.0 kim-query==3.0.0 simplejson==3.17.2 matplotlib==3.3.4 pymongo==3.11.3 montydb==2.1.1
#  Jinja2==2.11.3 ? 
pip install kimpy git+https://github.com/colabfit/colabfit-tools@aa2d1e3b160275cdb7d8734afdbbb4a570a92a94#egg=colabfit_tools
```

# ------------------------------------------------------------
### 7. Install KLIFF 
Installing KLIFF from source. It is a pretty straight forward process. 
First we need to install the `libdescriptor` library, which will be built as a python extension and a C++ library for LAMMPS.
Then we install KLIFF.

```bash
echo "Installing KLIFF..."

# libdescriptor
cd $MACH_INSTALL_PATH
git clone -b MACH2023 https://github.com/ipcamit/libdescriptor

cd libdescriptor
# Install python extensions
pip install .

# Install C++ library for LAMMPS
rm -rf build && mkdir build && cd build
cmake ../ -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$MACH_INSTALL_PATH
make -j2 && make install

# KLIFF
cd $MACH_INSTALL_PATH
git clone https://github.com/ipcamit/KLIFF
cd KLIFF
pip install -e .
```

# ------------------------------------------------------------
### Model driver
To execute the KLIFF trained models in LAMMPS and using ASE we would need the model driver.
Fortunately, installing is is simply letting the KIM-API handle it.
I am setting the `KIM_MODEL_DISABLE_GRAPH` environment variable to `1` to avoid the the C++ graph library dependency (`libtorchscatter` and `libtorchsparse`). This way you would not use the graph based models in LAMMPS, but it simplifies the installation process. For the C++ inference we also need `libtorch C++ ABI`. Unfortunately the Arm64 MacOS does not have universal binaries for `libtorch`, and workaround is bit involved: `https://github.com/pytorch/pytorch/issues/63558#issuecomment-1066916150`

```bash
cd $MACH_INSTALL_PATH
# libtorch for linux and mac_intel 
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    curl -Ls https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.13.0%2Bcpu.zip --output libtorch.zip
elif [[ "$OSTYPE" == "darwin"* ]]; then
    curl -Ls https://download.pytorch.org/libtorch/cpu/libtorch-macos-1.13.0.zip --output libtorch.zip
fi 
unzip libtorch.zip
cp -r libtorch/lib/* $MACH_INSTALL_PATH/lib
cp -r libtorch/include/* $MACH_INSTALL_PATH/include
cp -r libtorch/share/* $MACH_INSTALL_PATH/share

git clone -b MACH2023 https://github.com/ipcamit/colabfit-model-driver
cd colabfit-model-driver && cd ..

export KIM_MODEL_DISABLE_GRAPH=1
export LIBDESCRIPTOR_ROOT=$MACH_INSTALL_PATH

kim-api-collections-management install system colabfit-model-driver
```

# ------------------------------------------------------------
### Finally get tutorial data and install example model
```bash
cd $MACH2023_PATH
git clone https://github.com/ipcamit/MACH2023
cd MACH2023
kim-api-collections-management install system SF__MO_000000000000_000
```

### Clean up 

```bash
echo "Cleaning up..."
cd $MACH_INSTALL_PATH
rm -rf kim-api lammps-stable_23Jun2022 lammps.tar.gz libtorch libtorch.zip colabfit-portable-models
```

### Done!
```bash
cd $MACH2023_PATH/MACH2023
echo "Done!"
```
