I suppose this error was raised when autodoc could not process some kind of type annotation. So I need to know what kind of python code was documented. Could you share your project? Or could you make a minimal reproducible example?
Thanks for your reply. Unfortunately, I cannot share the whole project but thanks to your hint, I understood the problem is related to the package `nptyping`. I get the error when I do something like:

`from nptyping import NDArray`
`def funct(a: NDArray[float]) -> float`

I hope this helps.
If it's not enough, I would try to make a more detailed example, please let me know.