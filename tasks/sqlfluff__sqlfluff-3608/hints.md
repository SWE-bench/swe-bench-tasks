I'm happy to contribute the changes for this one, but would appreciate views on what the error codes we should align on first @barrywhart @tunetheweb 
I'm not familiar with any widespread conventions about exit codes, except to keep them below 256.

This Stack Overflow post has a lot of discussion, often self-contradictory. https://stackoverflow.com/questions/1101957/are-there-any-standard-exit-status-codes-in-linux

Overall, your proposal sounds good to me.

Can you also search the existing issues for any mention of exit codes? I think there may be one or two open issues, perhaps related to the behavior when "fix" finds issues but some are unfixable. Because of its multifaceted nature as a linter and fixer that is used both interactively (e.g. during pre-commit) and in batch (CICD), SQLFluff perhaps has more stringent requirements for precise exit codes than some other tools. Do you think it'd be useful to review existing (and or write some new) user documentation before starting the coding, to help get a better understanding of the various use cases?



Agree with @barrywhart 's comments.

Only question is why 65/66 instead of just 2/3?
> Only question is why 65/66 instead of just 2/3?

This was initially because I had read that codes 0-64 were reserved for system usage but it appears things aren't that consistent.

> This Stack Overflow post has a lot of discussion, often self-contradictory...

I'm wondering based on this post whether we should simplify things:
- 0: success
- 1: fail (on linting or fixing, but due to finding issues with code or unable to fix, no "errors")
- 2: fail because misuse or error

It's slightly less granular but a little more consistent with the bash approach (from the most recent post on that SO question):

> Exit status 0: success
> Exit status 1: "failure", as defined by the program
> Exit status 2: command line usage error
Cleaning up the exit codes seems sensible. How likely do we think it is to break things for users?
Relatively unlikely I reckon - I'm not sure the existing codes are sufficiently granular to be useful right now.