This was as implemented back in #2159. I don't see any `inspect.isproperty`. Do you have any suggestions?
I guess it should work with [inspect.isdatadescriptor](https://docs.python.org/3/library/inspect.html#inspect.isdatadescriptor). 
And I wonder if this class is still needed, it seems that it started with #2136 for an issue with Sphinx, but from what I can see the docstring are inherited without using this class (for methods and properties).
If it is not needed anymore, then it should be deprecated instead of fixed. 🤔 
Well it dosen't seem to work right off without this for me, am I missing something in my `conf.py` file?
I wonder if it may work by default only if the base class is an abstract base class? (haven't checked)
I probably tested too quickly, sorry: if I don't redefine a method/property in the child class, I correctly get its signature and docstring. But if I redefine it without setting the docstring, then indeed I don't have a docstring in Sphinx. (But I have the docstring with help() / pydoc)