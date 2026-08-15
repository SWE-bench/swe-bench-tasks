I have a fix in progress. Do you really want `x^{*2}`? I think either `{x^{*}}^{2}` or `(x^{*})^{2}` makes more sense (and is easier to implement, to the extent that I can say that  `x^{*2}` will not happen, at least not now, since it requires something of a LaTeX parser...).

Btw, using {} inside symbol names disables some parsing, so it may be better to use `x^*` as a symbol name and the printer will automatically translate it to `x^{*}` when outputting LaTeX and something similar when outputting to other formats. Using {} will leave the curly brackets there in the other output formats as well. (This works even for multi-character superscripts, so `x_foo^bar` comes out as `x_{foo}^{bar}`.)
Although I'd like to use `x^{*2}` in my current programming, I agree with that `(x^{*})^{2}` would be more appropriate for general case.

And thanks for the advice on using curly brackets! :)