Thank you for the report, I can reproduce this bug. 
I have a fix, but I think this has the potential to break countless continuous integration and annoy a lot of persons, so I'm going to wait for a review by someone else before merging.
The fix is not going to be merged before a major version see https://github.com/PyCQA/pylint/pull/3514#issuecomment-619834791
Ahh that's a pity that it won't come in a minor release :( Is there an estimate on when 3.0 more or less lands?
Yeah, sorry about that. I don't think there is a release date for 3.0.0 yet, @PCManticore might want to correct me though.
Shouldn't you have a branch for your next major release so things like this won't bitrot?
I created a 3.0.0.alpha branch, where it's fixed. Will close if we release alpha version ``3.0.0a0``.
Released in 3.0.0a0.
🥳 thanks a lot @Pierre-Sassoulas!
Reopening because the change was reverted in the 3.0 alpha branch. We can also simply add a new reporter for json directly in 2.x branch and deprecate the other json reporter.