Thanks for the report! Unfortunately I can't reproduce this. What version of numpy are you using when the warning appears?
Sorry, forgot to mention that you need to enable the warnings during normal execution, e.g., `python -W always <file>.py`. In my case, the warnings are issued during `pytest` run which seems to activate these warnings by default.

As for the NumPy version, I'm running
```console
$ python -c 'import numpy; print(numpy.__version__)'
1.24.0
```
Thanks, I can now reproduce 😄 
The problem is that there are three more values, that are by default out of range in this case, to note specific cases:
https://github.com/matplotlib/matplotlib/blob/8d2329ad89120410d7ef04faddba2c51db743b06/lib/matplotlib/colors.py#L673-L675
(N = 256 by default)

These are then assigned to out-of-range and masked/bad values here:
https://github.com/matplotlib/matplotlib/blob/8d2329ad89120410d7ef04faddba2c51db743b06/lib/matplotlib/colors.py#L730-L732
which now raises a deprecation warning.

I think that one way forward would be to check the type of `xa` for int/uint and in that case take modulo the maximum value for `self._i_over` etc. This is basically what happens now anyway, but we need to do it explicitly rather than relying on numpy doing it. (I cannot really see how this makes sense from a color perspective, but we will at least keep the current behavior.)
I think this is exposing a real bug that we need to promote the input data to be bigger than uint8.  What we are doing here is buildin a lookup up table, the first N entries are for for values into the actually color map and then the next 3 entries are the special cases for over/under/bad so `xa` needs to be big enough to hold `self.N + 2` as values.
I don't know if this is a bigger bug or not, but I would like us to have fixed any deprecation warnings from dependencies before 3.7 is out (or if necessary a quick 3.7.1.)