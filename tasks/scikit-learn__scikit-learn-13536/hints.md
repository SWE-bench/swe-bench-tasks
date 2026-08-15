There is some code in gradient boosting that checks for the current error message, so that should be updated to reflect a changed error message too.

(Arguably, this should be a TypeError, not a ValueError, since the user has passed the wrong parameter names, but I'm ambivalent to whether we fix that.)
I'd like to take this issue.