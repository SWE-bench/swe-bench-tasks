Hi, I am a beginner and I am looking for the first issue to work on. Could I try to work on this one? Is there anyone else who started contributing? 
Thank you for the answer in advance. 
@dzht19 please go ahead!

The offending line is here:

https://github.com/pytest-dev/pytest/blob/9318b2cb7f81252fec215e1cce4c5de021bda180/src/_pytest/python_api.py#L343

`np.inf` should be replaced by `math.inf`, and the numpy import at the beginning of the function should be removed. Also we should fix our test suite: `TestApprox.test_error_messages` currently tests scalars, lists and numpy arrays, but it uses `importorskip` at the beginning, so we skip the tests if numpy is not installed. We should split the test into two: one which tests everything not-numpy related, and one which tests numpy-data and depends on numpy.
Hi @dzht19,

Any progress on this?
> Hi @dzht19,
> 
> Any progress on this?

Hi, Yes. I hope to finish till the end of the week. 