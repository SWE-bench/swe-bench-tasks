I found the MathML code that seems to be in error, when symbol with a number in it is used, the following code is generated:
`<mi><msub><mi>r</mi><mi>2</mi></msub></mi>`

It looks like an extra set of <mi></mi> tags are present, when they are removed:
`<msub><mi>r</mi><mi>2</mi></msub>`

the rendered output has the symbol in it.
I tried this on a Windows machine today and it works correctly. It doesn't on the MacBook Pro I'm using, OS 10.14.2.
I am able to reproduce this behaviour on Safari. Unfortunately, Chrome does not support MathML.

The html code with MathML for `x2*z + x2**3` is:
```html
<html>
    <body>
        <math xmlns="http://www.w3.org/1998/Math/MathML">

            <!-- The line following is the generated MathML code -->
            <mrow><msup><mrow><mfenced><mi><msub><mi>x</mi><mi>2</mi></msub></mi></mfenced></mrow><mn>3</mn></msup><mo>+</mo><mrow><mi><msub><mi>x</mi><mi>2</mi></msub></mi><mo>&InvisibleTimes;</mo><mi>z</mi></mrow></mrow>

        </math>
    </body>
</html>
```

Removing the pair of `mi` tags around `<msub><mi>x</mi><mi>2</mi></msub>` works.
I tried on a Ubuntu machine with chrome and Mozilla and it works fine for me.
Yes it seems to be specific to Safari. As a workaround I"m using a regular
expression to find and remove any extra <mi> tags..

On Fri, Jan 18, 2019 at 1:59 AM Ritu Raj Singh <notifications@github.com>
wrote:

> I tried on a Ubuntu machine with chrome and Mozilla and it works fine for
> me.
>
> —
> You are receiving this because you authored the thread.
> Reply to this email directly, view it on GitHub
> <https://github.com/sympy/sympy/issues/15718#issuecomment-455473509>, or mute
> the thread
> <https://github.com/notifications/unsubscribe-auth/AsJHsGDSN-_HPPndcgRdjUKSpZhsyb9Oks5vEYzzgaJpZM4ZlqHG>
> .
>

Looking at https://www.tutorialspoint.com/online_mathml_editor.php

`<mi><msub><mi>r</mi><mi>2</mi></msub></mi>` gives x2 just as written.

`<msub><mi>r</mi><mi>2</mi></msub>` gives x2 with the 2 as a subscript.

So, while Safari could render it better, it still seems like the current output is not correct (as it is clear that it tries to render it with subscripts, `<msub>`).