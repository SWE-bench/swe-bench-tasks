Travis build log for OP: [log.txt](https://github.com/sympy/sympy/files/1558636/log.txt)

```
============================= test process starts ==============================
executable:         /home/travis/miniconda/envs/test-environment/bin/python  (2.7.14-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       gmpy 2.0.8
numpy:              1.13.3
random seed:        92237207
hash randomization: on (PYTHONHASHSEED=19927661)
```
https://travis-ci.org/sympy/sympy/jobs/316084624

```
============================= test process starts ==============================
executable:         /home/travis/miniconda/envs/test-environment/bin/python  (2.7.14-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       gmpy 2.0.8
numpy:              1.13.3
hash randomization: on (PYTHONHASHSEED=1928146661)
```
https://travis-ci.org/sympy/sympy/jobs/315883485

```
============================= test process starts ==============================
executable:         /home/travis/virtualenv/python2.7.14/bin/python  (2.7.14-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       python 
numpy:              None
hash randomization: on (PYTHONHASHSEED=526763854)
```
https://travis-ci.org/sympy/sympy/jobs/315817569

```
============================= test process starts ==============================
executable:         /home/travis/miniconda/envs/test-environment/bin/python  (2.7.14-final-0) [CPython]
architecture:       64-bit
cache:              yes
ground types:       gmpy 2.0.8
numpy:              1.13.3
hash randomization: on (PYTHONHASHSEED=2215473045)
```
https://travis-ci.org/sympy/sympy/jobs/315714158
CC @valglad 
Will look into it. Seems to be something in the `reduce` method in `rewritingsystem.py`.