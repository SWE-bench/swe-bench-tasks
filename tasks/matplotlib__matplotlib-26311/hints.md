I left a comment on your commit.

Trying to target the end of a broken contour might be easier?
> Writing a test seems harder. I tried pasting the above code into a test, and it passed against main. I assume that is because the tests have different "screen space" than when I just run it as a script.

Can you set the DPI of the figure in your test to whatever you're using locally so that the rendered size is the same and therefore transforms to the same screen-size?