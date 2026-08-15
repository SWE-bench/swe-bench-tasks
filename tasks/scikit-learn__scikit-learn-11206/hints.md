@jnothman i am constantly getting these mismatch of the values in an array calculated. since i am getting no error in my local system, it looks the only way to figure out which line of the code is creating this error is to undo all new codes and implement 1 step at a time and see if it gets a green tick.

So in short:
* revert all changes
* implement each step like np.nansum() and np.nanvar and then see if it keeps on getting a green tick

Please let me know your views before i start doing that (as this kind of approach is going to take up a lot of waiting time as travis and appveyor is extremely slow)
I must admit that it appears quite perplexing for something like `test_incremental_variance_ddof` to succeed on one platform and fail drastically on others. Could I suggest you try installing an old version of cython (0.25.2 is failing) to see if this affects local test runs...?

If you really need to keep pushing to test your changes, you can limit the tests to relevant modules by modifying `appveyor.yml` and `build_tools/travis/test_script.sh`.
(Then again, it seems appveyor is failing with the most recent cython)
Nah, it looks like cython should have nothing to do with it. Perhaps numpy version. Not sure... :\
Behaviour could have changed across numpy versions that pertains to numerical stability. Are you sure that when you do `np.ones(...)` you want them to be floats, not ints?
Though that's not going to be the problem for numpy 1.10 :|
@jnothman i did np.ones() float because I doubted that maybe the division was somehow becoming an integer division i.e. 9/2=4 and not 4.5 . Maybe because of that (though it was quite illogical) but later even after making dtype=float the same errors are repeating, hence that is not the source of problem.

Probably i should move 1 step at a time. That would easily locate the source of error.
as long as `__future__.division` is imported, that should not be an issue.
I'll see if I have a moment to try replicate the test failures.

Yes, downgrading numpy to 1.10.4 is sufficient to trigger the errors. I've
not investigated the cause.

@jnothman can you please review this?
                                                                                      Yes but I considered those changes as minimal since that this is one estimator and mainly tests.
@jnothman @glemaitre can you please review the code now. i have made all the changes according to your previous review.
>  I'll make them generalised i.e. if all n_samples_seen are equal, it will return a scalar instead of a vector.

@pinakinathc ok. ping me when you addressed all the points to be reviewed.