Number 2 sounds good to me!
@barrywhart which variation?
I would replace with single "normal" quotes: ' rather than \`.

The clever approach could be cool for later, but I wouldn't try it now. I can't remember if we already handle detecting whether we're running in a terminal or not, because the techniques for doing bold or colored text don't work well when redirecting output to a file, etc.
> The clever approach could be cool for later, but I wouldn't try it now. I can't remember if we already handle detecting whether we're running in a terminal or not, because the techniques for doing bold or colored text don't work well when redirecting output to a file, etc.

Yeah I think there's some `isatty` function we use in the formatter, but agree on the simple replace method for now 😄 