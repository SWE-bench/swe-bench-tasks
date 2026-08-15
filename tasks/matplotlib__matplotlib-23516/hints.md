Thank you for diagnosing and reporting this @adamjstewart 

> Raise an error/warning if cmap/vmin/vmax are given but c is not

I think this is the better option of the two.   It will capture some unintentional usage and I think will be less surprising in the long run.

https://github.com/matplotlib/matplotlib/blob/1e4bc521dd14535711ac2dd0142adb147a1ba251/lib/matplotlib/axes/_axes.py#L4557-L4561 is probably the right place to put the check and warning (which we should make an error in the future).


I think this is a good first issue because it does involve a little bit of API design, I do not think it will be controversial (warn the user we are dropping their input on the floor).

Steps:

 - add a check to the  code linked above to warn if any of `c`, `cmap`, `norm`, `vmin`, `vmax` are passed by the user and `colors` is not None
 - add a test
 - add an behavior change API change note.
Could this just error out at `set_array` if the array has never been used?  