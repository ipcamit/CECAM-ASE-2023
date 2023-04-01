# base image
FROM ghcr.io/openkim/developer-platform

# install APT packages
USER root
RUN apt-get update && apt-get install -y git unzip
RUN pip install pybind11-global

# Install libtorch
WORKDIR /opt
RUN curl https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.13.0%2Bcpu.zip --output libtorch.zip
RUN unzip libtorch.zip
RUN cp -r libtorch/include/* /usr/local/include \
 && cp -r libtorch/lib/* /usr/local/lib/ \
 && cp -r libtorch/share/* /usr/local/share/ \
 && rm -rf libtorch.zip libtorch
RUN pip install torch==1.13.1+cpu torchvision==0.14.1+cpu torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cpu
RUN pip install torch_geometric torch_scatter torch_sparse torch_cluster -f https://data.pyg.org/whl/torch-1.13.0+cpu.html
RUN pip install git+https://github.com/colabfit/colabfit-tools@aa2d1e3b160275cdb7d8734afdbbb4a570a92a94#egg=colabfit_tools

# install libdescriptor
WORKDIR /opt
RUN git clone https://github.com/ipcamit/libdescriptor \ 
 && cd libdescriptor \
 && git checkout 318f4dc95d2 \ 
 && pip install .
# Install C++ library for LAMMPS
RUN cd /opt/libdescriptor \ 
 && rm -rf build && mkdir build && cd build \
 && cmake ../ -DCMAKE_BUILD_TYPE=Release && make -j4 && make install

# install Model driver
WORKDIR /opt
RUN git clone https://github.com/ipcamit/colabfit-model-driver \
 && cd colabfit-model-driver && git checkout f22bb39c7f9 && cd ..
ENV KIM_MODEL_DISABLE_GRAPH=1
RUN kim-api-collections-management install system colabfit-model-driver
# Switch back to openkim env

WORKDIR /home/openkim
USER openkim

RUN git clone https://github.com/ipcamit/MACH2023 \
 && cd MACH2023 \
 && kim-api-collections-management install user SF__MO_000000000000_000
