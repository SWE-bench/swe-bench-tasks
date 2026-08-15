@amueller I'm interested in working on this issue. May I know if you could share more details?
The imread function in scipy is deprecated, therefore we should not use it. I'm not sure if it's replaced by anything, or if we need to use PIL/pillow directly.
As per the Scipy document, `imread `is deprecated and it is suggested to use `imageio.imread` instead. Please share your thoughts if `imageio.imread` is fine or you would suggest using PIL/pillow directly? 
Hm... I guess we use pillow directly? @GaelVaroquaux @jnothman opinions?
So currently users of our imread need to have PIL or Pillow installed. We
should keep that assumption, for now. Which basically means we need to copy
the implementation of scipy.misc.imread. We could extend this to
allowing imageio to be installed instead in the future.

Thank you for the suggestion @jnothman. As suggested, have implemented the changes and created the PR.
I got something similar for basic image processing included in LFW fetcher: 

```
`imresize` is deprecated in SciPy 1.0.0, and will be removed in 1.2.0.
Use ``skimage.transform.resize`` instead.
```

Do we want to keep using PIL in this case (http://pillow.readthedocs.io/en/4.3.x/reference/Image.html#PIL.Image.Image.resize)?
Is there anyone currently working on this? The pull request by @keyur9 seems to be incomplete and inactive. I would love to take a shot at this but I don't want to step on anyone's toes.
Hello @jotasi , feel free to work on this as I'll not be able to work on this until the weekend. Thank you,