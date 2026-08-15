I should probably add that many of these instances are probably from documentation, so the effort to implement it will not be to manually change 169 instances.
I think that \text and \mathrm are intended for different kinds of use. \mathrm is used for symbols like 'sin' that contain typically only a few letters. \text is used for non-mathematical comments like 'otherwise', and the font is the current font used outside math.
There is also `\operatorname` which seems to be the best of two worlds. When it comes to operator names. This is used 183 times. So maybe it is less of a issue than I initially thought.

The main problem with `\mathrm` as I see it is if you are using your equations in a presentation with Beamer and the template is using a san-serif font. In this case all math will also be using a sans font, including sin etc, except for stuff put in `\mathrm` (one can of course redefine that font as well, but that doesn't seem like the right thing to do.

Looking a bit more into it, the current usage of `\mathrm` consists of primarily these classes:
 * To make a d in e.g. dt for an integral or differential non-italic (can be argued what the best way is) (primarily in documentation, but maybe whatever the correct way is should be used in the code?)
 * For "for" (should be text, in documentation, `\text` is used in printing)
 * For some specific functions (in documentation), should most of the time be operatorname instead
 * For some constants in core, like NaN and True. I think this is not correct as there is not point in having NaN in Roman in an otherwise non-Roman equation

So should be quite manageable. 
It is my understanding that \operatorname will also use a math font (\mathrm, I think) but will also add automatic space around the name in question, so "\operatorname{sin}x" will print "sin", a (thin) space and "x".
You may be correct. I'll try to confirm my (old) experience with Beamer etc and see what I get out of that.
I believe our LaTeX printer already assumes amsmath is used in several places. I don't use LaTeX much, but are there instances where amsmath can't be used? 
I remembered correctly. This is an output from beamer with the different options:
![image](https://user-images.githubusercontent.com/8114497/52373097-25233b80-2a5a-11e9-8d26-d74860eda71f.png)
This shows quite clearly why `\mathrm` isn't a good idea (and why `\operatorname` is better for operators, as it uses the same spacing). The other spacing one can somehow ignore though, as of course it is possible to get it to be identical, but it requires figuring out what it is.
Regarding amsmath: I do not know of any such case. I am thinking more from the perspective that many people have a hard time getting started with LaTeX and packages and so on. But I think that `\operatorname` and `\text` is still the way to go. Unless there are some symbols that for sure should be written in a Roman font.
In latex.py, `\mathrm` is used in the printers for `bool`, `NoneType`, `Trace`, `BaseScalarField`, and `Differential` (which has some unreachable code btw). For Trace we should obviously be using `\operatorname`, but for the others I'm not so sure. `\text` is currently used only in the Piecewise printer. 
Regarding amsmath I realized that \dddot and \ddddot are from amsmath, so #15982 added a bit more amsmath dependencies... (They were already used in the physics.vector printer earlier though.)
Even `matrix` requires amsmath, according to [this](https://en.wikibooks.org/wiki/LaTeX/Mathematics#cite_note-amsmath-3). I've never heard anyone complain about it. amsmath comes with LaTeX and is fully supported by MathJax, so I don't think there is an issue there.

The main compatibility issues for LaTeX are that it should be supported by MathJax (but virtually everything is), and it should be supported by matplotlib's mathtext if possible. 