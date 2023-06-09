#!/bin/bash
# Literate programming can't get here fast enough...  Please see build_env.md
# for a detailed explanation of what is going on here.
set -e
# 1. Set base directory ------------------------------------------------------------
echo "Setting base directories..."
export BASE_DIR=$PWD
export MACH2023_PATH=$PWD/MACH2023
export MACH_INSTALL_PATH=$MACH2023_PATH/install_path
export PATH="$MACH_INSTALL_PATH/bin:"$PATH

mkdir $MACH2023_PATH $MACH_INSTALL_PATH $MACH_INSTALL_PATH/bin

# 2. If no conda, install it --------------------------------------------------------
# Check if conda is installed, ask user for new env if installed
echo "Installing micromamba"
# using micromamba to keep things localized
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
# ------------------------------------------------------------------------------------

# 3. Install conda packages ----------------------------------------------------------
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

# Now base env is ready
# ------------------------------------------------------------------------------------

# 4. Install KIM API -----------------------------------------------------------------
echo "Installing KIM API..."

cd $MACH_INSTALL_PATH
git clone https://github.com/openkim/kim-api
cd kim-api && mkdir build && cd build
export KIM_API_CONFIGURATION_FILE=$MACH_INSTALL_PATH/kim-config
export KIM_API_USER_CONFIGURATION_FILE=$MACH_INSTALL_PATH/kim-config
cmake -DCMAKE_INSTALL_PREFIX=$MACH_INSTALL_PATH .. -DCMAKE_BUILD_TYPE=Release -DKIM_API_USER_CONFIGURATION_FILE=$KIM_API_USER_CONFIGURATION_FILE
make -j2 && make install
# Try basic commands
source kim-api-activate
kim-api-collections-management install system SW_StillingerWeber_1985_Si__MO_405512056662_006
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MACH_INSTALL_PATH/lib
# ------------------------------------------------------------------------------------

# 5. Install LAMMPS ------------------------------------------------------------------
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
# ------------------------------------------------------------------------------------

# 6. Install Python things -----------------------------------------------------------
echo "Installing Python packages..."
sleep 2
# pytorch and pyg
pip install torch==1.13.1+cpu torchvision==0.14.1+cpu torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cpu
pip install torch_geometric torch_scatter torch_sparse torch_cluster -f https://data.pyg.org/whl/torch-1.13.0+cpu.html

# KLIFF dependencies
pip install ase markupsafe==2.0.1 edn_format==0.7.5 kim-edn==1.3.1 kim-property==2.4.0 kim-query==3.0.0 simplejson==3.17.2 matplotlib==3.3.4 pymongo==3.11.3 montydb==2.1.1
#  Jinja2==2.11.3 ? 
pip install kimpy git+https://github.com/colabfit/colabfit-tools@aa2d1e3b160275cdb7d8734afdbbb4a570a92a94#egg=colabfit_tools
# ------------------------------------------------------------------------------------

# 7. Install KLIFF -------------------------------------------------------------------
echo "Installing KLIFF..."
sleep 2
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
# -------------------------------------------------------------------------------

# Model driver ----------------------------------------------------------------------
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
# -------------------------------------------------------------------------------

# get tutorial data --------------------------------------------------------------
cd $MACH2023_PATH
git clone https://github.com/ipcamit/MACH2023
cd MACH2023
kim-api-collections-management install system SF__MO_000000000000_000
# -------------------------------------------------------------------------------

# Clean up -----------------------------------------------------------------------
echo "Cleaning up..."
cd $MACH_INSTALL_PATH
rm -rf kim-api lammps-stable_23Jun2022 lammps.tar.gz libtorch libtorch.zip colabfit-portable-models
# -------------------------------------------------------------------------------

# Done! --------------------------------------------------------------------------
cd $MACH2023_PATH/MACH2023
echo "Done!"
