@DanielNoord Would you like to take a look at this? I'm unable to reproduce it with `main`.
I'm able to reproduce this.

Adding `pylint.extensions.docparams` to `load-plugins` and `no-docstring-rgx=__.*__` makes this warning emit for me.

I have a feeling it might be because of the `*` because the message reports it is missing for `args` instead of `*args`. I will take a look!