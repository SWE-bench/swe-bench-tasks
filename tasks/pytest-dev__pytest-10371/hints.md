i believe this could play into #7417 
Back after some time out :)

What do we think about a --suppress-logger= appendable parsearg option here, which takes a list of logger names (convert to set to avoid duplicates) and doing the following:

 - add NullHandler() to the logger to avoid warnings from last resort writing to stderr
 - mark propagate = False to avoid events being passed to ancestor handlers

Let me know, thanks :) its where I'm thinking to 'start' with this
As i suggested in the opening-post, i would choose an option name starting from `--log-...`, to fit with existing options related to the logging subsystem (e.g. in the `--help` message). 
Additionally, i would allow a separate option for each logger suppressed, to specify as value whether it should propagate=false/true.  
@symonk, are you still working on this and on #7417?

I've been looking through the issues labeled with `status: easy` in hopes of making a first contribution. This issue stood out to me since I've had problems with excessive logs during tests myself. Also, a possible solution doesn't seem to involve any subjects I'm too unfamiliar with.
Hello, @ankostis. Could you assign me to this issue?
Hey everone!
I'd like to tackle this as part of Hacktoberfest.
I see @symonk already had an ongoing PR (https://github.com/pytest-dev/pytest/pull/7873) that they closed.

I'm going to take it from there if it's ok.
Please, be my guest.