I wonder if this change https://github.com/sympy/sympy/pull/15367 caused this.
Looks like it.

Please note that using a math environment (like `equation*`) is a step into the wrong direction, see #15329.
:white_check_mark:

Hi, I am the [SymPy bot](https://github.com/sympy/sympy-bot) (v134). I'm here to help you write a release notes entry. Please read the [guide on how to write release notes](https://github.com/sympy/sympy/wiki/Writing-Release-Notes).



Your release notes are in good order.

Here is what the release notes will look like:
* printing
  * change from `$$`...`$$` to `$\displaystyle `...`$` to allow left-aligning in LaTeX documents ([#15329](https://github.com/sympy/sympy/pull/15329) by [@mgeier](https://github.com/mgeier))

This will be added to https://github.com/sympy/sympy/wiki/Release-Notes-for-1.4.

Note: This comment will be updated with the latest check if you edit the pull request. You need to reload the page to see it. <details><summary>Click here to see the pull request description that was parsed.</summary>

    #### References to other Issues or PRs

    Same thing for IPython: https://github.com/ipython/ipython/pull/11357

    Somewhat related: https://github.com/jupyter/nbconvert/pull/892

    #### Brief description of what is fixed or changed

    Change the LaTeX wrapping from `$$`...`$$` to `$\displaystyle `...`$`

    #### Other comments

    This left-aligns expressions when exporting to LaTeX.

    Before:

    ![grafik](https://user-images.githubusercontent.com/705404/46369833-5642c800-c684-11e8-9d11-600ab87c3dc2.png)

    After:

    ![grafik](https://user-images.githubusercontent.com/705404/46369898-7bcfd180-c684-11e8-8e71-275a7ba45bca.png)

    #### Release Notes

    <!-- BEGIN RELEASE NOTES -->
    * printing
      * change from `$$`...`$$` to `$\displaystyle `...`$` to allow left-aligning in LaTeX documents
    <!-- END RELEASE NOTES -->


</details><p>

Does this work across Jupyter, IPython, qt-console, i.e. anything we expecting `init_printing()` to work with? And, will it print correctly in older versions of the mentioned software or just the latest IPython release?
@moorepants Good question! I'll try a few and will show the results here.

Jupyter Notebook, release 4.0.5 from September 2015:

![grafik](https://user-images.githubusercontent.com/705404/46372191-b5a3d680-c68a-11e8-8129-0e16ad58d507.png)

Jupyter QtConsole, release 4.0.1 from August 2015: 

![grafik](https://user-images.githubusercontent.com/705404/46372865-9ad26180-c68c-11e8-9701-8a82d540b696.png)

That's all for now, what else should be supported?
For me the LaTeX in the notebook is already left aligned. Did this change recently? What version of the notebook do you have? 

I know it was broken recently in jupyterlab, but they fixed it https://github.com/jupyterlab/jupyterlab/issues/5107
Oh I see, it only affects the LaTeX conversion. It seems like it would be better to fix this in nbconvert, so that the LaTeX conversion for equations automatically converts it to displaystyle, so that it matches the appearance in the browser. 
@asmeurer Yes, I'm talking about conversion to LaTeX, but I think it actually makes more sense for HTML, too, because MathJax doesn't have to be forced to the left. With this PR the jupyterlab PR https://github.com/jupyterlab/jupyterlab/issues/5107 will become obsolete and should probably be reverted.

With "fix this in nbconvert", do you mean that `nbconvert` should parse the strings, check which LaTeX delimiters are used and change them to something else? This sounds very brittle to me.
> @asmeurer Yes, I'm talking about conversion to LaTeX, but I think it actually makes more sense for HTML, too, because MathJax doesn't have to be forced to the left. With this PR the jupyterlab PR jupyterlab/jupyterlab#5107 will become obsolete and should probably be reverted.

Doesn't the HTML nbconvert produce the exact same output as the notebook running in the browser? If the math is centered there that would definitely be a bug in nbconvert because it isn't in the live notebook.

> With "fix this in nbconvert", do you mean that nbconvert should parse the strings, check which LaTeX delimiters are used and change them to something else? This sounds very brittle to me.

Yes, but only do it specifically for text/latex outputs. It wouldn't be brittle because the notebook is very structured. For instance, here's a cell from a notebook (running `sympy.sqrt(8)`):

```json
  {
   "cell_type": "code",
   "execution_count": 3,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "image/png": "iVBORw0KGgoAAAANSUhEUgAAACUAAAAVBAMAAAAzyjqdAAAAMFBMVEX///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAv3aB7AAAAD3RSTlMAIpm7MhCriUTv3c12VGZoascqAAAACXBIWXMAAA7EAAAOxAGVKw4bAAAA+UlEQVQYGWWQsUoDQRCGvz28mNxdggZstDkipBMC+gAhL+BWFjamsbFRbFKpV9ppq2muUUvxCYLWASVPYGerwWCwucysF4jcwP4z38eyDAsLZTKtzwUDpeQfOtgoKraKzk+LznvLnWlst/NxH+qbOwJ7LE9zd47f5SKBQ7j5c35KyVK5hls4bjsZvVMR/Q0Dq+5SbADhxDmBRxv1pQ3d7WCirfzD2msCqQJXJ5pBFw5a1Bxwr4qGHO+LwCp4sWakacZ8KPDicoRZkX3snVI1ZhWWYiJxu2exug48w3rv9Egg7Otz5qHXTGXnLPsVqo4lCOXrxc3raT7ADIVyN2pPS3LmAAAAAElFTkSuQmCC\n",
      "text/latex": [
       "$$2 \\sqrt{2}$$"
      ],
      "text/plain": [
       "2⋅√2"
      ]
     },
     "execution_count": 3,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "import sympy\n",
    "sympy.sqrt(8)"
   ]
  },
```

You can see the LaTeX is in the "text/latex" output of "outputs", which the notebook renders with MathJax.  So my suggestion is for nbconvert to replace `$$ ... $$` in a `text/latex` output with `$\displaystyle ... $` as part of its conversion. That will fix all applications that produce LaTeX output to look exactly the same in the pdf conversion as it does in the browser, as opposed to your change that only affects things that use the IPython `Math` class or SymPy specifically. 
I guess one brittle thing is that the notebook uses CSS to force the math to always be left aligned, whereas this would only affect things using `$$`. So you would have to check for other things as well, like `\[` or even `\begin{equation}`. I don't know if one can transform things in general just by changing the math code. 

But maybe the layout can be changed with some code in the LaTeX template for the pdf converter (but again, in such a way that it only affects the math that is part of a text/latex output). I don't know enough LaTeX to know if this is possible, though I suspect it is. 
@asmeurer 

> So my suggestion is for nbconvert to replace `$$ ... $$` in a text/latex output with `$\displaystyle ... $` as part of its conversion. That will fix all applications that produce LaTeX output to look exactly the same in the pdf conversion as it does in the browser, as opposed to your change that only affects things that use the IPython Math class or SymPy specifically.

This suggestion would "fix" an error that could be avoided in the first place. Let me illustrate:

Your suggestion:

* SymPy/IPython produce `$$...$$`, which doesn't show their intent, because in TeX this shows a centered equation separated from the surrounding text.

* HTML: MathJax emulates parts of LaTeX and TeX, so it has to be artificially forced to display the thing left-aligned which originally would be centered.

* LaTeX: The output string has either to be analyzed and re-written with different delimiters or it has to be coaxed into left-aligning with some dark TeX magic.

My suggestion:

* SymPy/IPython should produce `$\displaystyle ...$`, which is the *natural* way in LaTeX to get left-aligned math that is still not squeezed to fit into a line height.

* HTML: MathJax emulates LaTeX, so it displays the result as intended

* LaTeX: Well LaTeX *is* LaTeX, so obviously the result looks as intended

Sure, SymPy and IPython would have to be changed for that, but it is literally a one-line change (see this PR and https://github.com/ipython/ipython/pull/11357/files).

The advantage of my suggestion is that it is the *natural* way to do it. If an application/tool/library does it in an unnatural way, it should be changed. Future tools should just do it right in the first place.

Applications/tools/libraries that show LaTeX output in a natural way will be fine, no change needed. Future tools should again just do the natural thing.

> Doesn't the HTML nbconvert produce the exact same output as the notebook running in the browser? If the math is centered there that would definitely be a bug in nbconvert because it isn't in the live notebook.

Yes, the HTML generated by `nbconvert` forces MathJax equations to the left (using the CSS class `.MathJax_Display` and `text-align: left !important;`). With my suggestion, it wouldn't need to, but it would still continue to work even without changes.

> But maybe the layout can be changed with some code in the LaTeX template for the pdf converter

Maybe. I have no idea how to do this. I think only a TeX expert would be able to pull this off and I guess the TeX code wouldn't be pretty. Does anyone who reads this know how to do that?

The problem with your suggestion is that every tool that wants to display notebooks (be it in HTML or LaTeX or whatever else) has to jump through hoops to show LaTeX output. But this would be really simple if the math expressions would use a LaTeX syntax that actually expresses the intent.
I'd like to hear the thoughts of the Jupyter folks on this one. Your argument is basically that `$$...$$` should be centered, but the notebook makes it left aligned, partly because things like SymPy produce it and it's annoying for those use-cases. I would argue that it's annoying for any math output use-case, and that the notebook is right to make this alignment change. I think we can both agree that regardless which option is chosen the pdfs produced by nbconvert should be formatted the same as the HTML notebook.

I've opened an upstream issue at https://github.com/jupyter/notebook/issues/4060. Let's move the discussion there.