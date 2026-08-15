The crash will be fixed in https://github.com/PyCQA/pylint/pull/7228. Regarding the issue with the comma, I think a list of regex is not possible and it could be a big regex with both smaller regex and a ``|``. So we might want to change the way we handle this.
thanks for the response! As you mentioned, this isn't urgent or blocking, since quantifiers are the only python regex syntax that uses commas and commas aren't otherwise valid in python identifiers. Any quantifier can be reworded with some copy/pasting and `|`s but that gets ugly pretty fast so I figured I'd raise it here.
At the least, I think this might warrant some explicit documentation since this could silently create two valid regexes instead of just erroring out, which is the worst scenario IMO
I'm not suggesting you should work around this using ``|`` and nothing should be done in pylint, Permitting to have list of regex separated by comma is probably not something we should continue doing seeing comma have meaning in regexes. I imagine that if we remove the possibility to create a list of regex with comma from pylint and if someone want multiple regexes he can do that easily just be joining them together. i.e. instead of ``[a-z]*,[A-Z]*`` for ``[a-z]*`` and ``[A-Z]*`` it's possible to have a single regex ``[a-z]*|[A-Z]*``. 
Hey @Pierre-Sassoulas. The crash in this case won't be fixed by #7228 since this has a different argument [type](https://github.com/PyCQA/pylint/blob/main/pylint/config/argument.py#L134). Would you prefer if I update the existing MR to handle this case also or create a separate MR?

Although - depending on if you want to keep the csv functionality, perhaps we can treat both cases like we are passing one single regex (and not a comma-sepatated list of them)
What do you think @DanielNoord , should we keep the sequence of pattern type and fix it ? 
Changing that would be a major break for many options. I do think we should try and avoid them in the future.
But its ok to validate each individual regex in the csv using the new function [here](https://github.com/PyCQA/pylint/pull/7228/files#diff-9c59ebc09daac00e7f077e099aa4edbe3d8e5c5ec118ba0ffb2c398e8a059673R102), right @DanielNoord?
If that is ok then I can either update the existing MR or create a new one here to keep things tidy.
> But its ok to validate each individual regex in the csv using the new function [here](https://github.com/PyCQA/pylint/pull/7228/files#diff-9c59ebc09daac00e7f077e099aa4edbe3d8e5c5ec118ba0ffb2c398e8a059673R102), right @DanielNoord?
> 
> If that is ok then I can either update the existing MR or create a new one here to keep things tidy.

Yeah! Let's exit cleanly.
If we keep this, should we do something more complex like not splitting on a comma if it's inside an unclosed ``{`` ? Maybe keep the bug as is deprecate and remove in pylint 3.0 ?
I think it makes sense to remove it in Pylint 3.0 if 1. we want to remove it & 2. the concern for removing it is that it is a breaking change.
Updated #7228 to handle the crash in this issue; although nothing is in place to avoid splitting in the middle of the regex itself.
I can make a PR to avoid splitting on commas in quantifiers without breaking existing functionality, if you'd like. Since commas in regular expressions only occur in narrow circumstances, this is feasible without too much complexity, IMO
> Since commas in regular expressions only occur in narrow circumstances, this is feasible without too much complexity,

We appreciate all the help we can get :) How would you do it @lbenezriravin ? What do you think of "not splitting on a comma if it's inside an unclosed ``{``" ?
Wouldn't it be a better use of our efforts to deprecate these options and create new ones which don't split?
It's a bit of a hassle for users to change the name in the configuration files, but it is much more future proof and starts us on the path of deprecation.
@Pierre-Sassoulas yeah, that's exactly what I was thinking. Here's a quick prototype that I verified works on the trivial cases. Obviously I'd clean it up before PRing
```
def split_on_commas(x):
    splits = [None]
    open = False
    for char in x:
        if char == '{':
            open = True
        elif char == '}' and open is not False:
            open = False
        if char == ',' and open is False:
            splits.append(None)
        else:
            if splits[-1] is None:
                splits.append([char])
            else:
                splits[-1].append(char)
    return [''.join(split) for split in splits if split is not None]
 ```

@DanielNoord I agree that deprecating the functionality in the long term is best, but if I can quickly patch a bug in the short term, I'm happy to help.
I'm hesitating between 'let's do the fix and wait to see if the fix is good enough before deprecation' and 'let's warn of the deprecation only when there's  comma inside {} thanks to the fix' :smile: