# base image
FROM ghcr.io/openkim/developer-platform:latest-minimal

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
RUN pip install torch==1.13.1+cpu --extra-index-url https://download.pytorch.org/whl/cpu
RUN pip install torch_geometric torch_scatter torch_sparse torch_cluster -f https://data.pyg.org/whl/torch-1.13.0+cpu.html
RUN pip install git+https://github.com/colabfit/colabfit-tools@aa2d1e3b160275cdb7d8734afdbbb4a570a92a94#egg=colabfit_tools
RUN pip install --no-cache-dir notebook jupyterlab

# install libdescriptor
WORKDIR /opt
RUN git clone -b MACH2023 https://github.com/ipcamit/libdescriptor \ 
 && cd libdescriptor \
 && pip install .
# Install C++ library for LAMMPS
RUN cd /opt/libdescriptor \ 
 && rm -rf build && mkdir build && cd build \
 && cmake ../ -DCMAKE_BUILD_TYPE=Release && make -j4 && make install\
 && cd /opt && rm -rf libdescriptor

# install Model driver
WORKDIR /opt
ENV KIM_MODEL_DISABLE_GRAPH=1
RUN git clone -b MACH2023 https://github.com/ipcamit/colabfit-model-driver \
 && cd colabfit-model-driver && cd .. \
 && kim-api-collections-management install system colabfit-model-driver \
 && rm -rf colabfit-model-driver
# Switch back to openkim env

WORKDIR /home/openkim
USER openkim

RUN git clone https://github.com/ipcamit/MACH2023 \
 && cd MACH2023 \
 && kim-api-collections-management install user SF__MO_000000000000_000

ENV SHELL=/bin/bash
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

