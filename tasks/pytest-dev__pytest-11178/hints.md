We should probably error earlier, none is not approx-able

It seems to be a mistake to let approx take dict for convenience 
It appears that `None` is currently functional when passing it directly to approx, but not when passed as part of a dictionary (which gets processed by the `ApproxMapping` class, and a subtraction operation on the dict value is throwing the error).

I do agree that None shouldn't be approx-able based on what the function should be doing, though an early error on `None` may break existing tests, so should `ApproxMapping` instead be adjusted to better handle `None`? The documentation does include dictionaries with `None` values, and keeping the dict functionality may be helpful when dealing with multiple values from the same function run in a way that parameterize wouldn't cover.

I'm open to work on any of the above options, let me know the preferred direction!
> so should ApproxMapping instead be adjusted to better handle None?

I vote for that one; deprecating `None` would be a whole can of worms, but handling `None` seems to be the way to fix this, given the current failure is not acceptable.