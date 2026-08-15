I.e. coefs_paths.ndim < 4? I haven't tried to reproduce yet, but thanks for
the minimal example.

Are you able to check if this was introduced in 0.21? 
Yes - the example above works with scikit-learn==0.20.3. Full versions:
```
System:
    python: 3.6.8 (default, Jun  4 2019, 11:38:34)  [GCC 4.2.1 Compatible Apple LLVM 10.0.1 (clang-1001.0.46.4)]
executable: /Users/tsweetser/.pyenv/versions/test/bin/python
   machine: Darwin-18.6.0-x86_64-i386-64bit

BLAS:
    macros: NO_ATLAS_INFO=3, HAVE_CBLAS=None
  lib_dirs:
cblas_libs: cblas

Python deps:
       pip: 18.1
setuptools: 40.6.2
   sklearn: 0.20.3
     numpy: 1.16.4
     scipy: 1.3.0
    Cython: None
    pandas: 0.24.2
```