+1 from my side. Same goes for the pyproject.toml file
This should be done during a configuration refactor, or it will be a small patch on something old and already very patched using optparse. 
I tried to figure out where exactly this order sensitive disable/enable comes from since it affects CLI, init and toml config. Can you point me to the right place? I can try to open a PR
Everything happens in ``Pylinter`` and I think the relevant class with the behavior for options parsing is ``config.OptionsManagerMixIn,`` (without absolute certainty). I would be interested in what you think of the current configuration and what you would do differentely if you take the time to understand how it works :)
Thanks for the hint. As far as I can say, the behavior comes from this code:
https://github.com/PyCQA/pylint/blob/a12242b2f44d5244bd1cacc6bc78df8c9c8e4296/pylint/config/option_manager_mixin.py#L309-L318

`parser.items(section)` is a list (so it's sorted), so the definition order is important. To be honest I'm not sure how to fix this since a very general loop is used
I can't think of a solution that will keep this for loop in its current state either.
Are there any plans to refactor the configuration module to use argparse and to modernize it a little bit?
Else, I'm not quite sure how to proceed. I guess this would be a breaking change, because

* `disable=all` ->`enable=bar` = `bar` 
* `enable=bar` -> `disable=all` = `all`

But the other way round, we also miss scenarios:
* `enable=all` ->`disable=bar` = `all except bar` 
* `disable=bar` -> `enable=all` = `all`.

So both orders have up and downsides. A possible statement could be: "It's not a bug, it's a feature 😄 "

Else maybe something like this (quite hacky and we need to decide on an order
```python
[...]
order_sensitive_config = {}
if option in ["enable", "disable"]:
  order_sensitive_config[option] = value
  continue
try: 
  self.global_set_option(option, value) 
except (KeyError, optparse.OptionError): 
   continue
[...]
if "enable" in order_sensitive_config:
  self.global_set_option("enable", order_sensitive_config["enable"]) 
if "disable" in order_sensitive_config:
  self.global_set_option("disable", order_sensitive_config["disable"]) 

I think the logical order is to always take ``all`` into account first, then the other one to enable or disable some of the message. Ie:

    disable=all ->enable=bar = only bar
    enable=bar -> disable=all = only bar
    enable=all ->disable=bar = all except bar
    disable=bar -> enable=all =all except bar

My reasoning is that you would not specify disable or enable when you use ``all`` for the other without wanting to modify the behavior of ``all``. Said another way, if enable=bar comes first it's effect will be completely canceled by disable=all, whereas the contrary is not true: all still has an effect on all other message than bar. So the user probably expect all to be taken into account first as they're not adding option for the sake of it.

You're right that it can be considered a breaking change, maybe we could move that to 3.0, or simply call that a bug fix, it depends on how "intuitive" this solution really is (maybe I've convinced myself but it will not be understood this way at all ?). Let me know what you think.

> Are there any plans to refactor the configuration module to use argparse and to modernize it a little bit?

There are plans (https://github.com/PyCQA/pylint/projects/1) but this is not a priority for most contributors and as a maintainers most of our time consists of reviewing merge requests, triaging issues and implementing absolutely necessary changes like the new match pattern in python 3.10, so there's very little time for this kind of (very important) refactoring project.





Thanks a lot for this insights.

I agree, it depends a lot how you look on this: It's either a breaking change or a bug fix. Since you asked what I would do: Personally, I would not use "dynamic" loops at all, but handle the options one by one. This leads obviously to more code, but options order dependencies and so in will disappear. But this is not possible w/o a refactoring.

So, what do you think about my approach above? It's not very nice, but I have o other idea. I like the idea to handle "all" special; this can be easily added.
Thank you. There's I think foor aspects to the refactor : 
- The loop is too generic. I agree with what you said.
- optparse is very old and would benefit from an argparse revamp
- Inheritance is used so everything is mixed up in Pylinter and even some checkers (composition and a class to handle the configuration, and the configuration only, would help imho)
- There's call back code for some options which means the options parsing is all other the place and hard to understands

If you can refactor only this for loop without modifying the other aspect that's fine for me, but a preliminary refactor might help. In particular I think argparse design force each argument to be handled separately, and this for loop would simply disappear (?) as well as a lot of optparse code that you don't need to do anymore nowadays. I don't know about click or confuse but this would be another possibility.

To be honest, moving away from optparse to argparse/click (click is btw very nice) would be (as far as I can say) a very drastic change. I did only one small change so far in pylint, so I'm kind of afraid doing this change. As you said, there are many patches and callbacks making it hard to understand for beginners. In the end, the code is not even typed, which add just more complexity and hurdles.

Any idea how we can move on from here?

Maybe a complete drop of the old code with a fresh design could help?
> Maybe a complete drop of the old code with a fresh design could help?

Yes, that would make a lot of sense especially for the transition to click or argparse. I think it's a lot easier to reproduce pylint's arg parsing from zero then replace the original code than to progressively refactor. It would be a breaking change though. I'm pretty sure that some strange bugs due to everything being done by hand with optparse are considered feature now. 
I spoke about confuse too, because it could help define a template yaml and have the argument to parse done automatically.

https://confuse.readthedocs.io/en/latest/

> Integration with command-line arguments via argparse or optparse from the standard library. Use argparse’s declarative API to allow command-line options to override configured defaults.
I might miss a detail about confuse, but it seems not to support toml and ini out of the box, doesn't it?
In regards to a redesign, I'm not sure if I have enough time... sadly
Yes, we're handling a lot of possible file and format.  Maybe migrating to ``pyproject.toml`` only and providing a tool to convert old conf (setup.cfg, and pylintrc) and just using confuse would be easier than maintaining what we currently have. Probably not short term but this seems like something that could be done in the future. I understand that such a refactor is not acceptable when what you intended to do was simply fix a little bug in the order of parsing 😄 
Pinging @jacobtylerwalls as I'm not sure you're subscribed to this issue and I'd like some input from you as well.

I have been thinking about this some more and I wonder if we should close this as `won't fix`. Although the current system is not that clearly documented (which we can/should do), it does work and is actually the most customisable. By using the order in which options are received it is also much clearer for the user what the "final state" will be.
If we obscure this by special casing `all` and parsing some disables before others this will only get worse.

<s>Note that you can even use double `disable=` in `ini` and `toml` files, so you can have a `disable`, `enable` and then a `disable` again to get the "final state" just as you would like it to be,</s>
I was wrong, this is not true.
I think it's valuable and probably not too hard. It's not a great solution to have to move your rcfile choices around.

Proposal:
- at any given "layer" of option providers, parse the "all"s first.
- if a given layer has both enable all and disable all, either parse them in their order or raise an exception
- that's it

All it "breaks" is the person who has `--disable=fixme --enable=all` in their config or rcfile and wants to get fixme messages nevertheless. Not a great thing to depend on, but it's going to exist out there. So should be a 3.0 thing.
> * at any given "layer" of option providers, parse the "all"s first.

That would require pre-scanning all providers for the `enable` and `disable` options, pre-processing those and then removing them from the arguments that are processed normally by `argparse`. Obviously we could, but I just want to point out the specific layer of additional complexity.
An example of how the current behavior can be misleading is what happened in #8328 when we tried to document ``suppressed-message`` (the way a configuration file option / in file message control / CLI option, interact together is NOT intuitive).