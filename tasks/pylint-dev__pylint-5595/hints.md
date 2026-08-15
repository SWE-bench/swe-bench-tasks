agree, it is very unusual.
I've toyed with the idea of adjusting the scoring such that larger amounts of issues result in a score that becomes closer and closer to 0 while keeping scores rated 5 and above by the current algorithm the same.  I've arrived at [10( (x^a + 1)^(1/a) - x)](https://www.desmos.com/calculator/1frsbnwoid), loosely based on how Minkowski distance works, where x is the density of issues and a is a taper factor.  4 seems to be a good value for a.

I guess a function like this could be added
```py
def taper_score(x, a):
    """Turns a value going from 0 to infinity into a score from 10 to 0

    Starts off linear with the relation 10 - 10 * x and gradually turns
    into an exponential fall off, with a sharpness determined by a.

    Increasing the parameter a gives a sharper taper, and as a goes
    to infinity this function converges to max(10 - 10 * x, 0).
    """
    return 10 * (x ** a + 1) ** (1 / a) - 10 * x
```
And then update the scoring expression to
```py
taper_score((5 * error + warning + refactor + convention) / statement, 4.0)
```

But I don't really see a difference between your code being rated `0.1/10.0` instead of`-24/10.0`.  Usability wise my biggest issue would be the difficulty sorting through and inspecting the messages.  The defaults when run on a medium sized project tends to [spew out 1500 messages](http://www.hornwitser.no/x/discord/lint/#ref=rapp/rewrite&types=all&modules=all&hide=reports,filters) straight into the terminal.
@Hornwitser That's interesting, thanks for posting the comment. It might be worth giving it a try if you have some time to send a PR. Regarding your second comment, you might be interested in #746 which unfortunately stalled, but would provide a solution to the sorting and inspecting the messages that pylint emits.
The /10 strongly implied a rating of 0 or 1 to 10 for me, until I got a negative rating and questioned the whole system, started searching and found this issue.

No idea if the scoring system is good or bad in the bigger picture, but I can tell you it ain't intuitive.
From FAQ:

> However, this option can be changed in the Pylint rc file. If having negative
values really bugs you, you can set the formula to be the maximum of 0 and the
above expression.

Any reason we wouldn't just do this now? I don't know why we would need to wait an unspecified amount of time for v.3.0, especially if it's so easy to get the old behavior back. Do folks really have CI pipelines where the passing scores is negative and a score 0.0 will unexpectedly pass?

One argument for doing this in v2.13.0 is that we merged #5521 -- now a run with a fatal error can score higher than a negative score.
Although I'm generally for changing things sooner rather than later I think the `2.12` update showed me that plugins and other integrations of `pylint` use our internals in very particular ways.
I don't think we can guarantee that nobody is relying on the fact that scores can be negative. I would be hesitant to change this right now. Also because there is not that much benefit to us. Although unintuitive, the fact that scores can be negative is not really limiting us in working on or improving pylint.
Daniel is right about the fact that it might breaks things for some plugin mainteners / users. Sometime it's surprising.

![workflow](https://user-images.githubusercontent.com/5493666/147258919-6fa89c74-922c-4d7f-a172-ab8241553454.png)

But it's also making users feel bad (I remember I felt hurt with my first negative score 😄) and it's easy to change so we could change it. 

I was thinking about this lately and maybe a solution would be to add levels, i.e. if you have an error, you'll have between 0 and 2.5/10 (Or between 0 and 10 but you're at level 0 of code quality), if you do not have any errors you'll have between 2.5 and 10.0 (Or 0 and 10 at level 1 of quality). This could affect more than the score and could also be the philosophy behind a kind of guide to what should be done next for a particular user instead of just dumping thousands of messages on their legacy code base. We made a pretty lengthy comments chain about the next step in gamification of pylint with @cdce8p in the last MR before a release and rather stupidly I did not create an issue with the discussion. Now it's lost in a MR from a long time ago that I can't find again 😄 Let me know if you remember where / when we talked about that Marc :)
Didn't know it either, but a search for `gamification` seems to work 🤷🏻‍♂️ https://github.com/PyCQA/pylint/pull/4538#issuecomment-853355683
There is also this comment here that mentioned it: https://github.com/PyCQA/pylint/issues/746#issue-122747071
> I don't think we can guarantee that nobody is relying on the fact that scores can be negative.

The scoring algorithm is a config option (`--evalutation`), if someone depends on the exact value returned by pylint's score they can set it to use the old algorithm when it's changed.
> The scoring algorithm is a config option (`--evalutation`), if someone depends on the exact value returned by pylint's score they can set it to use the old algorithm when it's changed.

I think I misinterpreted @jacobtylerwalls. Sorry about that! Changing the default score evaluation should be fine indeed, not allowing negative scores should not be done (for now). Thanks for pointing this out @Hornwitser 👍 
Cool. Yeah. That's what I was thinking. #5521 already changed the default evaluation for fatal errors and so it would make for a more consistent release story to say that in tandem with that we also set the (default) score floor to 0. I can push a PR to keep discussion going, not to be pushy!
agree, it is very unusual.
I've toyed with the idea of adjusting the scoring such that larger amounts of issues result in a score that becomes closer and closer to 0 while keeping scores rated 5 and above by the current algorithm the same.  I've arrived at [10( (x^a + 1)^(1/a) - x)](https://www.desmos.com/calculator/1frsbnwoid), loosely based on how Minkowski distance works, where x is the density of issues and a is a taper factor.  4 seems to be a good value for a.

I guess a function like this could be added
```py
def taper_score(x, a):
    """Turns a value going from 0 to infinity into a score from 10 to 0

    Starts off linear with the relation 10 - 10 * x and gradually turns
    into an exponential fall off, with a sharpness determined by a.

    Increasing the parameter a gives a sharper taper, and as a goes
    to infinity this function converges to max(10 - 10 * x, 0).
    """
    return 10 * (x ** a + 1) ** (1 / a) - 10 * x
```
And then update the scoring expression to
```py
taper_score((5 * error + warning + refactor + convention) / statement, 4.0)
```

But I don't really see a difference between your code being rated `0.1/10.0` instead of`-24/10.0`.  Usability wise my biggest issue would be the difficulty sorting through and inspecting the messages.  The defaults when run on a medium sized project tends to [spew out 1500 messages](http://www.hornwitser.no/x/discord/lint/#ref=rapp/rewrite&types=all&modules=all&hide=reports,filters) straight into the terminal.
@Hornwitser That's interesting, thanks for posting the comment. It might be worth giving it a try if you have some time to send a PR. Regarding your second comment, you might be interested in #746 which unfortunately stalled, but would provide a solution to the sorting and inspecting the messages that pylint emits.
The /10 strongly implied a rating of 0 or 1 to 10 for me, until I got a negative rating and questioned the whole system, started searching and found this issue.

No idea if the scoring system is good or bad in the bigger picture, but I can tell you it ain't intuitive.
From FAQ:

> However, this option can be changed in the Pylint rc file. If having negative
values really bugs you, you can set the formula to be the maximum of 0 and the
above expression.

Any reason we wouldn't just do this now? I don't know why we would need to wait an unspecified amount of time for v.3.0, especially if it's so easy to get the old behavior back. Do folks really have CI pipelines where the passing scores is negative and a score 0.0 will unexpectedly pass?

One argument for doing this in v2.13.0 is that we merged #5521 -- now a run with a fatal error can score higher than a negative score.
Although I'm generally for changing things sooner rather than later I think the `2.12` update showed me that plugins and other integrations of `pylint` use our internals in very particular ways.
I don't think we can guarantee that nobody is relying on the fact that scores can be negative. I would be hesitant to change this right now. Also because there is not that much benefit to us. Although unintuitive, the fact that scores can be negative is not really limiting us in working on or improving pylint.
Daniel is right about the fact that it might breaks things for some plugin mainteners / users. Sometime it's surprising.

![workflow](https://user-images.githubusercontent.com/5493666/147258919-6fa89c74-922c-4d7f-a172-ab8241553454.png)

But it's also making users feel bad (I remember I felt hurt with my first negative score 😄) and it's easy to change so we could change it. 

I was thinking about this lately and maybe a solution would be to add levels, i.e. if you have an error, you'll have between 0 and 2.5/10 (Or between 0 and 10 but you're at level 0 of code quality), if you do not have any errors you'll have between 2.5 and 10.0 (Or 0 and 10 at level 1 of quality). This could affect more than the score and could also be the philosophy behind a kind of guide to what should be done next for a particular user instead of just dumping thousands of messages on their legacy code base. We made a pretty lengthy comments chain about the next step in gamification of pylint with @cdce8p in the last MR before a release and rather stupidly I did not create an issue with the discussion. Now it's lost in a MR from a long time ago that I can't find again 😄 Let me know if you remember where / when we talked about that Marc :)
Didn't know it either, but a search for `gamification` seems to work 🤷🏻‍♂️ https://github.com/PyCQA/pylint/pull/4538#issuecomment-853355683
There is also this comment here that mentioned it: https://github.com/PyCQA/pylint/issues/746#issue-122747071
> I don't think we can guarantee that nobody is relying on the fact that scores can be negative.

The scoring algorithm is a config option (`--evalutation`), if someone depends on the exact value returned by pylint's score they can set it to use the old algorithm when it's changed.
> The scoring algorithm is a config option (`--evalutation`), if someone depends on the exact value returned by pylint's score they can set it to use the old algorithm when it's changed.

I think I misinterpreted @jacobtylerwalls. Sorry about that! Changing the default score evaluation should be fine indeed, not allowing negative scores should not be done (for now). Thanks for pointing this out @Hornwitser 👍 
Cool. Yeah. That's what I was thinking. #5521 already changed the default evaluation for fatal errors and so it would make for a more consistent release story to say that in tandem with that we also set the (default) score floor to 0. I can push a PR to keep discussion going, not to be pushy!