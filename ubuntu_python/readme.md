Ubuntu 16 container with base Python distribution 

This container can be used as a base for Ubuntu based application installations.

The default Pythons 2 and 3 use OpenBLAS under numPy/sciPy.

Alternatively, one can load the Intel Python module from CHPC sys branch by ("ml intelpy/2.7.12" or "ml intelpy/3.5.2").

Tricky part is to have multi-threaded accelerated BLAS support for numPy/sciPy, done as follows:

- need to first install OpenBlas, then pip (separately for python2 and
  python3), then pip install SciPy, which will in turn install latest NumPy with
  OpenBLAS

Found a useful git page on timing different BLASes with numPy at 
https://github.com/gforsyth/openblas.vs.mkl

Here are timings for the largest matrix (2000x2000) in 
/uufs/chpc.utah.edu/common/home/u0101881/containers/singularity/containers/tests/paraview/numpy/openblas.vs.mkl
  OPENBLAS_NUM_THREADS=8 python3 mattest.py openblas 8
                                      container  native CHPC build w/ MKL
  scrubpeak stock blas, 1 thread only 1370 msec  
  scrubpeak OpenBLAS, 1 thread        1370 msec  2770 msec
  scrubpeak OpenBLAS, 8 threads        200 msec
  kp108 AVX OpenBLAS, 1 thread         664 msec 
  kp108 AVX OpenBLAS, 8 threads        104 msec
  kp300 AVX2 OpenBLAS, 1 thread        450 msec 
  kp300 AVX2 OpenBLAS, 8 threads       78.5msec

- with Intel Python (assuming LMod has been set up in the container):
  ml intelpy/3.5.2 
  MKL_NUM_THREADS=8 python mattest.py mkl 8
                                 container   native
  scrubpeak MKL, 1 thread        1370 msec 
  scrubpeak MKL, 8 threads        194 msec
  kp108 AVX MKL, 1 thread         661 msec   645 msec
  kp108 AVX MKL, 8 threads        98.3msec   101 msec
  kp300 AVX2 MKL, 1 thread        340 msec 
  kp300 AVX2 MKL, 8 threads       56.4msec
 
-> OpenBLAS as fast as MKL on SSE 4.2 machine, about the same on AVX machine, slower on AVX2 machine
-> OpenBLAS seems to allow for multiple code paths for different instruction sets

