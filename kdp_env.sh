#!/bin/bash
set -e

# 1. Set base directory ------------------------------------------------------------
echo "Setting base directories..."
export BASE_DIR=$PWD
export MACH2023_PATH=$PWD/MACH2023
export MACH_INSTALL_PATH=$MACH2023_PATH/install_path

mkdir $MACH2023_PATH $MACH_INSTALL_PATH $MACH_INSTALL_PATH/bin

export PATH="$MACH_INSTALL_PATH/bin:"$PATH
# ------------------------------------------------------------------------------------

# 3. Install conda packages ----------------------------------------------------------
# Try the following commands:
echo openkim | sudo -S apt-get update && sudo apt-get install -y git unzip
echo openkim | sudo pip install pybind11-global
# Now base env is ready
# ------------------------------------------------------------------------------------

# 6. Install Python things -----------------------------------------------------------
echo "Installing Python packages..."
# pytorch and pyg
sudo pip install torch==1.13.1+cpu torchvision==0.14.1+cpu torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cpu
sudo pip install torch_geometric torch_scatter torch_sparse torch_cluster -f https://data.pyg.org/whl/torch-1.13.0+cpu.html

# KLIFF dependencies
# pip install ase markupsafe==2.0.1 edn_format==0.7.5 kim-edn==1.3.1 kim-property==2.4.0 kim-query==3.0.0 simplejson==3.17.2 matplotlib==3.3.4 pymongo==3.11.3 montydb==2.1.1
#  Jinja2==2.11.3 ? 
sudo pip install git+https://github.com/colabfit/colabfit-tools@aa2d1e3b160275cdb7d8734afdbbb4a570a92a94#egg=colabfit_tools
# ------------------------------------------------------------------------------------

# 7. Install KLIFF -------------------------------------------------------------------
echo "Installing KLIFF..."
# libdescriptor
cd $MACH_INSTALL_PATH
git clone -b MACH2023 https://github.com/ipcamit/libdescriptor
cd libdescriptor
# Install python extensions
sudo pip install .
# Install C++ library for LAMMPS
rm -rf build && mkdir build && cd build
cmake ../ -DCMAKE_BUILD_TYPE=Release
make -j4 && sudo make install

# KLIFF
cd $MACH_INSTALL_PATH
git clone https://github.com/ipcamit/KLIFF
cd KLIFF
sudo pip install -e .
# -------------------------------------------------------------------------------

# Model driver ----------------------------------------------------------------------
cd $MACH_INSTALL_PATH
# libtorch
curl -Ls https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.13.0%2Bcpu.zip --output libtorch.zip
unzip libtorch.zip
sudo cp -r libtorch/lib/* /usr/local/lib
sudo cp -r libtorch/include/* /usr/local/include
sudo cp -r libtorch/share/* /usr/local/share

git clone -b MACH2023 https://github.com/ipcamit/colabfit-model-driver
cd colabfit-model-driver && cd ..
export KIM_MODEL_DISABLE_GRAPH=1
kim-api-collections-management install user colabfit-model-driver
# -------------------------------------------------------------------------------

# get tutorial data --------------------------------------------------------------
cd $BASE_DIR
kim-api-collections-management install user SF__MO_000000000000_000
# -------------------------------------------------------------------------------

# Clean up -----------------------------------------------------------------------
echo "Cleaning up..."
sleep 3
cd $MACH_INSTALL_PATH
rm -rf libtorch libtorch.zip colabfit-portable-models
# -------------------------------------------------------------------------------

# Done! --------------------------------------------------------------------------
cd $MACH2023_PATH/MACH2023
echo "Done!"
