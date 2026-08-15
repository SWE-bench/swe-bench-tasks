There is no minor tick there anymore so there won’t be a label. What’s wrong w putting the HH:MM in the major label?
Actually, I don't think there is anything wrong with that. It's more that the previous code suddenly broke. Was this an intentional change? 
Yes though I’m on my phone and can’t look up the PRs.  Recent ones by @anntzer and or myself.  Basically minor ticks no longer include major ticks.   So no more over strike on the ticking and no more heuristic guessing if a labeled minor tick is really a major tick.  
Yes, that comes from https://github.com/matplotlib/matplotlib/pull/13314.  I guess this could have been better documented; on the other hand the issue that #13314 fixed did keep coming up again and again, so trying to play whack-a-mole by fixing it one locator at a time is a bit an endless task.

Note that in the example here, your formatters are actually not really independent from one another (you need to embed the newline in the major formatter), so I think the solution with the new API (`ax.xaxis.set_major_formatter(mdates.DateFormatter('%H%M\n%a'))` looks just fine.  (But yes, I acknowledge it's an API break.)
I see. Now reading the API change note, "Minor Locator no longer try to avoid overstriking major Locators", it seems to tell me the opposite, because obviously the minor locator does avoid the major locations. 

May I suggest to write an additional what's new entry that is understandable by normal people and shows what is changed and why that is?
Do you want to give it a try?  You are obviously more aware of the cases that have been broken.  (If not I'll do it, that's fine too.)
Is there any way to revert back to the old behaviour?
Right now, no.  Could perhaps be switched with a new flag (with the note that in that case, even loglocators don't try to avoid crashing minor and major ticks).
For a what's new entry maybe show the effect as follows:

```
ax.xaxis.set_major_locator(mticker.MultipleLocator(10))
ax.xaxis.set_minor_locator(mticker.MultipleLocator(2))
ax.xaxis.set_minor_formatter(mticker.ScalarFormatter())
ax.grid(which="both", axis="x")
```
previously:  
![majorminorchange_3 0 2](https://user-images.githubusercontent.com/23121882/53999892-84ea3080-4145-11e9-8409-e97551b0f3ca.png)

now:  
![majorminorchange_3 0 2 post1846 gfd40d7d74](https://user-images.githubusercontent.com/23121882/53999898-8b78a800-4145-11e9-95fe-e682117fc982.png)

I mean this really looks like a great improvement, but maybe someone relies on the major and minor ticks/grids overlapping? 
I think a what's new entry would still be useful, since noone reads API change notes. (Reading through the recent [API changes](https://matplotlib.org/api/api_changes.html#api-changes-for-3-0-0) actually a lot of them should have been mentionned in the what's new section?! Or maybe I don't quite understand the difference between what's new and API change notes?)


Also, how do you revert this change? Previously you could still write your own ticker in order not to tick some locations. Arguably, the new behaviour is much better for most standard cases. However for special cases, with this change, you cannot write any ticker to force a tick at a specific location if it happens to be part of the major ticks. Not even a `FixedLocator` will work, right? 

Concrete example:

```
ax.set_xticks([0.2], minor=True)
ax.grid(which="minor", axis="x")
```

previously:
![image](https://user-images.githubusercontent.com/23121882/54054874-b3bae200-41eb-11e9-8f2c-1a431d503c81.png)

now:

![image](https://user-images.githubusercontent.com/23121882/54054913-ccc39300-41eb-11e9-9ad8-8795f263fa31.png)

Question: How to get the gridline back?
I’m not opposed to having a way to get all the ticks back, but I’m not clear on what the practical problem is versus a theoretical one.   If you need a bunch of vertical lines at arbitrary locations axvline does that for you.  This makes all the practical cases much better at the cost of a few obscure cases being a bit harder.  I’d need a bit more to convince me that adding API to toggle this behaviour is worth the fuss. 

I think what’s new is for new features.  API changes is for changes to existing features.  At least in my mind.  OTOH Id support merging these two under what’s new and just labelling the API changes as such.  
> I’m not clear on what the practical problem is versus a theoretical one. 

That *is* a theoretical problem indeed. You type something in (`ax.set_xticks(..)`) and don't get out what you asked for, like

```
you > Please give me a tick at position 0.2
interpreter > Na, I don't feel like doing that is a good idea; I will ignore your command.
```

> If you need a bunch of vertical lines at arbitrary locations axvline does that for you. 

Sure, there is no need for `.grid` at all, given that there is a `Line2D` object available.


> I think what’s new is for new features. API changes is for changes to existing features. 

I think I would argue that things like  "Hey look, we've fixed this long standing bug." or "If you use good old command `x` your plot will now look like `y`." are still somehow *news* people are interested in reading the What's new section.

> interpreter > Na, I don't feel like doing that is a good idea; I will ignore your command.

Thats correct - #13314 says that minor ticks are exclusive of major ticks by definition, so if you ask to put a minor tick where a major tick is, you won't get it.  

I'm still not clear what the use-case is, but if you need to hack around this definition: 

```
import matplotlib.pyplot as plt

fig, ax =plt.subplots()
ax.set_xticks([0.2001], minor=True)
ax.grid(which="minor", axis="x")
plt.show()
```

though I note that going more decimal places (0.20001) excludes the tick, which seems a bit too much slop...  (well, its `rtol=1e-5`)
On my phone but note that #11575 is close to (though not exactly) the opposite of what @ImportanceOfBeingErnest mentioned above: users were complaining that set_xticks did not cause the minor ticks to be excluded from colliding locations. 
The fact that log scales use major and minor locators is more an implementation detail, #11575 could be solved differently as well. In general, I'm not at all opposing the **default** Locators to exclude minor ticks at major tick positions. 

If the decision is indeed to redefine the notions of major and minor in the sense of *"minor ticks are exclusive of major ticks by definition"*, that *is* a major change in the semantics and a "What's new" entry is the very least one needs for that. 
I don't mind moving/duplicating the api_changes to the whatsnew.
If you want to put up an alternate PR to fix issue #11575 and the other similar issues, and revert #13314, I won't block it either.
Having a different behavior for default and nondefault locators (what's even a "default" locator?) seems strange, though.
By "default" I meant all those cases where the user does not type in `.set_minor_locator` or `.set_xticks`; that would in addition to normal plots be e.g. `plt.semilogy`, `plt.plot(<list of datetimes>)` etc. 
But I fully agree that different behaviour is in general undesired. I also acknowledge that this change is useful for all but a few edge cases. 
It's really more a principle thing: major and minor locators are not independent of each other any more. (A use case would be the original issue where in addition you use a different color or font(size) for the major and minor labels.) 

The best would be an opt-out option for this behaviour. (But I currently wouldn't know where to put that. In the locators? In the axes?)  
If people really think, that is not necessary, adding a note in the what's new/Api change that says something like *"We feel this change best reflects how people would use major and minor locators; however if you have a usecase where this is causes problems, please do file a report on the issue tracker."* might be the way to go.
> By "default" I meant all those cases where the user does not type in .set_minor_locator or .set_xticks; 

But all #11575 *is* a case where the user uses set_xticks but wants collision suppression...

> A use case would be the original issue where in addition you use a different color or font(size) for the major and minor labels.

The real fix would be to allow text objects with variable color or size (I mean, here you can have two different colors (major/minor) but not three, so that's clearly a hack).

-----

Can you open a PR to add whatever note you want to the api_changes and possibly move it to the whatsnew?  I think we should try to keep this as is, and, if there's too much pushback against it, we can consider adding the opt-out in a future release.
> Can you open a PR [...] ?

No sorry, I can't. I did try and it came out too sarcastic to be publishable. 
Do you want to block 3.1 over that?  (That's fine with me, but you need to ask for it :))
No, I don't want to block 3.1 over this. I gave some arguments above, and if they are not shared by others, I might simply be wrong in my analysis. 
OK, let's just ping @tacaswell to get his opinion as well then, if he wants to chime in before the 3.1 release.
Suggest we add to tomorrow’s agenda.  
Discussed on call

https://paper.dropbox.com/doc/Matplotlib-2019-meeting-agenda--AaCmZlKDONJlV5crSSBPDIBjAg-aAmENlkgepgsMeDZtlsYu#:h2=13618:-Minor-tick-supression-w

Primary plan is to try to add a public API for controlling the de-confliction
Backup plan is to revert this and try again for 3.2