# This was needed because importing pytorch with libtorch in LD_LIBRARY_PATH results in a segfault
export LD_LIBRARY_PATH=/opt/libtorch/lib:$LD_LIBRARY_PATH
