@mhvk - I'm happy to do this PR if you think it is a good idea.
I agree there no longer is any reason to put structured arrays into `NdarrayMixin` -- indeed, I thought I had already changed its use! So, yes, happy to go ahead and create structured columns directly.
So you think we should change it now, or do a release with a FutureWarning that it will change?
Thinking more, maybe since the NdarrayMixin is/was somewhat crippled (I/O and the repr within table), and any functionality is compatible with Column (both ndarray subclasses), we can just do this change now?  Delete a few lines of code and add a test.
I agree with just changing it -- part of the improvement brought by structured columns