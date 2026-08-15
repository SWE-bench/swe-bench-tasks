Thanks for the detailed bug report, it makes the bug easy to reproduce.

Best fix might be to use `.set_output(transform="default")` on the PCA estimator, to directly output a numpy array. PR welcome, bonus if you find other instances of this bug!